// CoroDefenseAnalysis.cpp
#include "CoroDefenseAnalysis.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "coro-defense-analysis"

using namespace llvm;

bool CoroDefenseAnalysis::run(Module &M) {
    discoverTypes(M);
    if (Types.empty())
        return false;
    discoverCallSites(M);
    return true;
}

void CoroDefenseAnalysis::discoverTypes(Module &M) {
    // After CoroSplit, every coroutine produces functions named:
    //   <mangled_base>.resume
    //   <mangled_base>.destroy
    // We scan all functions, group by base name, and assign TypeIDs.

    StringMap<CoroTypeRecord *> ByBase;
    uint32_t NextID = 1; // 0 is reserved for noop_coroutine

    for (Function &F : M) {
        StringRef Name = F.getName();
        bool IsResume = Name.ends_with(".resume");
        bool IsDestroy = Name.ends_with(".destroy");
        if (!IsResume && !IsDestroy)
            continue;

        StringRef Base = IsResume ? Name.drop_back(7) : Name.drop_back(8);

        auto [It, Inserted] = ByBase.try_emplace(Base, nullptr);
        if (Inserted) {
            Types.push_back({});
            It->second = &Types.back();
            It->second->TypeID = NextID++;
            It->second->RampFn = M.getFunction(Base);
        }
        if (IsResume)
            It->second->ResumeFn = &F;
        else
            It->second->DestroyFn = &F;
    }

    // Extract the frame struct type from each resume stub's body.
    for (auto &Rec : Types)
        extractFrameType(Rec);

    LLVM_DEBUG(dbgs() << "[CoroDefense] Found " << Types.size()
                      << " coroutine types\n";
               for (auto &R
                    : Types) dbgs()
               << "  TypeID=" << R.TypeID << "  "
               << (R.RampFn ? R.RampFn->getName() : "<no ramp>") << "\n");
}

void CoroDefenseAnalysis::extractFrameType(CoroTypeRecord &Rec) {
    if (!Rec.ResumeFn || Rec.ResumeFn->arg_empty())
        return;

    // The resume stub's first argument is a pointer to the frame.
    // Walk GEP instructions in the entry block to find the struct type.
    for (auto &I : Rec.ResumeFn->getEntryBlock()) {
        auto *GEP = dyn_cast<GetElementPtrInst>(&I);
        if (!GEP)
            continue;
        auto *ST = dyn_cast<StructType>(GEP->getSourceElementType());
        if (!ST)
            continue;
        // The frame struct has at least 2 fields (resume_fn, destroy_fn).
        if (ST->getNumElements() < 2)
            continue;
        Rec.FrameTy = ST;
        return;
    }
}

void CoroDefenseAnalysis::discoverCallSites(Module &M) {
    const DataLayout &DL = M.getDataLayout();

    for (Function &F : M) {
        // Skip our own emitted dispatch functions.
        if (F.getName().starts_with("__coro_dispatch_"))
            continue;
        // Skip the resume/destroy stubs themselves.
        if (F.getName().ends_with(".resume"))
            continue;
        if (F.getName().ends_with(".destroy"))
            continue;

        for (BasicBlock &BB : F) {
            for (Instruction &I : BB) {
                auto *CB = dyn_cast<CallBase>(&I);
                if (!CB || !CB->isIndirectCall())
                    continue;

                // Coroutine resume/destroy calls have exactly one argument:
                // the frame pointer.
                if (CB->arg_size() != 1)
                    continue;
                Value *Arg = CB->getArgOperand(0);
                if (!Arg->getType()->isPointerTy())
                    continue;

                // The callee must be a value loaded from memory.
                Value *Callee = CB->getCalledOperand()->stripPointerCasts();
                auto *Load = dyn_cast<LoadInst>(Callee);
                if (!Load)
                    continue;

                // Accumulate the byte offset of the load from the base
                // pointer.
                APInt Offset(64, 0);
                Value *Base = Load->getPointerOperand()
                                  ->stripAndAccumulateConstantOffsets(
                                      DL, Offset, /*AllowNonInbounds=*/true);

                // The call argument must be the same base pointer
                // (stripped of casts).
                if (Base->stripPointerCasts() != Arg->stripPointerCasts())
                    continue;

                uint64_t Off = Offset.getZExtValue();
                if (Off == 0) {
                    CallSites.push_back({CB, Arg, /*IsResume=*/true});
                } else if (Off == 8) {
                    CallSites.push_back({CB, Arg, /*IsResume=*/false});
                }
            }
        }
    }

    LLVM_DEBUG(dbgs() << "[CoroDefense] Found " << CallSites.size()
                      << " coroutine call sites\n");
}