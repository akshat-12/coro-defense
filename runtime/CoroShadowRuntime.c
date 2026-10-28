/*
 * CoroShadowRuntime.c — coroutine-frame shadow stack
 * ==================================================
 * Keeps a trusted copy of every live coroutine frame in a write-protected
 * region and checks the live frame against that copy on each resume/destroy.
 *
 * The copy is the WHOLE frame, not just the resume/destroy pointers, so this
 * also catches data-only attacks (e.g. flipping an `is_admin` bool spilled in
 * the frame) that control-flow defenses (CFI) cannot see.
 *
 * A coroutine frame legitimately changes as it runs (suspend index, locals),
 * so the snapshot is refreshed at every suspend boundary:
 *   register  — once, when the frame is created (parked at initial_suspend)
 *   update    — after each legitimate resume returns (parked again)
 *   verify    — before each resume/destroy; the frame must still equal the
 *               last snapshot. An attacker writes while the coroutine is
 *               suspended, i.e. exactly in the window verify guards.
 *
 * The shadow region is protected with Intel MPK (pkey_mprotect + a protection
 * key toggled by the cheap userspace WRPKRU via pkey_set); if MPK is not
 * available it falls back to page-level mprotect. Either way the region is
 * read-only except during the brief, locked windows when we write a snapshot,
 * so the attacker's arbitrary write cannot corrupt the shadow itself.
 */

#define _GNU_SOURCE
#include <malloc.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

// ── Configuration
// ────────────────────────────────────────────────────────────
#define SHADOW_LOG2_CAP 12u
#define SHADOW_CAPACITY (1u << SHADOW_LOG2_CAP) // 4096 slots
#define SHADOW_MASK (SHADOW_CAPACITY - 1u)
#define MAX_FRAME 256u // bytes snapshotted per frame

// ── Entry layout
// ──────────────────────────────────────────────────────────────
typedef struct __attribute__((aligned(64))) {
    uintptr_t frame_ptr; // key (0 = empty)
    uint32_t flags;
    uint32_t snap_len;           // bytes of `snapshot` that are valid
    uint8_t snapshot[MAX_FRAME]; // trusted copy of the frame
} ShadowEntry;

#define FLAG_OCCUPIED (1u << 0)

// ── Shadow store state ──────────────────────────────────────────────────────
// The table lives in protected memory. The lock, region pointer, and key live
// in ordinary BSS so they are always writable.
static void *g_region = NULL;
static ShadowEntry *g_table = NULL;
static size_t g_region_sz = 0;
static int g_pkey = -1; // >=0 when MPK is in use
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

// ── Protection toggling
// ───────────────────────────────────────────────────────
static void make_writable(void) {
    if (g_pkey >= 0)
        pkey_set(g_pkey, 0);
    else
        mprotect(g_region, g_region_sz, PROT_READ | PROT_WRITE);
}
static void make_readonly(void) {
    if (g_pkey >= 0)
        pkey_set(g_pkey, PKEY_DISABLE_WRITE);
    else
        mprotect(g_region, g_region_sz, PROT_READ);
}

// ── Initialisation
// ────────────────────────────────────────────────────────────
__attribute__((constructor)) static void shadow_init(void) {
    long pgsz = sysconf(_SC_PAGESIZE);
    size_t want = SHADOW_CAPACITY * sizeof(ShadowEntry);
    g_region_sz = (want + (size_t)pgsz - 1) & ~((size_t)pgsz - 1);

    g_region = mmap(NULL,
                    g_region_sz,
                    PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS,
                    -1,
                    0);
    if (g_region == MAP_FAILED) {
        perror("[CoroShadow] mmap");
        abort();
    }
    memset(g_region, 0, g_region_sz);
    g_table = (ShadowEntry *)g_region;

    // Try Intel MPK first.
    g_pkey = pkey_alloc(0, 0);
    if (g_pkey >= 0 &&
        pkey_mprotect(g_region, g_region_sz, PROT_READ | PROT_WRITE, g_pkey) !=
            0) {
        pkey_free(g_pkey);
        g_pkey = -1;
    }

    make_readonly();
    fprintf(stderr,
            "[CoroShadow] shadow stack ready (%s, %u slots, %u B/frame)\n",
            g_pkey >= 0 ? "MPK" : "mprotect fallback",
            SHADOW_CAPACITY,
            MAX_FRAME);
}

// ── Hashing / probing
// ───────────────────────────────────────────────────────── Fibonacci hashing
// spreads 16-byte-aligned frame pointers evenly.
static size_t shadow_hash(uintptr_t p) {
    return (size_t)((p * UINT64_C(11400714819323198485)) >>
                    (64 - SHADOW_LOG2_CAP));
}

// Linear probing; returns the slot for `key` (occupied) or the first empty
// one.
static ShadowEntry *find_slot(uintptr_t key) {
    size_t idx = shadow_hash(key);
    for (size_t i = 0; i < SHADOW_CAPACITY; i++) {
        size_t s = (idx + i) & SHADOW_MASK;
        if (!(g_table[s].flags & FLAG_OCCUPIED))
            return &g_table[s];
        if (g_table[s].frame_ptr == key)
            return &g_table[s];
    }
    return NULL; // table full
}

// How many bytes of this frame to shadow. malloc_usable_size keeps us inside
// the heap allocation (no out-of-bounds read); MAX_FRAME caps entry size.
static uint32_t frame_len(void *frame) {
    size_t us = malloc_usable_size(frame);
    if (us == 0)
        us = 64; // conservative fallback
    if (us > MAX_FRAME)
        us = MAX_FRAME;
    return (uint32_t)us;
}

// ── Public API
// ────────────────────────────────────────────────────────────────

// Snapshot a freshly created frame (parked at initial_suspend). Injected at
// the end of the coroutine's ramp, after all header fields (resume/destroy
// pointers, promise, TypeID) are initialised.
void __coro_shadow_register(void *frame) {
    uintptr_t key = (uintptr_t)frame;
    uint32_t len = frame_len(frame);

    pthread_mutex_lock(&g_lock);
    make_writable();
    ShadowEntry *slot = find_slot(key);
    if (!slot) {
        fprintf(stderr, "[CoroShadow] FATAL: table full\n");
        abort();
    }
    slot->frame_ptr = key;
    slot->snap_len = len;
    slot->flags = FLAG_OCCUPIED;
    memcpy(slot->snapshot, frame, len);
    make_readonly();
    pthread_mutex_unlock(&g_lock);
}

// Refresh the snapshot after a legitimate resume (the frame has advanced to
// its next suspend point). Injected right after each resume call site.
void __coro_shadow_update(void *frame) {
    uintptr_t key = (uintptr_t)frame;

    pthread_mutex_lock(&g_lock);
    ShadowEntry *slot = find_slot(key);
    if (slot && (slot->flags & FLAG_OCCUPIED) && slot->frame_ptr == key) {
        make_writable();
        memcpy(slot->snapshot, frame, slot->snap_len);
        make_readonly();
    }
    pthread_mutex_unlock(&g_lock);
}

// Report a tampered frame and die. `off0`/`off8` are the live vs. snapshot
// resume/destroy pointers, used only to make the message specific.
static void report_and_abort(const char *when,
                             void *frame,
                             ShadowEntry *slot,
                             int is_resume) {
    size_t ptr_off = is_resume ? 0 : 8;
    void *live = NULL, *snap = NULL;
    memcpy(&live, (char *)frame + ptr_off, sizeof live);
    memcpy(&snap, slot->snapshot + ptr_off, sizeof snap);
    if (live != snap) {
        fprintf(stderr,
                "[CoroShadow] ATTACK: %s_fn tampered on frame %p\n"
                "  expected %p  got %p\n",
                is_resume ? "resume" : "destroy",
                frame,
                snap,
                live);
    } else {
        fprintf(stderr,
                "[CoroShadow] ATTACK: frame data tampered on %p before %s "
                "(no pointer touched — a data-only attack the shadow still "
                "catches)\n",
                frame,
                when);
    }
    abort();
}

// Called before every handle.resume().
void __coro_shadow_verify_resume(void *frame) {
    uintptr_t key = (uintptr_t)frame;
    ShadowEntry *slot = find_slot(key); // lock-free read (region is RO)
    if (!slot || !(slot->flags & FLAG_OCCUPIED) || slot->frame_ptr != key) {
        fprintf(
            stderr,
            "[CoroShadow] ATTACK: unregistered frame %p passed to resume()\n",
            frame);
        abort();
    }
    if (memcmp(frame, slot->snapshot, slot->snap_len) != 0)
        report_and_abort("resume", frame, slot, /*is_resume=*/1);
}

// Called before every handle.destroy(); verifies then removes the entry
// (the frame is about to be freed).
void __coro_shadow_verify_and_remove_destroy(void *frame) {
    uintptr_t key = (uintptr_t)frame;
    ShadowEntry *slot = find_slot(key);
    if (!slot || !(slot->flags & FLAG_OCCUPIED) || slot->frame_ptr != key) {
        fprintf(
            stderr,
            "[CoroShadow] ATTACK: unregistered frame %p passed to destroy()\n",
            frame);
        abort();
    }
    if (memcmp(frame, slot->snapshot, slot->snap_len) != 0)
        report_and_abort("destroy", frame, slot, /*is_resume=*/0);

    // Remove the entry and repair the probe chain.
    pthread_mutex_lock(&g_lock);
    make_writable();
    memset(slot, 0, sizeof *slot);
    size_t hole = (size_t)(slot - g_table);
    for (size_t i = 1; i < SHADOW_CAPACITY; i++) {
        size_t next = (hole + i) & SHADOW_MASK;
        if (!(g_table[next].flags & FLAG_OCCUPIED))
            break;
        ShadowEntry tmp = g_table[next];
        memset(&g_table[next], 0, sizeof tmp);
        size_t ideal = shadow_hash(tmp.frame_ptr) & SHADOW_MASK;
        for (size_t j = 0; j < SHADOW_CAPACITY; j++) {
            size_t s = (ideal + j) & SHADOW_MASK;
            if (!(g_table[s].flags & FLAG_OCCUPIED)) {
                g_table[s] = tmp;
                break;
            }
        }
    }
    make_readonly();
    pthread_mutex_unlock(&g_lock);
}
