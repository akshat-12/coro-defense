// CoroShadowPass.cpp
#include "CoroShadowPass.h"
#include "CoroDefenseAnalysis.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "coro-shadow"
using namespace llvm;

// Classify an existing call: is it a CFI dispatch call or a raw indirect call?
static bool isCallTo(CallBase *CB, StringRef Name) {
    auto *CF = CB->getCalledFunction();
    return CF && CF->getName() == Name;
}

// Is this an indirect call that looks like a coroutine resume (frame[+0])?
static bool isRawCoroResume(CallBase *CB, const DataLayout &DL) {
    if (!CB->isIndirectCall() || CB->arg_size() != 1) return false;
    Value *Callee = CB->getCalledOperand()->stripPointerCasts();
    auto *Load = dyn_cast<LoadInst>(Callee);
    if (!Load) return false;
    APInt Off(64, 0);
    Value *Base = Load->getPointerOperand()
                     ->stripAndAccumulateConstantOffsets(DL, Off, true);
    return Off.getZExtValue() == 0 &&
           Base->stripPointerCasts() == CB->getArgOperand(0)->stripPointerCasts();
}

static bool isRawCoroDestroy(CallBase *CB, const DataLayout &DL) {
    if (!CB->isIndirectCall() || CB->arg_size() != 1) return false;
    Value *Callee = CB->getCalledOperand()->stripPointerCasts();
    auto *Load = dyn_cast<LoadInst>(Callee);
    if (!Load) return false;
    APInt Off(64, 0);
    Value *Base = Load->getPointerOperand()
                     ->stripAndAccumulateConstantOffsets(DL, Off, true);
    return Off.getZExtValue() == 8 &&
           Base->stripPointerCasts() == CB->getArgOperand(0)->stripPointerCasts();
}

PreservedAnalyses CoroShadowPass::run(Module &M, ModuleAnalysisManager &) {
    LLVMContext &Ctx = M.getContext();
    auto *VoidTy = Type::getVoidTy(Ctx);
    auto *PtrTy  = PointerType::getUnqual(Ctx);

    // Declare (or find) the runtime functions.
    // They are defined in libcoroshadow.a and linked in at link time.
    auto *FTy1 = FunctionType::get(VoidTy, {PtrTy}, false);
    FunctionCallee RegFn =
        M.getOrInsertFunction("__coro_shadow_register", FTy1);
    FunctionCallee VerifyResumeFn =
        M.getOrInsertFunction("__coro_shadow_verify_resume", FTy1);
    FunctionCallee VerifyDestroyFn =
        M.getOrInsertFunction("__coro_shadow_verify_and_remove_destroy", FTy1);

    const DataLayout &DL = M.getDataLayout();
    CoroDefenseAnalysis A;
    bool HasCoros = A.run(M);

    // ── 1. Inject __coro_shadow_register in creation stubs ──────────────────
    // Strategy: find the store of the resume function pointer in each ramp.
    //           Insert the register call right after it.
    if (HasCoros) {
        for (auto &Rec : A.Types) {
            if (!Rec.RampFn) continue;
            Instruction *InsertAfter = nullptr;
            Value *FrameBase = nullptr;

            for (BasicBlock &BB : *Rec.RampFn) {
                for (Instruction &I : BB) {
                    auto *SI = dyn_cast<StoreInst>(&I);
                    if (!SI) continue;
                    if (SI->getValueOperand()->stripPointerCasts()
                            != Rec.ResumeFn) continue;
                    Value *Dst = SI->getPointerOperand();
                    FrameBase = dyn_cast<GetElementPtrInst>(Dst)
                        ? cast<GetElementPtrInst>(Dst)->getPointerOperand()
                        : Dst;
                    InsertAfter = &I;
                    break;
                }
                if (InsertAfter) break;
            }
            if (!InsertAfter || !FrameBase) continue;

            IRBuilder<> B(InsertAfter->getNextNode());
            B.CreateCall(RegFn, {FrameBase});
        }
    }

    // ── 2. Inject verify calls before every resume/destroy call site ────────
    for (Function &F : M) {
        if (F.getName().starts_with("__coro_")) continue;

        for (BasicBlock &BB : F) {
            // Collect first to avoid iterator invalidation.
            SmallVector<std::pair<CallBase*, bool>, 8> ToInstrument;

            for (Instruction &I : BB) {
                auto *CB = dyn_cast<CallBase>(&I);
                if (!CB) continue;

                bool IsResume  = isCallTo(CB, "__coro_dispatch_resume")
                              || isRawCoroResume(CB, DL);
                bool IsDestroy = isCallTo(CB, "__coro_dispatch_destroy")
                              || isRawCoroDestroy(CB, DL);
                if (!IsResume && !IsDestroy) continue;

                ToInstrument.push_back({CB, IsResume});
            }

            for (auto [CB, IsResume] : ToInstrument) {
                Value *FramePtr = CB->getArgOperand(0);
                IRBuilder<> B(CB);     // insert BEFORE the call
                if (IsResume)
                    B.CreateCall(VerifyResumeFn, {FramePtr});
                else
                    // verify_and_remove: must happen before the real destroy
                    B.CreateCall(VerifyDestroyFn, {FramePtr});
            }
        }
    }

    return PreservedAnalyses::none();
}
