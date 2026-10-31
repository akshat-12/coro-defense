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

**Example — a coroutine that suspends twice, and its drive loop.** This is the
shape every victim in this project uses:

```cpp
static Task worker(int id) {
    printf("worker %d: A\n", id);     // runs on the 1st resume
    co_await std::suspend_always{};   // suspend #1  <-- parks here after "A"
    printf("worker %d: B\n", id);     // runs on the 2nd resume
    co_await std::suspend_always{};   // suspend #2
    printf("worker %d: done\n", id);  // runs on the 3rd resume, then co_return
}

int main() {
    Task t = worker(1);   // allocate frame; initial_suspend parks BEFORE "A"
    t.handle.resume();    // -> "worker 1: A",   now parked at suspend #1
    t.handle.resume();    // -> "worker 1: B",   now parked at suspend #2
    t.handle.resume();    // -> "worker 1: done", now t.handle.done() == true
}                         // ~Task -> t.handle.destroy() frees the frame
```

Each `resume()` does the same two machine steps: **load the resume function
pointer out of the frame and call it** (§2). That function reads the *resume
index* stored in the frame to jump to the right continuation (before `A`, then
`#1`, then `#2`). The whole "where am I in this function" state lives in the
heap frame, not on any stack — which is exactly why corrupting the frame is so
powerful.

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

**Example — the frame struct and a byte view.** For `worker()` above, LLVM
emits a frame type like this (schematic, field names ours):

```llvm
%worker.Frame = type {
  ptr,            ; +0   resume  stub  (@worker.resume)
  ptr,            ; +8   destroy stub  (@worker.destroy)
  %promise_type,  ; +16  promise object (empty here -> 1 byte + padding)
  i32,            ; +20  TypeID   (our CoroFrame.cpp addition; 0 in stock clang)
  i2,             ; +24  suspend/resume index (2 suspend points -> 2 bits)
  i32             ; +28  spilled local `id`
}
```

A live, parked frame then looks like this in memory (addresses illustrative):

```
frame @ 0x5555_0000_42b0
 +0  40 50 16 6e ...   resume_fn  = 0x0000_6e16_5040   <- called by resume()
 +8  70 51 16 6e ...   destroy_fn = 0x0000_6e16_5170   <- called by destroy()
 +16 00                promise (empty)
 +20 01 00 00 00       TypeID = 1
 +24 .. ..             index + spilled `id`
```

**Example — what `handle.resume()` compiles to.** It is `__builtin_coro_resume`
over the frame, i.e. an indirect call through `frame[0]`:

```asm
; rdi = frame
mov   rax, [rdi]      ; rax = frame[0]  = resume_fn  (loaded from WRITABLE heap)
call  rax            ; <-- the hijackable edge; rdi (=frame) is the argument
```

Every attack in §5 ends by making that one load return a value the attacker
chose. There is no type check on `rax` here beyond what a generic CFI mechanism
adds — and §4/§7 show those mechanisms don't cover this edge.

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

**Example — before and after `CoroSplit` (schematic).** Front-end IR for
`worker()` is one function full of coroutine intrinsics:

```llvm
define ptr @worker(i32 %id) {                 ; the single pre-split function
entry:
  %id.addr = ...
  %promise = alloca %promise_type
  %id2  = call token @llvm.coro.id(i32 0, ptr %promise, ptr null, ptr null)
  %size = call i64 @llvm.coro.size.i64()
  %mem  = call ptr @operator.new(i64 %size)   ; heap-allocate the frame
  %hdl  = call ptr @llvm.coro.begin(token %id2, ptr %mem)
  ...                                         ; body, with:
  %s = call i8 @llvm.coro.suspend(token none, i1 false)  ; each co_await
  switch i8 %s, label %suspend [ i8 0, label %resume  i8 1, label %cleanup ]
  ...
  call i1 @llvm.coro.end(ptr %hdl, i1 false)
}
```

`CoroSplit` turns that into a **ramp** plus **stubs**, and materializes the
frame type:

```llvm
%worker.Frame = type { ptr, ptr, %promise_type, i32, i2, i32 }  ; see §2

define ptr @worker(i32 %id) {                 ; RAMP (what the caller calls)
  %mem = call ptr @operator.new(i64 40)
  store ptr @worker.resume,  ptr %mem               ; frame[0]
  store ptr @worker.destroy, ptr getelementptr(... i32 1)  ; frame[8]
  ; store i32 1 into frame+20  <-- added by our CFI pass (§6.2)
  ...                                                ; run up to initial_suspend
  ret ptr %mem                                       ; return handle, parked
}
define void @worker.resume(ptr %frame) { ... switch on frame's index ... }
define void @worker.destroy(ptr %frame) { ... }
```

And the promise-offset constraint from `CoroEarly` is literally a GEP to field
2 of the mock struct:

```llvm
; coroutine_handle::from_promise(p)  /  .promise()  lowers to +/- 16:
%frame   = getelementptr i8, ptr %promise, i64 -16   ; promise is at frame+16
```

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

**Example — the hijack in five lines, and what each defense sees.** Given a
leak and a write primitive from a memory bug:

```c
void *frame  = leak_live_frame();        // info leak defeats ASLR
void *gadget = base + OFF_hijack_target; // a leaked code address (function entry)

// the memory-corruption bug writes 8 bytes here:
*(void **)frame = gadget;                // overwrite frame[0] (the resume ptr)

handle_resume(frame);   // victim does: mov rax,[frame]; call rax  -> gadget(frame)
```

What the deployed defenses observe at that `call rax`:

| Defense | What it checks here | Result |
|---|---|---|
| `cfi-icall` | only *source-level* fnptr calls; this is a compiler builtin | not instrumented → **passes** |
| CET **IBT** | target must start with `endbr64`; `gadget` is a function entry | has `endbr64` → **passes** |
| CET **shadow stack** | return addresses | not a return → **irrelevant** |

That is the whole finding: the one load-and-call that drives a coroutine is a
control-flow edge the deployed defenses do not guard.

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
five bug-driven PoCs that match the paper's realistic threat model.

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

**Example — attack 1 (resume-pointer overwrite) on the wire** (`make -C generic
run_attack_1`). The attacker leaks, writes `&hijack_target` over `frame[0]`, and
triggers a resume:

```
[ATTACKER] Connected  victim says: READY victim_server pid=2002430
[ATTACKER] Leaked:  worker_frame 0x55…2b0   resume_fn 0x55…5040
                    hijack_target 0x55…4f60
[ATTACKER] frame[0] is at 0x55…2b0; overwriting it with hijack_target…
[ATTACKER]   WRITE 55…2b0 8 604f…  -> OK wrote 8 bytes
[ATTACKER]   TRIGGER RESUME        -> OK
--- victim stderr ---
[VICTIM] <- "WRITE 55…2b0 8 604f…"
[VICTIM] <- "TRIGGER RESUME"
[VICTIM] ╔══════════════════════════════════════════════╗
[VICTIM] ║  HIJACK_TARGET executing inside victim PID …  ║   <-- hijack fired
[VICTIM]  id -> uid=1001(akshat) …
```

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

  ```
  [VICTIM] buf=0x…670 frame=0x…6c0 delta=80 resume_fn=0x…930
  [ATTACKER] overflow (80 filler + 8-byte ptr) -> OK copied 88 bytes into a 64-byte buffer
  [ATTACKER] RESUME -> OK
  [VICTIM] *** HIJACK_TARGET executing inside PID … ***
  ```

- **Primitive 2 — use-after-free reclaim.** `uaf/` (in-process,
  [test/uaf/uaf_poc.cpp](../test/uaf/uaf_poc.cpp)). The frame is `destroy()`'d
  while a `coroutine_handle` to it is still held — the single most common
  coroutine lifetime bug — and the attacker's next same-size allocation reclaims
  the freed chunk with controlled contents (a fake frame). Resuming the
  **dangling handle** calls `frame[0]`. In-process because the reclaim must land
  in the narrow window between free and resume, which is deterministic via the
  allocator's tcache but awkward to drive remotely.

  ```
  [VICTIM] frame=0x…2b0 usable=24   (bug) frame freed; dangling handle kept
  [ATTACKER] reclaim=0x…2b0 (== freed frame, reclaimed)
  [ATTACKER] planted hijack_target in reclaimed frame[0]/[8]
  [VICTIM] resuming dangling handle... -> *** HIJACK_TARGET executing ***
  ```

- **Primitive 3 — dangling handle in a scheduler queue.** `scheduler/` (TCP
  :4446, [test/scheduler/sched_victim.cpp](../test/scheduler/sched_victim.cpp)).
  A mini async scheduler keeps handles in a ready-queue for later resumption.
  The owning object is torn down (frame freed) while its handle is still queued;
  the attacker's staged input reclaims the freed frame; when the scheduler later
  pops and resumes the stale handle, control is hijacked. This is the
  **temporal** variant that makes coroutines special — a suspended continuation
  living in a queue, long after its owner is gone.

  ```
  [VICTIM] frame=0x…8d0 usable=24 reclaim=0x…8d0 (reclaimed freed frame)
  [ATTACKER] STAGE -> OK staged 16 bytes into the reclaimed frame
  [ATTACKER] RUN   -> OK
  [VICTIM] scheduler resuming queued handle 0x…8d0... -> *** HIJACK_TARGET executing ***
  ```

- **Primitive 4 — fake-frame injection.** `fakeframe/` (TCP :4448,
  [test/fakeframe/fakeframe_victim.cpp](../test/fakeframe/fakeframe_victim.cpp)).
  Unlike primitives 1–3, which corrupt a *real* frame, here the attacker crafts
  an **entirely fake frame** in a buffer it controls and redirects a *stored*
  `coroutine_handle` at it. The bug is a heap overflow of a
  `struct Session { char buf[64]; coroutine_handle<> h; }` whose `buf` overflow
  overwrites the adjacent handle pointer `h` with the address of an
  attacker-staged scratch buffer; resuming `h` then calls the fake frame's
  resume pointer. This is the realistic form of the didactic "attack 4".

  ```
  [VICTIM] buf=0x…a10 handle_store=0x…a50 scratch=0x…120
  [ATTACKER] STAGE (fake frame: resume=destroy=hijack_target) -> OK
  [ATTACKER] overflow (64 filler + handle ptr=&scratch)       -> OK
  [ATTACKER] TRIGGER -> OK
  [VICTIM] resuming stored handle 0x…120... -> *** HIJACK_TARGET executing ***
  ```

- **Primitive 5 — data-only attack.** `dataonly/` (TCP :4447,
  [test/dataonly/dataonly_victim.cpp](../test/dataonly/dataonly_victim.cpp)).
  The privileged coroutine keeps a security decision (`is_admin`) and a
  frame-resident `prefs[]` array live across a suspend. The bug is a classic
  **unchecked indexed write** (`prefs[idx] = val`, `idx` attacker-controlled),
  so a large/negative index reaches the `is_admin` byte. **No pointer is
  touched** — it flips a *decision*, not a control-flow target. This is the
  realistic form of the didactic "attack 3", and it is the case that *no*
  control-flow defense can stop (see §7).

  ```
  [VICTIM] frame=0x…670 prefs=0x…690 is_admin=0x…6a2
  [ATTACKER] prefs=0x…690 is_admin=0x…6a2 -> prefs[18] is the is_admin byte
  [ATTACKER] (no pointer touched — control-flow defenses are blind to this)
  [ATTACKER] SETPREF 18 1 -> OK ;  TRIGGER -> OK granted=true
  [VICTIM] priv: *** ACCESS GRANTED (is_admin=true) ***
  ```

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

**Example — the frame type, stock vs. our clang:**

```llvm
; stock clang:              { ptr, ptr, %promise, i2, i32 }
;                             +0   +8    +16     idx  spilled
; our clang (TypeID added): { ptr, ptr, %promise, i32, i2, i32 }
;                             +0   +8    +16     +20  idx  spilled
;                                          ^promise stays at 16 (ABI); TypeID at 20
```

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

**Example — what it finds** (its `LLVM_DEBUG` output on the generic victim):

```
[CoroDefense] Found 2 coroutine types
  TypeID=1  worker_coro
  TypeID=2  privileged_coro
[CoroDefense] Found 4 coroutine call sites
```

And the exact IR shape it matches as a "resume site" (offset 0) — this is what
`replaceCallSites`/`CoroShadowPass` rewrite or wrap:

```llvm
%fp = load ptr, ptr %frame        ; load from frame + 0
call void %fp(ptr %frame)         ; indirect, 1 ptr arg, callee loaded from arg  => RESUME
```

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

**Example — what the pass emits** (schematic). The read-only table and the
dispatcher:

```llvm
; .rodata, constant: slot[0]=noop, slot[i]=the real stubs for TypeID i
@__coro_dispatch_table = constant [3 x {ptr,ptr}] [
    {ptr @__coro_noop_resume, ptr @__coro_noop_destroy},   ; 0: noop_coroutine
    {ptr @worker_coro.resume, ptr @worker_coro.destroy},   ; 1
    {ptr @privileged_coro.resume, ptr @privileged_coro.destroy} ; 2
], section ".rodata"

define internal void @__coro_dispatch_resume(ptr %frame) noinline nounwind {
  %tid = load i32, ptr getelementptr(i8, ptr %frame, i64 20)   ; TypeID @ frame+20
  %ok  = icmp ult i32 %tid, 3                                  ; bounds check
  br i1 %ok, label %dispatch, label %oob
oob:      call void @llvm.trap()  unreachable                  ; SIGILL
dispatch: %e  = getelementptr [3 x {ptr,ptr}], @__coro_dispatch_table, i32 0, i32 %tid
          %fp = load ptr, ptr %e            ; trusted resume_fn from .rodata
          call void %fp(ptr %frame)  ret void
}
```

**Example — the call-site rewrite** (`replaceCallSites`):

```llvm
; BEFORE (hijackable: target comes from the writable frame)
%fp = load ptr, ptr %frame
call void %fp(ptr %frame)
; AFTER (target comes from the read-only table, keyed by frame+20)
call void @__coro_dispatch_resume(ptr %frame)
```

So overwriting `frame[0]` no longer changes the call target — only the TypeID at
`frame+20` selects it, and that only indexes the read-only table.

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

**Example — an instrumented resume site** (schematic):

```llvm
; BEFORE                         ; AFTER (shadow-only build)
%fp = load ptr, ptr %frame       call void @__coro_shadow_verify_resume(ptr %frame) ; check
call void %fp(ptr %frame)        %fp = load ptr, ptr %frame
                                 call void %fp(ptr %frame)                           ; real resume
                                 call void @__coro_shadow_update(ptr %frame)         ; re-snapshot
```

And the register call placed at the ramp's return:

```llvm
define ptr @worker(i32 %id) {            ; ramp
  ...                                     ; header + TypeID all initialised
  call void @__coro_shadow_register(ptr %frame)   ; snapshot the parked frame
  ret ptr %frame
}
```

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

**Example — the shadow entry and the startup line:**

```c
typedef struct __attribute__((aligned(64))) {
    uintptr_t frame_ptr;         // key (0 = empty)
    uint32_t  flags, snap_len;
    uint8_t   snapshot[256];     // trusted copy of the frame
} ShadowEntry;                   // 4096-slot open-addressed table, MPK-protected
```

```
[CoroShadow] shadow stack ready (MPK, 4096 slots, 256 B/frame)   # or "mprotect fallback"
```

**Example — the three ways it aborts**, one per attack class:

```
# pointer overwrite (overflow / direct):
[CoroShadow] ATTACK: resume_fn tampered on frame 0x…  expected 0x…550  got 0x…470
# data-only flip (is_admin):
[CoroShadow] ATTACK: frame data tampered on 0x… before resume (no pointer touched …)
# UAF / fake-frame (the frame was never registered, or was removed on destroy):
[CoroShadow] ATTACK: unregistered frame 0x… passed to resume()
```

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

**Example — a resume site in `both` mode.** Verify runs first, so the shadow's
`abort()` wins before the CFI dispatch even executes:

```llvm
call void @__coro_shadow_verify_resume(ptr %frame)   ; shadow: abort on mismatch
call void @__coro_dispatch_resume(ptr %frame)        ; CFI: table dispatch (if we got here)
call void @__coro_shadow_update(ptr %frame)          ; shadow: re-snapshot
```

---

## 7. Evaluation: the attack × defense matrix

Each realistic attack is run against six build variants. `vulnerable` is the
known-good compiler with no defense; `cfibaseline` is stock
`-fsanitize=cfi-icall` (LTO, verified to trap a wrong-type call); `cet` is
`-fcf-protection=full` (ELF property `IBT, SHSTK`); `coro-cfi`/`shadow`/`both`
are our defenses. (`make matrix` from `test/`.)

```
PRIMITIVE      | vulnerable     cfibaseline    cet            coro-cfi       shadow         both
---------------+----------------------------------------------------------------------------------------
1 Overflow     | HIJACKED       HIJACKED       HIJACKED       neutralized    BLOCK(shadow)  BLOCK(shadow)
2 UAF          | HIJACKED       HIJACKED       HIJACKED       neutralized    BLOCK(shadow)  BLOCK(shadow)
3 Scheduler    | HIJACKED       HIJACKED       HIJACKED       neutralized    BLOCK(shadow)  BLOCK(shadow)
4 Fake-frame   | HIJACKED       HIJACKED       HIJACKED       neutralized    BLOCK(shadow)  BLOCK(shadow)
5 Data-only    | GRANTED(data)  GRANTED(data)  GRANTED(data)  GRANTED(data)  BLOCK(shadow)  BLOCK(shadow)
```

Legend: `HIJACKED` = control-flow hijack executed; `neutralized` = coro-CFI
dispatched through its read-only table so the hijack never ran (process
survives); `GRANTED(data)` = the data-only attack succeeded (the privileged
branch ran); `BLOCK(shadow)` = the shadow stack detected tampering and
`abort()`ed. (The didactic harness's five attacks behave the same way: 1/2/4/5
like the control-flow rows, attack 3 like the data-only row.)

**Reading the result.**

- **`cfibaseline` = HIJACKED** (rows 1–4) reproduces *Await() a Second* on this
  setup: genuine forward-edge CFI does not instrument the coroutine resume edge.
- **`cet` = HIJACKED** (rows 1–4): IBT only requires the target be *some*
  `endbr64`, and `hijack_target` (an address-taken function) has one; the shadow
  stack guards only returns. **Caveat:** this CPU exposes no CET feature, so CET
  is compiled-in (property present, `endbr64` emitted) but **not hardware-enforced
  here** — the result is the expected one either way, but to claim
  *enforced-and-bypassed* you must rerun on CET-capable hardware (Tiger Lake+/
  Zen3+, kernel ≥ 6.6, glibc ≥ 2.39).
- **`coro-cfi` = neutralized** (rows 1–4): it stops the *hijack* but, for
  UAF/scheduler/fake-frame, the program still resumed a freed/forged frame — CFI
  guarantees control-flow integrity, not memory safety. For the fake-frame case,
  the forged TypeID can at most index the read-only dispatch table (here a noop),
  so no attacker code runs. The shadow is stronger: it detects the stale/forged
  frame (`unregistered frame`) and aborts.
- **Row 5 (data-only) is the decisive one.** It is `GRANTED(data)` under *every*
  control-flow defense — stock CFI, CET, **and our coro-aware CFI** — because it
  corrupts a spilled `bool`, not a pointer; the resume edge is never diverted. It
  is blocked **only** by the whole-frame shadow stack, whose byte-for-byte
  comparison catches the flip (`frame data tampered`). This is the empirical
  statement of the defense taxonomy: control-flow integrity, however complete,
  cannot address data-only corruption; that needs data integrity (here, the
  MPK-protected whole-frame shadow).

**Example — two cells of row 1 (overflow), side by side.** Same attacker, two
victim builds:

```
# overflow_victim (vulnerable):           # overflow_victim_shadow:
[VICTIM] copied 88 bytes into 64-byte buf [VICTIM] copied 88 bytes into 64-byte buf
[ATTACKER] RESUME -> OK                   [CoroShadow] ATTACK: resume_fn tampered on
[VICTIM] *** HIJACK_TARGET executing ***    frame 0x…  expected 0x…550 got 0x…470
                                          Aborted (core dumped)         <-- BLOCK(shadow)
```

**Example — two cells of row 5 (data-only).** Here `coro-cfi` is *not* enough:

```
# dataonly_victim_cfi (coro-aware CFI):   # dataonly_victim_shadow:
[ATTACKER] SETPREF 18 1 ; TRIGGER         [ATTACKER] SETPREF 18 1 ; TRIGGER
[VICTIM] *** ACCESS GRANTED ***           [CoroShadow] ATTACK: frame data tampered …
  -> GRANTED(data): CFI never saw it        Aborted (core dumped)  -> BLOCK(shadow)
```

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
    dataonly/   dataonly_victim.cpp dataonly_attacker.cpp  # Primitive 5 (:4447)
    fakeframe/  fakeframe_victim.cpp fakeframe_attacker.cpp # Primitive 4 (:4448)
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
