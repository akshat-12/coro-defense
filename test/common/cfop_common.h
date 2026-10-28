/*
 * cfop_common.h — shared pieces for the realistic CFOP primitive demos
 * ====================================================================
 * Each demo plants a *real* memory-safety bug (heap overflow, use-after-free,
 * or a dangling scheduler handle) and shows that it corrupts a coroutine
 * frame's resume/destroy pointer, which handle.resume()/.destroy() then calls
 * indirectly. The attacker capability is only what the bug gives — plus an
 * assumed info leak for addresses (ASLR defeat), exactly as in
 * "Await() a Second: Evading CFI by Hijacking C++ Coroutines".
 */
#pragma once

#include <coroutine>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <exception>
#include <utility>
#include <unistd.h>
#include <malloc.h>

// ── Task: minimal eager-suspend coroutine ────────────────────────────────────
// ABI-fixed layout: resume@0, destroy@8, promise@16. Do not add fields ahead
// of the promise (coroutine_handle::from_promise relies on offset 16).
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
    std::coroutine_handle<promise_type> handle;

    explicit Task(std::coroutine_handle<promise_type> h) noexcept : handle(h) {}
    Task() noexcept : handle(nullptr) {}
    Task(Task &&o) noexcept : handle(std::exchange(o.handle, nullptr)) {}
    Task &operator=(Task &&o) noexcept {
        if (handle) handle.destroy();
        handle = std::exchange(o.handle, nullptr);
        return *this;
    }
    Task(const Task &)            = delete;
    Task &operator=(const Task &) = delete;
    ~Task() { if (handle) handle.destroy(); }
};

// ── Hijack target ─────────────────────────────────────────────────────────────
// Stands in for a one-gadget/execve. Lives in .text; a corrupted frame[0]/[8]
// is pointed here and handle.resume()/.destroy() jumps to it.
[[gnu::noinline]]
inline void hijack_target(void *frame) {
    fprintf(stderr, "[VICTIM] *** HIJACK_TARGET executing inside PID %d *** "
                    "(would be execve/ROP in a real exploit)\n", getpid());
    if (FILE *f = popen("id", "r")) {
        char buf[128] = "";
        if (fread(buf, 1, sizeof buf - 1, f)) fprintf(stderr, "[VICTIM]  id -> %s", buf);
        pclose(f);
    }
    // Clear the resume slot so a done() check is satisfied and we don't re-enter.
    if (frame) { void *nul = nullptr; memcpy(frame, &nul, sizeof nul); }
}

// Usable size of a heap allocation (used for deterministic reclaim / grooming).
inline size_t chunk_size(void *p) { return malloc_usable_size(p); }

// Read the resume/destroy pointers currently in a frame (for diagnostics).
inline void *frame_resume (void *f) { void *p; memcpy(&p, (char*)f + 0, 8); return p; }
inline void *frame_destroy(void *f) { void *p; memcpy(&p, (char*)f + 8, 8); return p; }
