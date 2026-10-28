// CoroDefenseAnalysis.h
#pragma once
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/ADT/StringMap.h"
#include <cstdint>
#include <vector>

namespace llvm {

// One entry per distinct coroutine type (one .resume/.destroy pair).
struct CoroTypeRecord {
    Function    *ResumeFn    = nullptr;  // e.g. _ZL11worker_coroi.resume
    Function    *DestroyFn   = nullptr;  // e.g. _ZL11worker_coroi.destroy
    Function    *RampFn      = nullptr;  // e.g. _ZL11worker_coroi (creation stub)
    StructType  *FrameTy     = nullptr;  // the frame struct type
    uint32_t     TypeID      = 0;        // 1-based; 0 reserved for noop_coroutine
};

// One entry per indirect call that resume()s or destroy()s a coroutine.
// These are the call sites CFOP hijacks.
struct CoroCallSite {
    CallBase *Call      = nullptr;  // the call or invoke instruction
    Value    *FramePtr  = nullptr;  // the coroutine frame pointer (call arg 0)
    bool      IsResume  = false;    // true=resume, false=destroy
};

// Run this analysis before modifying anything.
struct CoroDefenseAnalysis {
    std::vector<CoroTypeRecord> Types;
    std::vector<CoroCallSite>   CallSites;

    // Populate Types and CallSites by scanning M.
    // Returns false if no coroutines were found.
    bool run(Module &M);

private:
    void discoverTypes(Module &M);
    void discoverCallSites(Module &M);
    void extractFrameType(CoroTypeRecord &Rec);
};

} // namespace llvm