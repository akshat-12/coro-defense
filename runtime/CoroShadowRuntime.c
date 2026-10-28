#include <sys/mman.h>
#include <pthread.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// ── Configuration ────────────────────────────────────────────────────────────
#define SHADOW_LOG2_CAP  14u
#define SHADOW_CAPACITY  (1u << SHADOW_LOG2_CAP)   // 16384 slots
#define SHADOW_MASK      (SHADOW_CAPACITY - 1u)

// ── Entry layout (64 bytes = one cache line) ──────────────────────────────────
typedef struct __attribute__((aligned(64))) {
    uintptr_t  frame_ptr;           //  0: key
    void      (*expected_resume)(void*);  //  8
    void      (*expected_destroy)(void*); // 16
    uint32_t   expected_type_id;    // 24
    uint32_t   flags;               // 28
    uintptr_t  _pad[4];             // 32..63
} ShadowEntry;

#define FLAG_OCCUPIED (1u << 0)

// ── Shadow store state ────────────────────────────────────────────────────────
// The table lives in protected memory. The lock and region pointer live in
// BSS so they are always writable (even when the table is PROT_READ).
static void          *g_region   = NULL;
static ShadowEntry   *g_table    = NULL;
static size_t         g_region_sz = 0;
static int            g_prot      = PROT_READ | PROT_WRITE;
static pthread_mutex_t g_lock     = PTHREAD_MUTEX_INITIALIZER;

// ── Initialisation ────────────────────────────────────────────────────────────
__attribute__((constructor))
static void shadow_init(void) {
    long pgsz = sysconf(_SC_PAGESIZE);
    size_t want = SHADOW_CAPACITY * sizeof(ShadowEntry);
    g_region_sz = (want + (size_t)pgsz - 1) & ~((size_t)pgsz - 1);

    g_region = mmap(NULL, g_region_sz,
                    PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (g_region == MAP_FAILED) { perror("[CoroShadow] mmap"); abort(); }

    memset(g_region, 0, g_region_sz);
    g_table = (ShadowEntry *)g_region;

    if (mprotect(g_region, g_region_sz, PROT_READ) != 0) {
        perror("[CoroShadow] mprotect"); abort();
    }
    g_prot = PROT_READ;
}

// ── Helpers (call with lock held) ────────────────────────────────────────────
static void make_writable(void) {
    if (g_prot == (PROT_READ | PROT_WRITE)) return;
    mprotect(g_region, g_region_sz, PROT_READ | PROT_WRITE);
    g_prot = PROT_READ | PROT_WRITE;
}
static void make_readonly(void) {
    if (g_prot == PROT_READ) return;
    mprotect(g_region, g_region_sz, PROT_READ);
    g_prot = PROT_READ;
}

// Fibonacci hashing: distributes 16-byte-aligned pointers evenly.
static size_t shadow_hash(uintptr_t p) {
    return (size_t)((p * UINT64_C(11400714819323198485)) >> (64 - SHADOW_LOG2_CAP));
}

// Linear probing. Returns pointer to slot (occupied or empty).
// Safe to call without the lock ONLY when the region is PROT_READ
// (i.e., during verification reads).
static ShadowEntry *find_slot(uintptr_t key) {
    size_t idx = shadow_hash(key);
    for (size_t i = 0; i < SHADOW_CAPACITY; i++) {
        size_t s = (idx + i) & SHADOW_MASK;
        if (!(g_table[s].flags & FLAG_OCCUPIED)) return &g_table[s];
        if (g_table[s].frame_ptr == key)         return &g_table[s];
    }
    return NULL;  // table full
}

// ── Public API ────────────────────────────────────────────────────────────────

// Called from the coroutine's creation stub (ramp function), right after
// the resume/destroy pointers are stored into the new frame.
void __coro_shadow_register(void *frame_ptr) {
    uintptr_t key = (uintptr_t)frame_ptr;
    void (*rfn)(void*), (*dfn)(void*);
    uint32_t tid = 0;
    memcpy(&rfn, (char*)frame_ptr + 0,  sizeof rfn);
    memcpy(&dfn, (char*)frame_ptr + 8,  sizeof dfn);
    memcpy(&tid, (char*)frame_ptr + 16, sizeof tid);

    pthread_mutex_lock(&g_lock);
    make_writable();

    ShadowEntry *slot = find_slot(key);
    if (!slot) { fprintf(stderr, "[CoroShadow] FATAL: table full\n"); abort(); }

    slot->frame_ptr        = key;
    slot->expected_resume  = rfn;
    slot->expected_destroy = dfn;
    slot->expected_type_id = tid;
    slot->flags            = FLAG_OCCUPIED;

    make_readonly();
    pthread_mutex_unlock(&g_lock);
}

// Called before every handle.resume().
void __coro_shadow_verify_resume(void *frame_ptr) {
    uintptr_t key = (uintptr_t)frame_ptr;
    // Lock-free read — region is PROT_READ, no concurrent write in flight.
    ShadowEntry *slot = find_slot(key);

    if (!slot || !(slot->flags & FLAG_OCCUPIED) || slot->frame_ptr != key) {
        fprintf(stderr,
            "[CoroShadow] ATTACK: unregistered frame %p passed to resume()\n",
            frame_ptr);
        abort();
    }
    void (*live)(void*);
    memcpy(&live, (char*)frame_ptr + 0, sizeof live);
    if (live != slot->expected_resume) {
        fprintf(stderr,
            "[CoroShadow] ATTACK: resume_fn tampered on frame %p\n"
            "  expected %p  got %p\n",
            frame_ptr, (void*)slot->expected_resume, (void*)live);
        abort();
    }
    uint32_t live_tid;
    memcpy(&live_tid, (char*)frame_ptr + 16, sizeof live_tid);
    if (slot->expected_type_id && live_tid != slot->expected_type_id) {
        fprintf(stderr,
            "[CoroShadow] ATTACK: TypeID tampered on frame %p "
            "(expected %u got %u)\n",
            frame_ptr, slot->expected_type_id, live_tid);
        abort();
    }
}

// Called before every handle.destroy().
// Verifies AND removes the entry (frame is about to be freed).
void __coro_shadow_verify_and_remove_destroy(void *frame_ptr) {
    uintptr_t key = (uintptr_t)frame_ptr;
    ShadowEntry *slot = find_slot(key);

    if (!slot || !(slot->flags & FLAG_OCCUPIED) || slot->frame_ptr != key) {
        fprintf(stderr,
            "[CoroShadow] ATTACK: unregistered frame %p passed to destroy()\n",
            frame_ptr);
        abort();
    }
    void (*live)(void*);
    memcpy(&live, (char*)frame_ptr + 8, sizeof live);
    if (live != slot->expected_destroy) {
        fprintf(stderr,
            "[CoroShadow] ATTACK: destroy_fn tampered on frame %p\n"
            "  expected %p  got %p\n",
            frame_ptr, (void*)slot->expected_destroy, (void*)live);
        abort();
    }

    // Remove entry before the real destroy frees the frame.
    pthread_mutex_lock(&g_lock);
    make_writable();
    memset(slot, 0, sizeof *slot);
    // Robin-Hood rehash: repair the probe chain.
    size_t hole = (size_t)(slot - g_table);
    for (size_t i = 1; i < SHADOW_CAPACITY; i++) {
        size_t next = (hole + i) & SHADOW_MASK;
        if (!(g_table[next].flags & FLAG_OCCUPIED)) break;
        ShadowEntry tmp = g_table[next];
        memset(&g_table[next], 0, sizeof tmp);
        size_t ideal = shadow_hash(tmp.frame_ptr) & SHADOW_MASK;
        // Re-insert at the closest open slot to ideal.
        for (size_t j = 0; j < SHADOW_CAPACITY; j++) {
            size_t s = (ideal + j) & SHADOW_MASK;
            if (!(g_table[s].flags & FLAG_OCCUPIED)) { g_table[s] = tmp; break; }
        }
    }
    make_readonly();
    pthread_mutex_unlock(&g_lock);
}
