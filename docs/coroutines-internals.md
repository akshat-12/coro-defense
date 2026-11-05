# C++20 Coroutines, Inside Out

A from-scratch explanation of C++20 coroutines and **exactly what they become
when compiled** — the generated functions and stubs, the heap frame, its struct
type and byte-level layout, and the machine code that drives a resume. Every IR
and assembly excerpt below is **real output** from the clang/LLVM 18.1.8 build
this project uses, lightly trimmed and annotated.

> This is the coroutine primer. The attack/defense material lives in
> [coroutine-cfop-defenses.md](coroutine-cfop-defenses.md); this document is
> just "how coroutines work and what they look like compiled."

## Contents

1. [What a coroutine is](#1-what-a-coroutine-is)
2. [The running example](#2-the-running-example)
3. [The machinery: promise, handle, awaiters](#3-the-machinery-promise-handle-awaiters)
4. [The lifecycle / state machine](#4-the-lifecycle--state-machine)
5. [What the compiler emits (overview)](#5-what-the-compiler-emits-overview)
6. [Step 1 — coroutine intrinsics (front-end IR)](#6-step-1--coroutine-intrinsics-front-end-ir)
7. [Step 2 — CoroSplit: the ramp and the stubs](#7-step-2--corosplit-the-ramp-and-the-stubs)
8. [The frame struct and its memory layout](#8-the-frame-struct-and-its-memory-layout)
9. [How resume/destroy actually dispatch](#9-how-resumedestroy-actually-dispatch)
10. [`from_promise` and the fixed promise offset](#10-from_promise-and-the-fixed-promise-offset)
11. [Allocation, elision, and why we pin frames to the heap](#11-allocation-elision-and-why-we-pin-frames-to-the-heap)
12. [One resume, end to end](#12-one-resume-end-to-end)
13. [Reproduce it yourself](#13-reproduce-it-yourself)

---

## 1. What a coroutine is

A **coroutine** is a function that can **suspend** partway through, hand control
back to its caller, and later be **resumed** from exactly where it left off,
with all its local state intact. In C++20, a function is a coroutine if its body
uses any of `co_await`, `co_yield`, or `co_return`.

C++ coroutines are **stackless**. A suspended coroutine does *not* keep a live
call stack (as a thread or fiber would). Instead, the compiler figures out which
local variables are live across each suspension and packs them — together with a
small integer saying "which suspend point we're parked at" and some bookkeeping
— into a single heap object called the **coroutine frame**. Suspending just
unwinds the normal machine stack and returns to the caller; resuming re-enters
the generated code using the frame as its state.

That design is the whole story: **the coroutine's entire "where am I and what do
I know" lives in a heap struct**, reachable through a one-pointer handle. Points
8–9 show that struct and the exact code that reads it.

---

## 2. The running example

Every excerpt below comes from compiling this generator — a coroutine that
yields three numbers:

```cpp
#include <coroutine>
#include <cstdio>

struct Gen {
  struct promise_type {
    int value;                                   // lives IN the frame
    Gen get_return_object() {
      return Gen{std::coroutine_handle<promise_type>::from_promise(*this)};
    }
    std::suspend_always initial_suspend() noexcept { return {}; }
    std::suspend_always final_suspend()   noexcept { return {}; }
    std::suspend_always yield_value(int v) noexcept { value = v; return {}; }
    void return_void() noexcept {}
    void unhandled_exception() noexcept {}
  };
  std::coroutine_handle<promise_type> handle;
};

static Gen counter(int start) {
  int x = start;                 // live across suspends -> spilled into the frame
  for (int i = 0; i < 3; i++) {
    co_yield x;                  // suspend; exposes x via promise.value
    x += i;                      // uses x after resume
  }
}

int main() {
  Gen g = counter(10);                     // allocate frame; parked before 1st line
  while (!g.handle.done()) {
    g.handle.resume();                     // run until the next co_yield / end
    if (!g.handle.done())
      printf("yielded %d\n", g.handle.promise().value);
  }
  g.handle.destroy();                      // free the frame
}
```

Running it prints `yielded 10`, `yielded 10`, `yielded 11` — the point is the
machinery, not the arithmetic.

---

## 3. The machinery: promise, handle, awaiters

Three types make a coroutine work:

- **The promise type.** For a coroutine returning `Gen`, the compiler uses
  `Gen::promise_type`. The promise is an object **embedded inside the frame**
  (see §8) that customizes behavior through well-known hooks:
  - `initial_suspend()` / `final_suspend()` — suspend before the first statement
    and after the body ends?
  - `get_return_object()` — build the thing the coroutine call returns to the
    caller (here, a `Gen` wrapping the handle);
  - `yield_value(v)` — what `co_yield v` does (here: store `v` into
    `promise.value`, then suspend);
  - `return_void()` / `return_value()`, `unhandled_exception()`.
- **`std::coroutine_handle<P>`.** Internally just a single pointer — the frame
  address. It is the remote control: `resume()`, `destroy()`, `done()`,
  `address()`, and `promise()` / `from_promise()`. `main` above drives the
  coroutine entirely through this handle.
- **Awaiters.** `co_await e` (and `co_yield`, which is `co_await
  promise.yield_value(...)`) consult the awaiter's
  `await_ready` / `await_suspend` / `await_resume` to decide whether to suspend.
  `std::suspend_always` is the trivial awaiter that always suspends.

---

## 4. The lifecycle / state machine

Conceptually the compiler rewrites the coroutine body into a resumable state
machine with these phases:

```
counter(10) called
   │  operator new  -> allocate frame
   │  construct promise; get_return_object() -> Gen{handle}
   │  initial_suspend() == suspend_always  ──► SUSPEND (index=0), return Gen to caller
   ▼
resume()  ──► run body: x=10; i=0; co_yield x (value=10) ──► SUSPEND (index=1)
resume()  ──► x+=0 (=10); i=1; co_yield x (value=10)     ──► SUSPEND (index=2)
resume()  ──► x+=1 (=11); i=2; co_yield x (value=11)     ──► SUSPEND (index=3)
resume()  ──► x+=2; i=3; loop ends; return_void();
             final_suspend() == suspend_always ──► SUSPEND (done); frame kept
destroy() ──► run cleanup; operator delete -> free frame
```

Two consequences worth remembering:

- Because `initial_suspend` is `suspend_always`, **calling the coroutine just
  allocates and parks it**; nothing in the body runs until the first `resume()`.
- Because `final_suspend` is `suspend_always`, **the frame is not freed when the
  body finishes** — `done()` becomes true but the frame lives until `destroy()`.

---

## 5. What the compiler emits (overview)

From one source function `counter`, LLVM's coroutine passes produce **a ramp
plus three stubs**, all sharing one **frame struct type**:

| Symbol (demangled) | Role |
|---|---|
| `counter(int)` | **ramp** — what the caller calls: allocates the frame, writes the header, runs up to `initial_suspend`, returns the handle |
| `counter(int).resume` | **resume stub** — the state machine; `switch`es on the frame's index to continue |
| `counter(int).destroy` | **destroy stub** — cleanup + `operator delete` |
| `counter(int).cleanup` | **cleanup stub** — cleanup path without freeing (used on some exit edges) |
| `%counter.Frame` | the heap struct holding promise + spilled locals + index |

Real symbols from the build (mangled):

```
define internal fastcc ptr  @_ZL7counteri(i32 %start)          ; ramp
define internal fastcc void @_ZL7counteri.resume(ptr %0)       ; resume stub
define internal fastcc void @_ZL7counteri.destroy(ptr %0)      ; destroy stub
%_ZL7counteri.Frame = type { ... }                             ; the frame
```

The library `std::coroutine_handle<...>::resume()/destroy()/promise()/done()`
functions are also emitted (they're small wrappers); §9–10 show what they lower
to.

---

## 6. Step 1 — coroutine intrinsics (front-end IR)

Before optimization, clang emits the coroutine as **one** function full of
`llvm.coro.*` intrinsics — placeholders the mid-end later lowers. The actual
intrinsics emitted for `counter` (counts from the pre-lowering IR):

```
   1  @llvm.coro.id        token identifying this coroutine + its promise
   1  @llvm.coro.alloc     "do I need to heap-allocate?" (for elision)
   1  @llvm.coro.size.i64  frame size in bytes (becomes a constant)
   1  @llvm.coro.begin     returns the frame pointer (the handle)
   2  @llvm.coro.free      frame pointer, for operator delete
   2  @llvm.coro.promise   address of the promise  <-> frame (the +/-16 GEP, §10)
   3  @llvm.coro.save      save suspension state
   3  @llvm.coro.suspend   the suspend points (3 of them: init + 2 co_yields... )
   1  @llvm.coro.end       end of the coroutine body
   1  @llvm.coro.resume / @llvm.coro.destroy  (from handle.resume()/destroy())
```

`@llvm.coro.suspend` returning `i8` is the heart of it: at each suspend point the
value selects *suspend* (return to caller), *resume* (continue), or *cleanup*
(unwind) — which is exactly the `switch` the resume stub ends up containing.

---

## 7. Step 2 — CoroSplit: the ramp and the stubs

`CoroSplit` (with `CoroFrame`) builds the frame type, spills the live values into
it, and splits the function. The **ramp** heap-allocates the frame and writes the
header — here, a 48-byte `operator new` and the two function pointers at the top:

```llvm
; --- ramp: @_ZL7counteri ---
%call = tail call ptr @_Znwm(i64 48)                 ; operator new(48) -> frame
store ptr @_ZL7counteri.resume,  ptr %call           ; frame[0] = resume stub
%destroy.addr = getelementptr %…Frame, ptr %call, i64 0, i32 1
store ptr @_ZL7counteri.destroy, ptr %destroy.addr   ; frame[8] = destroy stub
; ... spill `start`, init promise, set index=0, run initial_suspend ...
%start.spill.addr = getelementptr %…Frame, ptr %call, i64 0, i32 5  ; store `start`
%index.addr73     = getelementptr %…Frame, ptr %call, i64 0, i32 8  ; store index
ret ptr %call                                        ; return handle, parked
```

The **resume stub** reloads the index and `switch`es on it to jump to the right
continuation:

```llvm
; --- resume stub: @_ZL7counteri.resume(ptr %0) ---
%index.addr = getelementptr %…Frame, ptr %0, i64 0, i32 8
%index      = load i2, ptr %index.addr                ; which suspend point?
; switch %index -> [ body-after-yield-1, body-after-yield-2, ... ]
%x.reload.addr     = getelementptr %…Frame, ptr %0, i64 0, i32 6  ; reload `x`
%__promise.addr    = getelementptr %…Frame, ptr %0, i64 0, i32 2  ; the promise
```

Every access inside the stubs is a GEP into the frame struct — the stubs hold no
state of their own; **all state is in the frame**.

---

## 8. The frame struct and its memory layout

This is the real emitted frame type for `counter` (field order = memory order):

```llvm
%_ZL7counteri.Frame = type {
  ptr,                              ; 0  resume  stub pointer
  ptr,                              ; 1  destroy stub pointer
  %"struct.Gen::promise_type",      ; 2  promise (has `int value`)
  i32,                              ; 3  <-- TypeID  (added by THIS project; see note)
  %"struct.…::coroutine_handle",    ; 4  spilled awaiter continuation handle
  i32,                              ; 5  spilled `start`
  i32,                              ; 6  spilled `x`
  i32,                              ; 7  spilled `i`
  i2,                               ; 8  suspend/resume index
  %"struct.…::suspend_always"       ; 9  spilled awaiter object (empty)
}
```

Resolved to byte offsets (this build, 64-bit; total size 48, from `operator
new(48)`):

```
 off  size  field
 +0     8   resume  fn pointer      ── header ──  called by handle.resume()
 +8     8   destroy fn pointer                    called by handle.destroy()
 +16    4   promise.value (int)                   promise sits at the ABI-fixed +16 (§10)
 +20    4   TypeID (i32)              *** our build only — stock clang omits this ***
 +24    8   awaiter continuation handle (ptr)
 +32    4   spilled `start`
 +36    4   spilled `x`
 +40    4   spilled `i`
 +44    1   resume index (i2, padded)
 +45    1   awaiter object (empty)
 +46    2   padding -> 48 total
```

Notes:

- **Header fields (resume, destroy, promise) have fixed offsets** 0/8/16. The
  resume/destroy pointers are plain function pointers in **writable heap
  memory** — that is the entire basis of the CFOP attacks in the other doc.
- The **spilled locals** (`start`, `x`, `i`) and the **index** are placed by
  `performOptimizedStructLayout`, so their order/offsets are not contractual —
  only the header is.
- **The `i32` at +20 labelled "TypeID" is added by *this project's* patched
  clang** (an extra header field after the promise, used by the Coroutine-Aware
  CFI defense). **Stock clang does not emit it** — a vanilla `counter` frame
  would be a few bytes smaller and have the awaiter/locals shifted up. It's shown
  here because it's what *this* toolchain produces; ignore it when reasoning
  about standard coroutines.

---

## 9. How resume/destroy actually dispatch

`handle.resume()` compiles to a two-instruction sequence — **dereference the
handle to get the frame, then call through `frame[0]`**:

```asm
; std::coroutine_handle<…>::resume()   (rdi = &handle)
movq  (%rdi), %rdi      ; rdi = *handle = frame pointer
jmpq  *(%rdi)           ; tail-call frame[0] (the resume stub), with rdi = frame
```

`destroy()` is identical but calls through `frame[8]`. That single
`jmpq *(%rdi)` (or `call`) is an **indirect call whose target is loaded straight
out of the heap frame**, with no type check beyond whatever generic CFI the build
happens to apply. (The companion doc shows that mainstream CFI and Intel CET do
*not* cover this edge.)

The resume stub, once entered, uses the index (field 8) to `switch` to the
correct continuation — so "resume" is really "call `frame[0]`, which jumps to the
block selected by `frame`'s index."

---

## 10. `from_promise` and the fixed promise offset

`std::coroutine_handle<P>::promise()` and `from_promise()` convert between the
frame pointer and the promise — and the promise is at a **fixed +16**:

```llvm
; promise()      : frame -> promise
%1 = getelementptr inbounds i8, ptr %0,   i64 16    ; promise = frame + 16

; from_promise(p): promise -> frame
%0 = getelementptr inbounds i8, ptr %__p, i64 -16   ; frame = promise - 16
```

That `16` is **not** computed from the real frame; `CoroEarly` lowers these
against a hardcoded mock layout `{ptr, ptr, i8}`, so the promise is *always* at
offset 16 regardless of the actual promise type. This is the ABI invariant that
forces the resume/destroy pointers to stay at 0/8 and the promise at 16 — and why
any extra header field (our TypeID) must go *after* the promise, never before it.

---

## 11. Allocation, elision, and why we pin frames to the heap

The frame is normally heap-allocated (`operator new`, the `_Znwm(48)` above) and
freed by `destroy()` (`operator delete`). Two optimizations interact with this:

- **HALO (Heap-Allocation eLision Optimization)**, done by `CoroElide`: if the
  compiler can prove a coroutine's frame never outlives its caller (typical for a
  coroutine that is created, driven, and destroyed within one function, after
  inlining), it **elides `operator new` and places the frame in the caller's
  stack frame**. The `@llvm.coro.alloc` intrinsic (§6) is the hook for this
  decision.
- **Inlining** is what usually exposes that proof.

For studying the frame (and for the attacks, which need the frame in writable
heap memory at a knowable address), we compile with **`-O1 -fno-inline`**:
optimized enough to produce clean, realistic IR, but with inlining off so HALO
cannot fire and frames stay on the heap. At `-O2` with elision, a short-lived
coroutine may have *no* heap frame at all.

---

## 12. One resume, end to end

Putting it together, here is the second `g.handle.resume()` in `main`:

1. `main` holds `g.handle` = the frame pointer `F` returned by the ramp.
2. `resume()` executes `movq (F_addr),%rdi` → `rdi = F`, then `jmpq *(F)` →
   calls `counter.resume(F)`.
3. `counter.resume` loads the index from `F+44` (say it's 1, "after the first
   `co_yield`"), `switch`es to that block.
4. That block reloads `x` from `F+36`, runs `x += i`, computes the next
   `co_yield` → stores `value` into the promise at `F+16`, bumps the index, and
   executes `llvm.coro.suspend` → returns out of the stub back to `main`.
5. `main` sees `done()` is still false, reads `g.handle.promise().value`
   (`*(int*)(F+16)`), prints it, and loops.

At no point is there a separate stack for the coroutine; step 3–4 run on
`main`'s stack and all continuity comes from `F`.

---

## 13. Reproduce it yourself

```bash
CL=~/workspace/llvm-build/bin/clang++        # or any clang++ >= 16
# raw coroutine intrinsics (pre-lowering):
$CL -std=c++20 -O1 -fno-inline -S -emit-llvm -Xclang -disable-llvm-passes counter.cpp -o pre.ll
# after CoroSplit — frame type + ramp + .resume/.destroy stubs:
$CL -std=c++20 -O1 -fno-inline -S -emit-llvm counter.cpp -o post.ll
grep 'Frame = type' post.ll                   # the frame struct
# assembly (see the movq/jmpq resume dispatch):
$CL -std=c++20 -O1 -fno-inline -S counter.cpp -o counter.s
```

Useful greps on `post.ll`: `define .*\.resume`, `_Znwm` (the `operator new`
size), `getelementptr .*Frame` (every frame access), `coro.` (any leftover
intrinsics after lowering — there should be essentially none).

---

*Toolchain: clang/LLVM 18.1.8. The `TypeID` field at +20 is this project's
addition; everything else is standard clang coroutine lowering. For the security
analysis built on this layout, see
[coroutine-cfop-defenses.md](coroutine-cfop-defenses.md).*
