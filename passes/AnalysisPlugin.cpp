// AnalysisPlugin.cpp — standalone opt plugin
#include "CoroAwareCFIPass.h"
#include "CoroDefenseAnalysis.h"
#include "CoroShadowPass.h"

#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

struct CoroAnalysisPrinterPass
    : public PassInfoMixin<CoroAnalysisPrinterPass> {
    PreservedAnalyses run(Module &M, ModuleAnalysisManager &) {
        CoroDefenseAnalysis A;
        if (!A.run(M)) {
            errs() << "[CoroDefense] No coroutines found in module.\n";
            return PreservedAnalyses::all();
        }
        errs() << "[CoroDefense] Types found:\n";
        for (auto &R : A.Types) {
            errs() << "  TypeID=" << R.TypeID
                   << "  ramp=" << (R.RampFn ? R.RampFn->getName() : "?")
                   << "  resume=" << (R.ResumeFn ? R.ResumeFn->getName() : "?")
                   << "  destroy="
                   << (R.DestroyFn ? R.DestroyFn->getName() : "?") << "\n";
        }
        errs() << "[CoroDefense] Call sites found: " << A.CallSites.size()
               << "\n";
        for (auto &S : A.CallSites) {
            errs() << "  " << (S.IsResume ? "RESUME " : "DESTROY") << "  in "
                   << S.Call->getFunction()->getName() << "\n";
        }
        return PreservedAnalyses::all();
    }
};

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
    return {
        LLVM_PLUGIN_API_VERSION, "CoroDefense", "0.1", [](PassBuilder &PB) {
            // ── Explicit pipeline use ──────────────────────────────────────
            // Lets you run:  opt --load-pass-plugin=...
            // --passes="coro-aware-cfi"
            PB.registerPipelineParsingCallback(
                [](StringRef Name,
                   ModulePassManager &MPM,
                   ArrayRef<PassBuilder::PipelineElement>) -> bool {
                    if (Name == "coro-aware-cfi") {
                        MPM.addPass(CoroAwareCFIPass());
                        return true;
                    }
                    if (Name == "coro-defense-analysis") {
                        MPM.addPass(CoroAnalysisPrinterPass());
                        return true;
                    }
                    if (Name == "coro-shadow-analysis") {
                        MPM.addPass(CoroShadowPass());
                        return true;
                    }
                    return false;
                });

            // ── Automatic insertion into clang's default pipeline ──────────
            // Fires after ALL standard passes including the four coroutine
            // lowering passes (coro-early → coro-split → coro-elide →
            // coro-cleanup).  By this point the frame structs exist, the
            // resume/destroy stubs are real functions, and all indirect call
            // sites are visible — exactly what CoroAwareCFIPass needs.
            PB.registerOptimizerLastEPCallback(
                [](ModulePassManager &MPM, OptimizationLevel OL) {
                    // Skip -O0: coroutine lowering behaves differently and
                    // the frame layout we depend on may not be present.
                    if (OL == OptimizationLevel::O0)
                        return;
                    MPM.addPass(CoroAwareCFIPass());
                });
        }};
}