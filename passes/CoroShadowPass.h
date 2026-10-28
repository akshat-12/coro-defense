#pragma once

#include "llvm/IR/PassManager.h"

namespace llvm {

struct CoroShadowPass : public PassInfoMixin<CoroShadowPass> {
    PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};

} // namespace llvm