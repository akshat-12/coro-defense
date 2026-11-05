/*
 * measuring_overhead.cpp — measure coroutine-defense overhead
 * =============================================================
 * Isolates the coroutine operations the defenses instrument (create / resume /
 * destroy) so overhead is visible rather than drowned by other work. Built in
 * every variant (vulnerable / cfibaseline / cet / cfi / shadow / both) with the
 * same compiler and flags, so the only difference is the defense.
 *
 *   ./measuring_overhead <mode> [iters]
 *     resume         one coroutine, resumed N times
 *     createdestroy  create+destroy N frames
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

    if (mode == "resume") {
        Task t = spin();
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
