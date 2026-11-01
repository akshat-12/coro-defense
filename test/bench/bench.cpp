/*
 * bench.cpp — microbenchmark for the coroutine-defense overhead
 * =============================================================
 * Isolates the coroutine operations the defenses instrument (create / resume /
 * destroy) so overhead is visible rather than drowned by other work. Built in
 * every variant (vulnerable / cfibaseline / cet / cfi / shadow / both) with the
 * same compiler and flags, so the only difference is the defense.
 *
 *   ./bench <mode> [iters]
 *     resume         one coroutine, resumed N times           (per-resume cost)
 *     createdestroy  create+destroy N frames                  (ramp + destroy)
 *     resume-big     resume N times, frame padded to ~256 B   (snapshot size)
 *     amortized      resume N times with ~work between suspends (realistic %)
 *
 * Prints one machine-readable line to stdout:
 *   MODE=<m> ITERS=<n> NS_PER_OP=<x>
 */
#include "cfop_common.h"
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <string>

static inline double now_ns() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1e9 + (double)ts.tv_nsec;
}

// A coroutine that suspends forever, one co_await per resume.
static Task spin() {
    for (;;) co_await std::suspend_always{};
}

// Same, but keeps a large array live across the suspend so the frame
// approaches MAX_FRAME (256 B) — exercises the shadow's memcpy/memcmp.
static Task spin_big() {
    volatile unsigned char pad[200];
    for (unsigned i = 0;; i++) {
        co_await std::suspend_always{};
        pad[i % sizeof pad]++;   // keep pad live and frame-resident
    }
}

// Does a little work between suspends, so overhead is amortised (realistic).
static Task spin_work() {
    volatile unsigned long acc = 0;
    for (;;) {
        co_await std::suspend_always{};
        for (int i = 0; i < 200; i++) acc += i * 2654435761u;  // ~a few hundred ns
    }
}

// Create + park a coroutine, then let it be destroyed. Returns nothing; the
// Task dtor calls handle.destroy().
static void create_destroy_once() {
    Task t = spin();
    t.handle.resume();   // one resume to leave initial_suspend and park
}

int main(int argc, char **argv) {
    std::string mode = (argc > 1) ? argv[1] : "resume";
    long iters = (argc > 2) ? atol(argv[2]) : 1000000;

    double t0, t1;

    if (mode == "resume" || mode == "resume-big" || mode == "amortized") {
        Task t = (mode == "resume-big") ? spin_big()
               : (mode == "amortized")  ? spin_work()
                                        : spin();
        t.handle.resume();                 // park
        t0 = now_ns();
        for (long i = 0; i < iters; i++) t.handle.resume();
        t1 = now_ns();
        t.handle = nullptr;                // leak (spin never finishes)

    } else if (mode == "createdestroy") {
        t0 = now_ns();
        for (long i = 0; i < iters; i++) create_destroy_once();
        t1 = now_ns();

    } else {
        fprintf(stderr, "unknown mode: %s\n", mode.c_str());
        return 2;
    }

    double ns_per_op = (t1 - t0) / (double)iters;
    printf("MODE=%s ITERS=%ld NS_PER_OP=%.4f\n", mode.c_str(), iters, ns_per_op);
    return 0;
}
