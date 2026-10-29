# Coroutine Frame-Oriented Programming (CFOP): Attacks and Defenses

A technical report on C++20 coroutines as a control-flow-hijacking surface, the
attacks we built to demonstrate it, and two compiler/runtime defenses
(Coroutine-Aware CFI and a whole-frame MPK Shadow Stack) implemented as LLVM
passes.

> **Scope & provenance.** The coroutine, memory-layout, and LLVM-internals
> sections describe clang/LLVM **18.1.8** (the version this project builds
> against). The section on *"Await() a Second: Evading Control Flow Integrity by
> Hijacking C++ Coroutines"* is our **synthesis of the paper's thesis**; exact
> experimental numbers, the formal threat model, and the full citation should be
> taken from the paper itself (fill in the citation block at the end). Code
> references use `path:line` into this repository.

---

## Table of contents

1. [C++20 coroutines in one page](#1-c20-coroutines-in-one-page)
2. [The coroutine frame: layout in memory](#2-the-coroutine-frame-layout-in-memory)
3. [How LLVM compiles coroutines](#3-how-llvm-compiles-coroutines)
4. [*Await() a Second*: the CFOP finding](#4-await-a-second-the-cfop-finding)
5. [Our attack benchmarks](#5-our-attack-benchmarks)
6. [Our defenses](#6-our-defenses)
7. [Evaluation: the attack × defense matrix](#7-evaluation-the-attack--defense-matrix)
8. [Limitations and future work](#8-limitations-and-future-work)
9. [Build & run](#9-build--run)
10. [References](#10-references)

---

## 1. C++20 coroutines in one page

A **coroutine** is a function that can *suspend* execution and *resume* later,
preserving its local state across the suspension. C++20 makes any function a
coroutine if its body uses `co_await`, `co_yield`, or `co_return`.

C++ coroutines are **stackless**: unlike a thread or a fiber, a suspended
coroutine does *not* keep a separate call stack. Instead, everything it needs to
resume — its local variables that are live across a suspend point, a resume
index saying "where to continue", and bookkeeping — is stored in a single
heap-allocated object called the **coroutine frame**. Suspension unwinds the
machine stack normally and returns control to the caller; resumption re-enters
the coroutine body using the frame.

Three pieces of machinery define a coroutine type:

- **The promise type.** For a return type `T`, the compiler looks up
  `T::promise_type`. The promise is an object *embedded in the frame* that
  customizes behavior: `initial_suspend()`/`final_suspend()` (whether to suspend
  before the first line and after `co_return`), `get_return_object()`,
  `return_value()`/`return_void()`, `unhandled_exception()`, and the awaiter for
  `co_yield`.
- **`std::coroutine_handle<P>`.** A thin wrapper around a single pointer — the
  frame address. It exposes `resume()`, `destroy()`, `done()`, `address()`, and
  (via the promise) `from_promise()`/`promise()`. **This is the capability that
  drives a suspended coroutine**, and it is exactly what an attacker wants to
  point at a frame they control.
- **Awaitables / awaiters.** `co_await expr` consults `expr`'s
  `await_ready/await_suspend/await_resume` to decide whether to suspend and what
  to do on resume.

A minimal "eager-suspend" task type (the one our benchmarks use,
[test/common/cfop_common.h](../test/common/cfop_common.h)):

```cpp
struct Task {
    struct promise_type {
        Task get_return_object() noexcept {
            return Task{std::coroutine_handle<promise_type>::from_promise(*this)};
        }
        std::suspend_always initial_suspend() noexcept { return {}; }
        std::suspend_always final_suspend()   noexcept { return {}; }
        void return_void()                    noexcept {}
        void unhandled_exception()            noexcept { std::terminate(); }
    };
    std::coroutine_handle<promise_type> handle;   // the only data member: a pointer
    // ... move-only ownership wrapper that destroy()s the frame in its dtor ...
};
```

Because `initial_suspend()` returns `suspend_always`, calling the coroutine
**allocates the frame and returns immediately, parked before the first line**.
The caller then drives it with `handle.resume()`. `final_suspend()` returning
`suspend_always` means the frame is **not** freed when the body finishes — it
stays alive (parked at the final suspend) until someone calls `destroy()`. Both
facts matter for the attacks below.

---

## 2. The coroutine frame: layout in memory

When a coroutine is called, the compiler emits code that computes the frame
size, calls `operator new` to allocate it on the heap, stores the initial
bookkeeping, runs the body up to the first suspend, and returns the handle. The
frame is a compiler-generated struct. For clang's **Switch-lowering ABI** (the
default), its header is laid out at fixed offsets:

```
            coroutine frame (heap)
          +---------------------------+  offset 0
          |  resume  fn ptr  (8 bytes)|  --> called by handle.resume()
          +---------------------------+  offset 8
          |  destroy fn ptr  (8 bytes)|  --> called by handle.destroy()
          +---------------------------+  offset 16
          |  promise object           |  --> ABI-fixed offset (see §3)
          +---------------------------+  (+ promise size, here empty)
          |  [TypeID i32]  (our add)  |  offset 20 — present only in our builds
          +---------------------------+
          |  suspend/resume index     |  which suspend point to resume at
          +---------------------------+
          |  spilled locals           |  e.g. `is_admin`, loop counters, …
          +---------------------------+
```

Key properties that make this a *control structure*, not just data:

- **`frame[0]` and `frame[8]` are function pointers that get called
  indirectly.** `handle.resume()` lowers to, in effect,
  `(*(void(**)(void*))frame)(frame)` — load the resume pointer out of the
  (writable, heap) frame and call it. `destroy()` is the same through
  `frame[8]`. There is no type check on that call beyond what the generic CFI
  mechanisms provide (see §4).
- **The frame is long-lived and attacker-adjacent.** A suspended coroutine's
  frame sits on the heap across an `await` — potentially for the entire lifetime
  of a request, or while queued in an async scheduler. Unlike an ephemeral stack
  frame, it is a durable, reusable target. This temporal property is central to
  the UAF and scheduler attacks (§5).
- **The frame legitimately mutates between resumes.** The resume index and any
  spilled locals change each time the coroutine advances. A defense that
  snapshots the frame must account for this (see the Shadow Stack, §6).

The `resume`/`destroy` pointers do **not** change across legitimate resumes: in
the Switch ABI they always point at the coroutine's single `.resume`/`.destroy`
stub, and the *index* field selects where execution continues. That stability is
what lets a pointer-only shadow be meaningful — and what the whole-frame shadow
extends.

---

## 3. How LLVM compiles coroutines

Clang front-end emits a coroutine as ordinary IR sprinkled with **coroutine
intrinsics** (`llvm.coro.id`, `llvm.coro.begin`, `llvm.coro.size`,
`llvm.coro.suspend`, `llvm.coro.save`, `llvm.coro.promise`, `llvm.coro.free`,
`llvm.coro.end`, …). A sequence of mid-end passes then turns that into the
frame + state-machine functions. In the LLVM 18 new pass manager the relevant
passes run in this order:

1. **CoroEarly** (`CoroEarly.cpp`) — an early function pass that lowers some
   intrinsics into their concrete form before optimization. Notably it lowers
   `llvm.coro.promise` (the backing of `coroutine_handle::from_promise`/
   `.promise`/`.address`). **It does so against a hardcoded mock layout**
   `StructType{ptr, ptr, i8}`, so it computes the promise at **offset 16**
   unconditionally:
   ```cpp
   // CoroEarly.cpp::lowerCoroPromise (paraphrased)
   auto *FrameTy = StructType::get(Context, {AnyResumeFnPtrTy, AnyResumeFnPtrTy, Int8Ty});
   Value *promise = ... getelementptr FrameTy, frame, 0, 2 ...;   // offset 16
   ```
   **This is the ABI constraint that governs both our frame change and the
   defenses:** nothing may be inserted *before* the promise, or every
   `from_promise()`/`.address()` computation is wrong and the program segfaults
   on resume. Any per-frame metadata we add must go *after* the promise.

2. **CoroSplit** (`CoroSplit.cpp` + `CoroFrame.cpp`) — the heavy, module/CGSCC
   pass. It:
   - **builds the frame struct** (`CoroFrame.cpp`, `FrameTypeBuilder`): header
     fields (resume ptr, destroy ptr, promise, resume index) get fixed
     sequential offsets; values that are *live across a suspend point* are
     "spilled" into additional frame fields placed by
     `performOptimizedStructLayout`;
   - **splits** the coroutine into several functions: the **ramp** (the original
     function up to the first suspend — allocates the frame, initializes the
     header, runs the prologue, returns the handle), plus `<base>.resume`,
     `<base>.destroy`, and `<base>.cleanup` stubs that implement the resume /
     destroy / cleanup state machines keyed on the index field.
   - Our one compiler change lives here: we add an `i32` **TypeID** as a *header*
     field placed **after** the promise (so the promise keeps offset 16), giving
     the TypeID a stable slot (offset 20 for an empty promise). See §6.

3. **CoroElide** (`CoroElide.cpp`) — Heap-Allocation eLision Optimization
   (HALO). If the compiler can prove a coroutine's frame does not outlive its
   caller, it elides the `operator new` and places the frame in the caller's
   stack frame. We **disable this** in all benchmark builds with `-fno-inline`
   (and build at `-O1`) so frames stay on the heap, where a memory-corruption
   primitive can reach them — matching the deployed-server threat model.

4. **CoroCleanup** (`CoroCleanup.cpp`) — lowers any remaining coroutine
   intrinsics to their final form and tidies up.

After these passes, from the outside a coroutine is just: a ramp function, three
stub functions, and a heap struct whose first two words are the
resume/destroy pointers. Our analysis pass (§6) recovers exactly that structure
from the post-split IR.

---

## 4. *Await() a Second*: the CFOP finding

*"Await() a Second: Evading Control Flow Integrity by Hijacking C++
Coroutines"* observes that the coroutine frame is a **control structure that
standard control-flow-integrity defenses do not protect**, and that this gives
an attacker who has a memory-corruption primitive a reliable control-flow
hijack even on hardened binaries. The authors name the technique **CFOP —
Coroutine Frame-Oriented Programming** (by analogy to ROP/JOP/COOP).

**The core observation.** `handle.resume()`/`.destroy()` perform an indirect
call through a function pointer that lives in a **writable heap object** (the
frame). That indirect call is *compiler-generated* — it is not a source-level
call through a typed function pointer — so:

- **Forward-edge CFI (`-fsanitize=cfi-icall`, Windows CFG)** does not instrument
  it. Those schemes check *source-level* indirect calls against a type/allowed-
  target set; the coroutine resume edge is lowered from `llvm.coro.resume` and
  is simply not a site they guard.
- **Intel CET** does not stop it either. Its forward-edge part (**IBT**) only
  requires the call to land on *some* `endbr64`; a realistic gadget (a function
  entry) has one, so the call passes. Its backward-edge part (the **shadow
  stack**) protects *return addresses*, not this forward indirect call.

**The threat model** (as a hardened-target CFI-evasion result): the victim is
compiled with mainstream control-flow defenses *enabled*, and the attacker has a
realistic **memory-corruption primitive** (heap overflow, use-after-free, type
confusion) plus an **information leak** to defeat ASLR. The claim is that, under
those exact conditions where classic techniques are blocked, hijacking a
coroutine frame still yields arbitrary control-flow — because the frame's
resume/destroy pointers are reachable control data that the deployed defenses
never check.

**Why it generalizes.** Stackless coroutines are now pervasive — C++20, Rust
`async`, and others compile to the same shape (a heap state object holding a
resume continuation). Any runtime that keeps suspended continuations around
(async servers, schedulers, generators) multiplies both the number of live
frames and the time they are exposed.

**What the authors propose.** The paper motivates coroutine-aware mitigations
(protecting the resume/destroy edge specifically, rather than relying on generic
CFI). Our defenses in §6 are an implementation and extension of that direction.

> **Verify before citing.** Treat the above as the conceptual thesis. Exact
> numbers (how many frames, overheads, which CVEs/programs, the precise formal
> model) belong to the paper; do not quote figures from this document as if they
> were measured here.

---

## 5. Our attack benchmarks

All attacks drive a **victim** that uses coroutines and end in the same
observable: a call lands in `hijack_target()`
([test/common/cfop_common.h](../test/common/cfop_common.h)), which prints
`HIJACK_TARGET executing` and runs `id` to stand in for an `execve`/ROP payload.
Builds use `-O1 -fno-inline -g` so frames stay on the heap.

We provide **two tiers**: a didactic harness that isolates the mechanism, and
three bug-driven PoCs that match the paper's realistic threat model.

### 5.1 Didactic harness — `generic/` (TCP :4444)

[test/generic/victim_server.cpp](../test/generic/victim_server.cpp) exposes a
line protocol with an explicit, *god-mode* primitive: `INFO` leaks addresses
(the live frame, the resume/destroy pointers, `hijack_target`, a writable scratch
buffer, a scheduler-style handle slot), and `WRITE <addr> <n> <hex>` writes
arbitrary bytes anywhere. Five attacks
([test/generic/attacker.cpp](../test/generic/attacker.cpp)) exercise the surface:

| # | Attack | Mechanism |
|---|--------|-----------|
| 1 | Resume-pointer overwrite | write `&hijack_target` to `frame[0]`, then `resume()` |
| 2 | Destroy-pointer overwrite | write `&hijack_target` to `frame[8]`, then `destroy()` |
| 3 | Data-only (`is_admin`) | flip a `bool` spilled in the frame — **no pointer touched** |
| 4 | Fake-frame injection | build a fake frame in a scratch buffer, repoint a handle at it, resume |
| 5 | Scheduler-queue CFP | poison the resume pointer of a handle sitting in a "ready queue" |

The harness deliberately *grants* the arbitrary write, so it isolates the
coroutine mechanism from the question of how the write was obtained. Attack 3 is
the important outlier: it is **data-only** — it hijacks a *decision*, not a
pointer — and therefore cannot be stopped by any control-flow defense.

### 5.2 Realistic primitives — bug-driven PoCs

Here the corruption comes from a **real memory-safety bug**; the attacker's only
extra power is an assumed info leak. These match the paper's model.

- **Primitive 1 — heap overflow into an adjacent frame.** `overflow/` (TCP
  :4445, [test/overflow/overflow_victim.cpp](../test/overflow/overflow_victim.cpp)).
  The victim grooms a buffer immediately below a live frame, then does an
  **unchecked copy** of attacker-controlled length into it. A forward overflow
  runs contiguously into `frame[0]`; resuming the coroutine jumps to
  `hijack_target`. Constrained primitive: anchored at one buffer, forward,
  contiguous.

- **Primitive 2 — use-after-free reclaim.** `uaf/` (in-process,
  [test/uaf/uaf_poc.cpp](../test/uaf/uaf_poc.cpp)). The frame is `destroy()`'d
  while a `coroutine_handle` to it is still held — the single most common
  coroutine lifetime bug — and the attacker's next same-size allocation reclaims
  the freed chunk with controlled contents (a fake frame). Resuming the
  **dangling handle** calls `frame[0]`. In-process because the reclaim must land
  in the narrow window between free and resume, which is deterministic via the
  allocator's tcache but awkward to drive remotely.

- **Primitive 3 — dangling handle in a scheduler queue.** `scheduler/` (TCP
  :4446, [test/scheduler/sched_victim.cpp](../test/scheduler/sched_victim.cpp)).
  A mini async scheduler keeps handles in a ready-queue for later resumption.
  The owning object is torn down (frame freed) while its handle is still queued;
  the attacker's staged input reclaims the freed frame; when the scheduler later
  pops and resumes the stale handle, control is hijacked. This is the
  **temporal** variant that makes coroutines special — a suspended continuation
  living in a queue, long after its owner is gone.

---

## 6. Our defenses

Both defenses target the *same* edge — the indirect call through
`frame[0]`/`frame[8]` — but with different trust models. Both are implemented as
LLVM passes loaded from one plugin
([passes/AnalysisPlugin.cpp](../passes/AnalysisPlugin.cpp)).

### 6.0 Prerequisite: the `CoroFrame.cpp` change (TypeID slot)

In the Switch-ABI branch of the frame builder, after the promise field:

```cpp
// CoroFrame.cpp — reserve a per-type TypeID slot AFTER the promise, so the
// promise keeps its ABI-fixed offset 16 (see §3). Placed last in the header.
(void)B.addField(Type::getInt32Ty(C), std::nullopt, /*header*/ true);
```

Because this lives in the compiler, **every** frame built by our clang has the
slot (offset 20 for an empty promise); it just stays 0 unless the CFI pass fills
it. This is why all benchmark variants — vulnerable, CFI, shadow, both — share
one identical frame layout, so the only experimental variable is the defense.

### 6.1 Pass 1 — `CoroDefenseAnalysis` (shared discovery)

[passes/CoroDefenseAnalysis.cpp](../passes/CoroDefenseAnalysis.cpp). Not a
transform; both defenses call it first.

- **`discoverTypes()`** groups functions by the `.resume`/`.destroy` suffix,
  recovering per-coroutine records: the two stubs, the **ramp** function
  (`M.getFunction(base)`), and a **TypeID** assigned in discovery order (1-based;
  **0 is reserved for `noop_coroutine`**).
- **`discoverCallSites()`** finds the hijackable edges: an **indirect** call with
  one pointer argument whose callee is a `LoadInst` from the *same* pointer as
  the argument; the accumulated byte offset classifies it — **0 ⇒ resume,
  8 ⇒ destroy**. (`stripAndAccumulateConstantOffsets` makes this robust to GEPs
  and bitcasts.)

### 6.2 Defense A — Coroutine-Aware CFI (`CoroAwareCFIPass`)

[passes/CoroAwareCFIPass.cpp](../passes/CoroAwareCFIPass.cpp).
**Idea:** stop consulting the writable frame pointer for the call target. Instead
dispatch through a **read-only, type-keyed table**.

`run()` does four things:

1. **`buildDispatchTable()`** — a global array of `{ptr resume_fn, ptr
   destroy_fn}` entries, one per TypeID, **sorted by TypeID so `table[TypeID]` is
   a direct index**; slot 0 is `noop_coroutine`. It is `isConstant=true`, placed
   in `.rodata`, 8-byte aligned — so a write to it faults. This moves the
   authoritative resume/destroy pointers out of the attacker-writable heap and
   into read-only memory.
2. **`buildDispatchFn()`** — emits `__coro_dispatch_resume(frame)` and
   `__coro_dispatch_destroy(frame)`, each `noinline`+`nounwind`: load the TypeID
   from `frame + 20`; **bounds-check** `TypeID < NumSlots` (fail → `llvm.trap` +
   `unreachable`, i.e. SIGILL); else index the table, load the trusted pointer,
   and `call` it with `frame`.
3. **`injectTypeIDStores()`** — in each ramp, right after the resume-pointer
   store, store the constant TypeID into `frame + 20`.
4. **`replaceCallSites()`** — rewrite each discovered indirect resume/destroy
   into a direct `call __coro_dispatch_resume/destroy(frame)`.

**Registration:** this pass is on the **OptimizerLast** extension point, so
simply loading the plugin with `-fpass-plugin` runs it automatically at `-O1+`.

**Guarantee / limits.** A corrupted `frame[0]`/`frame[8]` is *ignored* — the real
body runs and the process survives ("neutralized"), so it is graceful (no DoS).
A garbage TypeID either indexes a valid slot (safe) or trips the bounds check
(trap). It does **not** cover the data-only attack (no pointer/TypeID touched).
Because the dispatcher reads the TypeID from a fixed frame offset, all coroutine
types must place it at the same offset — true here (shared empty promise →
offset 20); a per-type-offset generalization is future work.

### 6.3 Defense B — whole-frame Shadow Stack with MPK (`CoroShadowPass` + runtime)

**Idea:** keep a trusted **copy of the entire frame** in write-protected memory,
and before every resume/destroy check the live frame still equals the copy.
Because it compares all bytes, it also catches **data-only** tampering that no
control-flow defense sees.

**The timing invariant.** A frame changes legitimately as it runs, so a one-time
snapshot would false-positive. The attacker, however, writes while the coroutine
is **suspended**. So the invariant is: *the frame must equal its last-suspended
snapshot at the next resume.* The snapshot is therefore refreshed at every
suspend boundary.

#### Pass 3 — `CoroShadowPass` (instrumentation)

[passes/CoroShadowPass.cpp](../passes/CoroShadowPass.cpp). Inserts four runtime
calls:

- **Register at the ramp's return.** It finds the frame base, then (using a
  `DominatorTree`) inserts `__coro_shadow_register(frame)` before every
  `ReturnInst` the base dominates. Registering at the *return* — not right after
  the resume-pointer store — ensures the whole header is initialized first,
  **including the CFI TypeID** written earlier in the ramp (needed for `both`
  mode, else the snapshot would capture TypeID=0 and false-positive).
- **Verify before, update after.** For every resume/destroy site — matched as
  the CFI dispatch calls *or* as raw indirect `frame[0]`/`frame[8]` calls, so it
  works with or without the CFI pass — it inserts `__coro_shadow_verify_resume`
  **before** the call and `__coro_shadow_update` **after** a resume (the frame
  has advanced to its next suspend point). Destroy gets
  `__coro_shadow_verify_and_remove_destroy` before, and no update.

**Registration:** this pass is addressable only via the pipeline parser (not
auto-inserted), which is why the `shadow`/`both` builds go compile-to-IR →
`opt -passes=...` → link against the runtime.

#### The runtime — `CoroShadowRuntime.c` (`libcoroshadow.a`)

[runtime/CoroShadowRuntime.c](../runtime/CoroShadowRuntime.c).

- **Store:** an open-addressed hash table of 4096 `ShadowEntry` slots, each
  holding `{frame_ptr key, flags, snap_len, uint8_t snapshot[256]}`.
- **Protection:** at startup it `mmap`s the region and tries **Intel MPK** —
  `pkey_alloc` + `pkey_mprotect` tag it with a protection key; `make_writable`/
  `make_readonly` flip write access with `pkey_set` (the cheap userspace WRPKRU,
  thread-local). If MPK is unavailable it **falls back to `mprotect`** toggling.
  Either way the region is **read-only except during brief, locked snapshot
  writes**, so the attacker's arbitrary write cannot corrupt the shadow itself —
  this is what makes the shadow a trustworthy anchor rather than more writable
  heap.
- **`frame_len()`** = `min(malloc_usable_size(frame), 256)` — snapshots as much
  of the frame as the heap allocation guarantees is in-bounds (no OOB read).
- **Entry points:** `__coro_shadow_register` (first snapshot),
  `__coro_shadow_update` (refresh after a legit resume),
  `__coro_shadow_verify_resume` (lock-free `memcmp` against the snapshot;
  mismatch → `abort`; an *unregistered* frame — e.g. a UAF'd/reclaimed one —
  aborts here), and `__coro_shadow_verify_and_remove_destroy` (verify, then
  remove the entry and repair the probe chain).
- **Diagnostics:** `report_and_abort` distinguishes a tampered
  `resume_fn`/`destroy_fn` (bytes differ at offset 0/8) from a pure
  `frame data tampered` data-only attack.

**Guarantee / limits.** Blocks all control-flow attacks (pointer mismatch), the
data-only flip (byte mismatch), and UAF/scheduler reuse (unregistered-frame
check) — all by `abort()`. That is louder than CFI: it crashes the process (a
DoS, but no code execution). Its model assumes no legitimate concurrent writer
touches a suspended frame (true here; a multithreaded runtime writing a promise
from another thread would need care). The 256-byte cap and deterministic reclaim
are demo simplifications.

### 6.4 How the two compose (`both`)

The `opt` pipeline runs `coro-aware-cfi` **then** `coro-shadow-analysis`: CFI
first rewrites the raw indirect calls into `__coro_dispatch_*`, then the shadow
pass recognizes those and wraps them with verify/update. Since `verify` runs
*before* the dispatch call, the shadow's `abort()` fires first on the
control-flow cases — which is why `both` reports `BLOCK(shadow)`.

| | overwrite resume/destroy | fake frame / UAF / scheduler | data-only (`is_admin`) | failure mode |
|---|---|---|---|---|
| **Coro-CFI** | blocked (pointer ignored) | blocked (TypeID dispatch / trap) | **missed** | graceful (survives) |
| **Shadow** | blocked (mismatch) | blocked (unregistered) | **blocked** (mismatch) | `abort()` |

---

## 7. Evaluation: the attack × defense matrix

Each realistic attack is run against six build variants. `vulnerable` is the
known-good compiler with no defense; `cfibaseline` is stock
`-fsanitize=cfi-icall` (LTO, verified to trap a wrong-type call); `cet` is
`-fcf-protection=full` (ELF property `IBT, SHSTK`); `coro-cfi`/`shadow`/`both`
are our defenses. (`make matrix` from `test/`.)

```
PRIMITIVE      | vulnerable cfibaseline   cet        coro-cfi     shadow         both
---------------+--------------------------------------------------------------------------------
1 Overflow     | HIJACKED   HIJACKED      HIJACKED   neutralized  BLOCK(shadow)  BLOCK(shadow)
2 UAF          | HIJACKED   HIJACKED      HIJACKED   neutralized  BLOCK(shadow)  BLOCK(shadow)
3 Scheduler    | HIJACKED   HIJACKED      HIJACKED   neutralized  BLOCK(shadow)  BLOCK(shadow)
```

For the didactic harness, additionally: attacks 1/2/4/5 behave like the
control-flow column above, and **attack 3 (data-only) is HIJACKED under
everything except `shadow`/`both`**.

**Reading the result.**

- **`cfibaseline` = HIJACKED** reproduces *Await() a Second* on this setup:
  genuine forward-edge CFI does not instrument the coroutine resume edge.
- **`cet` = HIJACKED**: IBT only requires the target be *some* `endbr64`, and
  `hijack_target` (an address-taken function) has one; the shadow stack guards
  only returns. **Caveat:** this CPU exposes no CET feature, so CET is compiled-in
  (property present, `endbr64` emitted) but **not hardware-enforced here** — the
  result is the expected one either way, but to claim *enforced-and-bypassed* you
  must rerun on CET-capable hardware (Tiger Lake+/Zen3+, kernel ≥ 6.6,
  glibc ≥ 2.39).
- **`coro-cfi` = neutralized**: it stops the *hijack* but, for UAF/scheduler, the
  program still resumed a freed frame — CFI guarantees control-flow integrity,
  not memory safety. The shadow is stronger there (it detects the stale frame and
  aborts).

---

## 8. Limitations and future work

- **Single TypeID offset.** Coro-CFI reads the TypeID at a fixed frame offset;
  all demo coroutines share an empty promise (offset 20). A real deployment needs
  a per-type offset (e.g. a side table keyed by the resume-stub address, or
  encoding the offset with the TypeID).
- **Shadow is DoS-on-detection.** It `abort()`s; a production design might log
  and recover, or move to a verify-and-repair model.
- **Reclaim determinism.** UAF/scheduler PoCs rely on single-threaded tcache LIFO
  reclaim; they are deterministic here but not a general heap-grooming result.
- **CET not enforced on this host** (see §7).
- **Data-flow coverage.** Only the whole-frame shadow addresses data-only
  attacks, and only for frame-resident data; authority held elsewhere is out of
  scope. A principled minimal invariant (vs. snapshotting everything) is open.
- **Threat-model realism.** The didactic harness grants the write; the three
  primitives derive it from real bugs but still assume an info leak. A full
  leak→AW chain against a real async server would strengthen the story.

---

## 9. Build & run

Prerequisites: the patched clang/opt in `~/workspace/llvm-build` (with the
`CoroFrame.cpp` TypeID change), the built plugin
(`passes/build/CoroDefensePlugin.so`) and runtime
(`runtime/build/libcoroshadow.a`). The `cfibaseline` variant additionally needs
`ld.lld` and clang's `cfi_ignorelist.txt` resource.

```
coro-defense/
  llvm-project/ …/CoroFrame.cpp      # the one compiler change (TypeID slot)
  passes/                            # the 3 passes + plugin registration
  runtime/CoroShadowRuntime.c        # the MPK shadow-stack runtime
  test/
    common.mk  Makefile  run_matrix.sh
    common/cfop_common.h             # shared Task + hijack_target
    generic/    victim_server.cpp attacker.cpp demo.sh   # didactic, 5 attacks (:4444)
    overflow/   overflow_victim.cpp overflow_attacker.cpp # Primitive 1 (:4445)
    uaf/        uaf_poc.cpp                                # Primitive 2 (in-process)
    scheduler/  sched_victim.cpp sched_attacker.cpp        # Primitive 3 (:4446)
```

```bash
# from test/
make                 # build vulnerable victim(s)+attacker(s) in every folder
make variants        # build every defense/baseline variant everywhere
make matrix          # build variants, then print the attack x defense table
make -C overflow run # run one primitive standalone (also: uaf, scheduler)
make -C generic demo # annotated 5-attack walkthrough
```

Each build variant of a victim `<v>` is a separate binary: `<v>` (vulnerable),
`<v>_cfibaseline`, `<v>_cet`, `<v>_cfi`, `<v>_shadow`, `<v>_both`.

---

## 10. References

- *Await() a Second: Evading Control Flow Integrity by Hijacking C++
  Coroutines.* **[Fill in authors, venue, year, URL/DOI from the paper.]**
- C++20 coroutines: ISO C++ `[dcl.fct.def.coroutine]`; cppreference,
  "Coroutines (C++20)".
- LLVM Coroutines: "Coroutines in LLVM" (LLVM docs); `llvm/lib/Transforms/
  Coroutines/` (`CoroEarly`, `CoroSplit`, `CoroFrame`, `CoroElide`,
  `CoroCleanup`).
- M. Kuznetsov et al., *Code-Pointer Integrity* (OSDI 2014) — prior art for
  protecting code pointers in a safe region.
- Intel CET: *Control-flow Enforcement Technology Specification* (IBT + shadow
  stack); clang `-fcf-protection`, `-fsanitize=cfi-icall`.

*This document describes a research/educational project; the attacks are
deliberately self-contained demos for studying coroutine control-flow security.*
