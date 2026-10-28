// CoroAwareCFIPass.cpp
#include "CoroAwareCFIPass.h"
#include "CoroDefenseAnalysis.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "coro-aware-cfi"
// Byte offset of the TypeID field in the coroutine frame.
// The modified CoroFrame.cpp adds the TypeID as a header field *after* the
// promise, so the promise keeps its ABI-fixed offset (16) that
// coroutine_handle::from_promise() relies on. For this project's coroutines
// (empty promise, 1 byte at offset 16) the i32 TypeID aligns to offset 20.
#define CORO_TYPEID_OFFSET 20u   // byte offset of TypeID in frame

using namespace llvm;

// ── Helpers ─────────────────────────────────────────────────────────────────

// Get or create a tiny "noop" function for the noop_coroutine slots.
static Function *getNoopStub(Module &M, bool IsResume) {
    const char *Name = IsResume ? "__coro_noop_resume" : "__coro_noop_destroy";
    if (auto *F = M.getFunction(Name)) return F;
    auto *FTy = FunctionType::get(
        Type::getVoidTy(M.getContext()),
        {PointerType::getUnqual(M.getContext())}, false);
    auto *F = Function::Create(FTy, GlobalValue::InternalLinkage, Name, M);
    BasicBlock::Create(M.getContext(), "entry", F);
    IRBuilder<>(cast<BasicBlock>(&F->front())).CreateRetVoid();
    return F;
}

// ── Build the read-only dispatch table ─────────────────────────────────────

static GlobalVariable *buildDispatchTable(Module &M,
                                          std::vector<CoroTypeRecord> &Types)
{
    LLVMContext &Ctx = M.getContext();
    auto *PtrTy  = PointerType::getUnqual(Ctx);

    // Entry type: { ptr resume_fn, ptr destroy_fn }
    StructType *EntryTy = StructType::get(Ctx, {PtrTy, PtrTy}, false);

    // Sort by TypeID so table[TypeID] is a direct index.
    std::sort(Types.begin(), Types.end(),
              [](auto &A, auto &B){ return A.TypeID < B.TypeID; });

    // Total slots: 0 (noop) + one per type.
    unsigned N = (unsigned)Types.size() + 1;
    std::vector<Constant *> Entries(N);

    // Slot 0: noop_coroutine.
    Entries[0] = ConstantStruct::get(EntryTy, {
        getNoopStub(M, true), getNoopStub(M, false)});

    // Slots 1..N-1: real coroutine types.
    for (auto &Rec : Types) {
        Constant *RF = Rec.ResumeFn
            ? static_cast<Constant *>(Rec.ResumeFn)
            : ConstantPointerNull::get(PtrTy);
        Constant *DF = Rec.DestroyFn
            ? static_cast<Constant *>(Rec.DestroyFn)
            : ConstantPointerNull::get(PtrTy);
        Entries[Rec.TypeID] = ConstantStruct::get(EntryTy, {RF, DF});
    }

    auto *TableTy   = ArrayType::get(EntryTy, N);
    auto *TableInit = ConstantArray::get(TableTy, Entries);

    auto *Table = new GlobalVariable(
        M, TableTy,
        /*isConstant=*/true,          // → .rodata
        GlobalValue::InternalLinkage,
        TableInit, "__coro_dispatch_table");
    Table->setSection(".rodata");
    Table->setAlignment(Align(8));
    return Table;
}

// ── Emit the dispatch functions ─────────────────────────────────────────────

static Function *buildDispatchFn(Module &M, bool IsResume,
                                 GlobalVariable *Table, unsigned NumSlots)
{
    LLVMContext &Ctx = M.getContext();
    auto *VoidTy = Type::getVoidTy(Ctx);
    auto *I32Ty  = Type::getInt32Ty(Ctx);
    auto *I8Ty   = Type::getInt8Ty(Ctx);
    auto *PtrTy  = PointerType::getUnqual(Ctx);

    auto *FTy = FunctionType::get(VoidTy, {PtrTy}, false);
    const char *Name = IsResume
        ? "__coro_dispatch_resume" : "__coro_dispatch_destroy";
    auto *Fn = Function::Create(FTy, GlobalValue::InternalLinkage, Name, M);

    // noinline: the bounds check MUST NOT be optimised away by inlining.
    Fn->addFnAttr(Attribute::NoInline);
    Fn->addFnAttr(Attribute::NoUnwind);

    auto *Entry    = BasicBlock::Create(Ctx, "entry",    Fn);
    auto *Dispatch = BasicBlock::Create(Ctx, "dispatch", Fn);
    auto *OOB      = BasicBlock::Create(Ctx, "oob",      Fn);

    IRBuilder<> B(Entry);
    Value *Frame = Fn->getArg(0);

    // Load TypeID from frame + CORO_TYPEID_OFFSET.
    Value *TIDPtr = B.CreateConstGEP1_64(I8Ty, Frame, CORO_TYPEID_OFFSET,
                                          "typeid.ptr");
    Value *TID    = B.CreateLoad(I32Ty, TIDPtr, "typeid");

    // Bounds check: TypeID < NumSlots.
    Value *OK = B.CreateICmpULT(TID, ConstantInt::get(I32Ty, NumSlots), "ok");
    B.CreateCondBr(OK, Dispatch, OOB);

    // OOB → trap (SIGILL signals a security violation clearly).
    B.SetInsertPoint(OOB);
    B.CreateIntrinsic(Intrinsic::trap, {}, {});
    B.CreateUnreachable();

    // Dispatch → table[TID].resume_fn(frame) or .destroy_fn(frame).
    B.SetInsertPoint(Dispatch);
    auto *TableTy  = cast<ArrayType>(Table->getValueType());
    auto *EntryTy  = cast<StructType>(TableTy->getElementType());

    Value *EntryPtr = B.CreateInBoundsGEP(
        TableTy, Table,
        {ConstantInt::get(I32Ty, 0), TID}, "entry.ptr");
    unsigned FieldIdx = IsResume ? 0 : 1;
    Value *FnPtrPtr = B.CreateStructGEP(EntryTy, EntryPtr, FieldIdx, "fn.slot");
    Value *TargetFn = B.CreateLoad(PtrTy, FnPtrPtr, "target.fn");

    B.CreateCall(FTy, TargetFn, {Frame});
    B.CreateRetVoid();

    return Fn;
}

// ── Inject TypeID stores into creation stubs ────────────────────────────────

static void injectTypeIDStores(std::vector<CoroTypeRecord> &Types) {
    for (auto &Rec : Types) {
        if (!Rec.RampFn) continue;

        // Find the store of the resume function pointer in the ramp.
        for (BasicBlock &BB : *Rec.RampFn) {
            for (Instruction &I : BB) {
                auto *SI = dyn_cast<StoreInst>(&I);
                if (!SI) continue;
                if (SI->getValueOperand()->stripPointerCasts() != Rec.ResumeFn)
                    continue;

                // Walk back to the frame base pointer.
                Value *StoreDst = SI->getPointerOperand();
                Value *FrameBase = StoreDst;
                if (auto *GEP = dyn_cast<GetElementPtrInst>(StoreDst))
                    FrameBase = GEP->getPointerOperand();

                // Insert store of TypeID immediately after this store.
                IRBuilder<> B(SI->getNextNode());
                LLVMContext &Ctx = SI->getContext();

                Value *TIDPtr = B.CreateConstGEP1_64(
                    B.getInt8Ty(), FrameBase, CORO_TYPEID_OFFSET, "typeid.slot");
                B.CreateStore(
                    ConstantInt::get(Type::getInt32Ty(Ctx), Rec.TypeID), TIDPtr);

                goto next_type;
            }
        }
        next_type:;
    }
}

// ── Replace indirect call sites with dispatch calls ─────────────────────────

static void replaceCallSites(std::vector<CoroCallSite> &Sites,
                             Function *DispResume, Function *DispDestroy)
{
    auto *FTy = DispResume->getFunctionType();

    for (auto &Site : Sites) {
        Function *Target = Site.IsResume ? DispResume : DispDestroy;
        IRBuilder<> B(Site.Call);

        CallBase *New;
        if (auto *CI = dyn_cast<CallInst>(Site.Call)) {
            New = B.CreateCall(FTy, Target, {Site.FramePtr});
        } else {
            auto *II = cast<InvokeInst>(Site.Call);
            New = B.CreateInvoke(FTy, Target,
                                 II->getNormalDest(), II->getUnwindDest(),
                                 {Site.FramePtr});
        }
        New->setDebugLoc(Site.Call->getDebugLoc());
        Site.Call->eraseFromParent();
    }
}

// ── Pass entry point ────────────────────────────────────────────────────────

PreservedAnalyses CoroAwareCFIPass::run(Module &M, ModuleAnalysisManager &) {
    CoroDefenseAnalysis A;
    if (!A.run(M)) return PreservedAnalyses::all();  // no coroutines

    unsigned NumSlots = (unsigned)A.Types.size() + 1;  // +1 for noop at [0]

    GlobalVariable *Table = buildDispatchTable(M, A.Types);

    Function *DispResume  = buildDispatchFn(M, true,  Table, NumSlots);
    Function *DispDestroy = buildDispatchFn(M, false, Table, NumSlots);

    injectTypeIDStores(A.Types);
    replaceCallSites(A.CallSites, DispResume, DispDestroy);

    return PreservedAnalyses::none();
}