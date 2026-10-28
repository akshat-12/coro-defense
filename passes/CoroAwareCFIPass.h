// CoroAwareCFIPass.h
#pragma once
#include "llvm/IR/PassManager.h"

namespace llvm {

struct CoroAwareCFIPass : public PassInfoMixin<CoroAwareCFIPass> {
    PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};

} // namespace llvm