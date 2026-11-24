# coro-defense

Coroutine Frame-Oriented Programming (CFOP): a testbench of attacks against
C++20 coroutine frames, plus two compiler/runtime defenses implemented as
LLVM passes — a **Coroutine-Aware CFI** (read-only, type-keyed dispatch
table) and a **whole-frame MPK Shadow Stack**.

This project follows on from, and empirically reproduces, the finding of
*"Await() a Second: Evading Control Flow Integrity by Hijacking C++
Coroutines"*: the `resume`/`destroy` function pointers that drive a C++20
coroutine live in a writable heap object (the coroutine frame) and are
called through a compiler-synthesized indirect call that mainstream
forward-edge CFI and Intel CET do not instrument.

This README covers **setup, repo structure, and how to build and run
everything**.

---

## Table of contents

1. [Repo structure](#repo-structure)
2. [Prerequisites](#prerequisites)
3. [Step 1 — build a patched clang/LLVM](#step-1--build-a-patched-clangllvm)
4. [Step 2 — build the LLVM pass plugin](#step-2--build-the-llvm-pass-plugin)
5. [Step 3 — build the shadow-stack runtime](#step-3--build-the-shadow-stack-runtime)
6. [Step 4 — build and run the attack testbench](#step-4--build-and-run-the-attack-testbench)
7. [Step 5 — measure defense overhead](#step-5--measure-defense-overhead)
8. [The LLVM patch, in detail](#the-llvm-patch-in-detail)
9. [Overriding toolchain paths](#overriding-toolchain-paths)
10. [Troubleshooting](#troubleshooting)

---

## Repo structure

```
coro-defense/
├── README.md                       # you are here
├── llvm-coro-typeid-offset.patch   # the one compiler change this project needs
├── patches/                        # reserved for any further compiler patches (currently empty)
│
├── passes/                         # the LLVM analysis + transform passes (one plugin .so)
│   ├── CMakeLists.txt
│   ├── CoroDefenseAnalysis.{h,cpp} #   shared discovery: coroutine types + resume/destroy call sites
│   ├── CoroAwareCFIPass.{h,cpp}    #   Defense A: read-only dispatch-table CFI
│   ├── CoroShadowPass.{h,cpp}      #   Defense B: whole-frame shadow-stack instrumentation
│   ├── AnalysisPlugin.cpp          #   plugin registration (`-fpass-plugin=...` / `opt -load-pass-plugin=...`)
│   └── build/                      #   (generated) CoroDefensePlugin.so
│
├── runtime/                        # the shadow-stack's runtime support library
│   ├── CMakeLists.txt
│   ├── CoroShadowRuntime.c         #   register/update/verify + MPK (or mprotect) protection
│   └── build/                      #   (generated) libcoroshadow.a
│
├── test/                           # the attack testbench + build system for every victim
│   ├── Makefile                    #   top-level dispatcher: `all` / `variants` / `matrix` / `clean`
│   ├── common.mk                   #   shared build rules included by every benchmark's Makefile
│   ├── run_matrix.sh               #   runs every primitive against every defense, prints the table
│   ├── measuring_overhead.sh       #   perf-stat based overhead measurement (see §7)
│   ├── common/cfop_common.h        #   shared `Task` coroutine type + `hijack_target()`
│   ├── overflow/                   #   Primitive 1: heap overflow into an adjacent frame (:4445)
│   ├── uaf/                        #   Primitive 2: use-after-free reclaim (in-process)
│   ├── scheduler/                  #   Primitive 3: dangling handle in a scheduler queue (:4446)
│   ├── dataonly/                   #   Primitive 5: data-only `is_admin` flip, no pointer touched (:4447)
│   ├── fakeframe/                  #   Primitive 4: fake-frame injection via a corrupted handle (:4448)
│   └── measuring_overhead/         #   microbenchmark used by §7
```

Every victim in `test/` is compiled into **six build variants** from the one
source file (`<stem>`, `<stem>_cfibaseline`, `<stem>_cet`, `<stem>_cfi`,
`<stem>_shadow`, `<stem>_both`) — see [common.mk](test/common.mk) and
§4 below.

---

## Prerequisites

- **Linux, x86-64**, with `git`, `cmake` (≥ 3.20), `ninja` (or `make`), and a
  working host C/C++ toolchain to bootstrap LLVM itself.
- **~15–20 GB free disk** and a few cores/RAM to spare — you are building
  LLVM/clang/lld from source.
- **`lld`** — required for the `cfibaseline` variant
  (`-fsanitize=cfi-icall -fuse-ld=lld`); it's built as part of the patched
  LLVM checkout below, no separate install needed.
- **`perf`** (`linux-tools-common` / `linux-tools-$(uname -r)`) — only needed
  for §7 (overhead measurement); everything else works without it.
- Optional: a CPU with **Intel MPK** (`pkey_alloc` support) for the shadow
  stack's cheap page-protection toggling, and/or a CPU with **Intel CET**
  (Tiger Lake+/Zen 3+) if you want the `cet` variant to be hardware-enforced
  rather than merely compiled-in. Neither is required: the shadow-stack
  runtime falls back to plain `mprotect` if MPK is unavailable, and the
  `cet` variant still builds and demonstrates the same CFI-blind-spot result
  either way (see the attack-matrix results from `make matrix`).

All paths below assume a `~/workspace/` layout, matching the defaults baked
into [test/common.mk](test/common.mk) and [passes/CMakeLists.txt](passes/CMakeLists.txt);
see [§9](#overriding-toolchain-paths) if you want different paths.

---

## Step 1 — build a patched clang/LLVM

This project needs exactly **one** upstream LLVM/clang source change: a
2-file patch to the coroutine-lowering passes that reserves a per-coroutine
**TypeID** slot in every coroutine frame (see
[§8](#the-llvm-patch-in-detail) for what it does and why). Everything else
(the defenses themselves) is an out-of-tree pass plugin loaded with
`-fpass-plugin=`/`opt -load-pass-plugin=`, so it does **not** need to be
compiled into clang.

```bash
mkdir -p ~/workspace && cd ~/workspace
git clone https://github.com/llvm/llvm-project.git
cd llvm-project
git checkout llvmorg-18.1.8          # the version this project is validated against
git apply ~/workspace/coro-defense/llvm-coro-typeid-offset.patch
```

Configure and build (enable `clang` and `lld`; assertions on is recommended
while developing/debugging the passes):

```bash
cmake -G Ninja -S llvm -B ~/workspace/llvm-build \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DCMAKE_INSTALL_PREFIX=~/workspace/llvm-install

ninja -C ~/workspace/llvm-build
ninja -C ~/workspace/llvm-build install
```

This is a full LLVM build and will take a while (expect on the order of an
hour or more depending on your machine). When it's done you should have:

- `~/workspace/llvm-build/bin/clang++` and `.../bin/opt` — the patched
  compiler and optimizer the test benchmarks compile with.
- `~/workspace/llvm-install/lib/cmake/llvm/LLVMConfig.cmake` — the installed
  CMake package the pass plugin (`passes/`) configures against.

Sanity-check the patch took effect (the frame should now carry an extra
`i32` after the two header pointers):

```bash
cat > /tmp/t.cpp <<'EOF'
#include "coroutine"
struct Task { struct promise_type {
  Task get_return_object(){return{};} std::suspend_never initial_suspend(){return{};}
  std::suspend_never final_suspend()noexcept{return{};} void return_void(){} void unhandled_exception(){}
};};
Task f(){ co_return; }
EOF
~/workspace/llvm-build/bin/clang++ -std=c++20 -O1 -fno-inline -S -emit-llvm /tmp/t.cpp -o - \
  | grep 'Frame = type'
```

---

## Step 2 — build the LLVM pass plugin

```bash
cd ~/workspace/coro-defense/passes
cmake -G Ninja -B build .
ninja -C build
```

This produces `passes/build/CoroDefensePlugin.so`, containing all three
passes registered from one plugin ([passes/AnalysisPlugin.cpp](passes/AnalysisPlugin.cpp)):

- `CoroDefenseAnalysis` — shared discovery (coroutine types + resume/destroy
  call sites); not a transform, both defenses call it first.
- `coro-aware-cfi` (`CoroAwareCFIPass`) — registered on LLVM's
  **OptimizerLast** extension point, so it runs automatically on any `-O1+`
  build that loads the plugin with `-fpass-plugin=`.
- `coro-shadow-analysis` (`CoroShadowPass`) — addressable only through the
  `opt` pipeline parser (`-passes=coro-shadow-analysis`), not auto-inserted,
  which is why the shadow/both build variants go source → IR → `opt` → link,
  rather than a single `clang++ -fpass-plugin=...` invocation (see
  [test/common.mk](test/common.mk)).

If `cmake` can't find LLVM, double check Step 1's `ninja install` actually
ran and that `~/workspace/llvm-install/lib/cmake/llvm` exists (see
[passes/CMakeLists.txt](passes/CMakeLists.txt), which points there explicitly).

---

## Step 3 — build the shadow-stack runtime

```bash
cd ~/workspace/coro-defense/runtime
cmake -G Ninja -B build .
ninja -C build
```

This produces `runtime/build/libcoroshadow.a` — the `__coro_shadow_register`
/ `_update` / `_verify_resume` / `_verify_and_remove_destroy` entry points
the `CoroShadowPass` instrumentation calls into, backed by an MPK- (or
`mprotect`-) protected snapshot table (see
[runtime/CoroShadowRuntime.c](runtime/CoroShadowRuntime.c)).

---

## Step 4 — build and run the attack testbench

Everything under `test/` is driven by one include file,
[test/common.mk](test/common.mk), which every benchmark's own `Makefile`
pulls in. From `test/`:

```bash
cd ~/workspace/coro-defense/test

make                 # build the vulnerable victim(s) + attacker(s) in every folder
make variants        # build all 6 variants (vuln/cfibaseline/cet/cfi/shadow/both) everywhere
make matrix          # build variants, then run run_matrix.sh and print the attack x defense table
make clean           # clean every folder
```

Or work on one benchmark at a time:

```bash
make -C overflow all       # just this benchmark's vulnerable build
make -C overflow variants  # all 6 variants of overflow_victim
make -C overflow run       # build + run the standalone demo
```

Each victim is a standalone TCP server (ports are fixed per benchmark — see
the table in the repo-structure tree above) except `uaf/`, which runs
in-process because its corruption window (between `destroy()` and the next
matching-size allocation) is too narrow to reliably drive over a socket.
A typical manual run looks like:

```bash
./overflow/overflow_victim &          # vulnerable variant
./overflow/overflow_attacker          # drives the exploit over 127.0.0.1:4445
# -> prints "HIJACK_TARGET executing inside victim PID ..."

./overflow/overflow_victim_shadow &   # same bug, shadow-stack build
./overflow/overflow_attacker
# -> victim prints "[CoroShadow] ATTACK: resume_fn tampered ..." and aborts
```

`make matrix` automates exactly this across all five realistic primitives
and all six build variants and prints the resulting attack x defense table.

---

## Step 5 — measure defense overhead

```bash
cd ~/workspace/coro-defense/test
make measuring_overhead     # == ./measuring_overhead.sh
```

This builds the `measuring_overhead/` microbenchmark in all six variants and
uses `perf stat` hardware counters (instructions/cycles) with a delta
method (running at N and 2N iterations and subtracting) to isolate
per-operation cost for "create once, resume N times" and "create, resume,
destroy, N times", for coro-CFI, the shadow stack, and both together. See
[test/measuring_overhead.sh](test/measuring_overhead.sh) for the exact
methodology.

---

## The LLVM patch, in detail

[`llvm-coro-typeid-offset.patch`](llvm-coro-typeid-offset.patch) touches two
files in `llvm/lib/Transforms/Coroutines/`:

- **`CoroFrame.cpp`** (`buildFrameType`) — reserves one additional 4-byte
  `i32` **header** field, placed immediately after the existing
  `resume`/`destroy` function-pointer fields (i.e. at a **fixed offset of
  16**, the same for every coroutine type regardless of its promise's
  size). This is the **TypeID** slot `CoroAwareCFIPass` later populates and
  reads. Because this lives in the compiler, **every** frame our clang builds gets
  the slot; it is simply left at `0` unless a defense pass fills it in,
  which is what lets the vulnerable, CFI, shadow, and both build variants
  all share one identical frame layout — the only thing that differs
  between them is which pass(es), if any, were loaded.

- **`CoroEarly.cpp`** (`lowerCoroPromise`) — this early-lowering pass
  computes the address of a coroutine's promise object for every
  `coroutine_handle::from_promise()` / `.promise()` call against a
  **hardcoded mock frame layout**. Originally that mock layout was
  `{ptr, ptr, i8}` (promise at a fixed offset of 16); the patch changes it
  to `{ptr, ptr, i32, i8}` to account for the TypeID field now sitting
  between the header pointers and the promise, so the promise's computed
  offset shifts to 20 (or 24, with alignment padding) and stays consistent
  with the real frame `CoroFrame.cpp` now builds. **Both files must stay in
  sync** — this is exactly the ABI constraint the comments in both hunks
  call out: nothing may be inserted into the frame without updating
  whichever other pass assumes a fixed offset for what comes after it.

No other LLVM/clang source is modified. The defenses themselves
(`CoroAwareCFIPass`, `CoroShadowPass`) are ordinary out-of-tree pass-plugin
code in `passes/`, loaded at compile time — they do not require rebuilding
LLVM to iterate on.

---

## Overriding toolchain paths

If your LLVM checkout/build/install don't live at the `~/workspace/...`
defaults, override the relevant variables rather than editing the Makefiles:

```bash
# passes/: point at your installed LLVMConfig.cmake
cmake -G Ninja -B build . -DLLVM_DIR=/path/to/llvm-install/lib/cmake/llvm

# test/: override on the make command line (or export as env vars)
make -C test variants \
  DEFCLANG=/path/to/llvm-build/bin/clang++ \
  OPT=/path/to/llvm-build/bin/opt \
  PLUGIN=/path/to/coro-defense/passes/build/CoroDefensePlugin.so \
  RUNTIME=/path/to/coro-defense/runtime/build
```

See the top of [test/common.mk](test/common.mk) for the full list of
`?=`-overridable variables (`DEFCLANG`, `OPT`, `CXX`, `PLUGIN`, `RUNTIME`,
`CXXFLAGS`, `VICTIM_FLAGS`, `ATTACKER_FLAGS`, `CFI_BASELINE_FLAGS`,
`CET_FLAGS`).

---

## Troubleshooting

- **`passes/` CMake can't find LLVM.** Confirm Step 1's `ninja install`
  completed and `~/workspace/llvm-install/lib/cmake/llvm/LLVMConfig.cmake`
  exists; pass `-DLLVM_DIR=...` explicitly if you installed elsewhere.
- **`_cfibaseline` variant fails to link.** It needs `lld`
  (`-fuse-ld=lld`); make sure `lld` was in `LLVM_ENABLE_PROJECTS` in Step 1
  and that `ld.lld` is on `PATH` or resolvable next to your patched clang.
- **Shadow-stack variant prints "mprotect fallback" instead of MPK.** Your
  CPU/kernel doesn't support Intel MPK (`pkey_alloc`); this is expected and
  harmless — the runtime degrades gracefully to `mprotect`-based protection.
- **`cet` variant doesn't actually get caught enforcing anything.** Intel
  CET (IBT/shadow stack) is only *hardware*-enforced on CPUs ≥ Tiger
  Lake/Zen 3 with kernel ≥ 6.6 and glibc ≥ 2.39; on older hardware the
  variant still builds with the CET ELF properties and `endbr64` landing
  pads present (compiled-in), but nothing enforces them at runtime. The
  expected result (CET does not stop the coroutine-resume hijack) holds
  either way.
- **`make matrix` / `run_matrix.sh` reports `MISSING`.** Run `make variants`
  first; the matrix script only runs binaries that already exist.
- **Port already in use (`:4444`–`:4448`).** A previous victim server is
  still running; `run_matrix.sh` already `pkill`s by binary name before each
  run, but if you're driving a benchmark by hand, kill the old server first.
