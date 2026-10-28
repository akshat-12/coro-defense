/**
 * victim_server.cpp  —  CFOP Demo: Victim Process
 * =================================================
 * A coroutine-based TCP server with a deliberately injected
 * arbitrary-write vulnerability, modelling a heap overflow or UAF primitive.
 *
 * The server exposes a line-based protocol on 127.0.0.1:4444 so an external
 * attacker process can:
 *   INFO   — leak addresses of live coroutine frames + code pointers
 *   WRITE  — write arbitrary bytes to any victim address (the vuln)
 *   TRIGGER — execute code paths that resume/destroy those frames
 *
 * Build:
 *   clang++/g++ -std=c++20 -O1 -fno-inline -g -o victim_server victim_server.cpp
 *
 * NOTE: -fno-inline prevents HALO (heap-allocation elision) so that
 * coroutine frames stay on the heap where the attacker can find them.
 */

#include <coroutine>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <exception>
#include <utility>
#include <sys/socket.h>
#include <netinet/in.h>
#include <cstdint>
#include <unistd.h>

static constexpr uint16_t PORT = 4444;

// ─────────────────────────────────────────────────────────────────────────────
// §1  Task type
// ─────────────────────────────────────────────────────────────────────────────

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
    Task()                      noexcept : handle(nullptr) {}
    Task(Task &&o)              noexcept : handle(o.handle) { o.handle = nullptr; }
    Task &operator=(Task &&o)   noexcept {
        if (handle) handle.destroy();
        handle = o.handle; o.handle = nullptr;
        return *this;
    }
    Task(const Task &)            = delete;
    Task &operator=(const Task &) = delete;
    ~Task() { if (handle) handle.destroy(); }
};

// ─────────────────────────────────────────────────────────────────────────────
// §2  Hijack target  (§gadget in a real ROP chain / execve in a real exploit)
//
// Lives in the victim's .text segment.  The attacker learns its address via
// INFO (simulating a code-pointer leak / ASLR bypass) and redirects any
// coroutine frame to it using the WRITE primitive.
// ─────────────────────────────────────────────────────────────────────────────

[[gnu::noinline]]
static void hijack_target(void *frame) {
    fprintf(stderr,
        "\n[VICTIM] ╔══════════════════════════════════════════════╗\n"
        "[VICTIM] ║  HIJACK_TARGET executing inside victim PID %-4d║\n"
        "[VICTIM] ╠══════════════════════════════════════════════╣\n"
        "[VICTIM] ║  In a real exploit: execve / ROP chain.     ║\n"
        "[VICTIM] ╚══════════════════════════════════════════════╝\n",
        getpid());
    FILE *f = popen("id", "r");
    if (f) { char buf[128]=""; fread(buf,1,127,f); pclose(f);
              fprintf(stderr, "[VICTIM]  id → %s", buf); }
    // Null the resume slot so done() returns true and callers don't re-enter.
    if (frame) { void *nul = nullptr; memcpy(frame, &nul, sizeof nul); }
}

// ─────────────────────────────────────────────────────────────────────────────
// §3  Live coroutines
// ─────────────────────────────────────────────────────────────────────────────

// ── 3a. Worker — target for attacks 1, 2, 4, 5 ───────────────────────────────
static Task worker_coro(int id) {
    fprintf(stderr, "[VICTIM] Worker-%d: running, suspended at checkpoint A\n", id);
    co_await std::suspend_always{};   // ← ATTACK WINDOW

    fprintf(stderr, "[VICTIM] Worker-%d: resumed past A\n", id);
    co_await std::suspend_always{};

    fprintf(stderr, "[VICTIM] Worker-%d: completed\n", id);
    co_return;
}

// ── 3b. Privileged coroutine — target for attack 3 (DOA) ─────────────────────
static volatile bool  *g_is_admin_ptr  = nullptr;
static bool            g_privileged_ran = false;

static Task privileged_coro() {
    volatile bool is_admin = false;
    g_is_admin_ptr = &is_admin;          // expose for INFO leak

    fprintf(stderr, "[VICTIM] PrivCoro: checking credentials, now suspended\n");
    co_await std::suspend_always{};      // ← ATTACK WINDOW: write is_admin here

    g_is_admin_ptr = nullptr;

    if (is_admin) {
        fprintf(stderr,
            "[VICTIM] PrivCoro: *** ACCESS GRANTED (is_admin=true) ***\n");
        FILE *f = popen("id", "r");
        if (f) { char buf[128]=""; fread(buf,1,127,f); pclose(f);
                  fprintf(stderr, "[VICTIM] PrivCoro:  privileged id → %s", buf); }
        g_privileged_ran = true;
    } else {
        fprintf(stderr, "[VICTIM] PrivCoro: access denied (is_admin=false)\n");
    }
    co_return;
}

// ─────────────────────────────────────────────────────────────────────────────
// §4  State visible to the attacker via INFO
// ─────────────────────────────────────────────────────────────────────────────

// A plain coroutine_handle<> (internally a single void*) the attacker can
// redirect by writing 8 bytes at &g_redirectable_handle.
static std::coroutine_handle<> g_redirectable_handle{};

// Writable scratch buffer — attacker stages a fake coroutine frame here.
alignas(16) static uint8_t g_scratch_buf[512];

// Owning pointers for the live coroutines.
// NOTE: we create coroutines on the stack first and then move to heap because
// GCC 13 has a bug where perfect-forwarding a coroutine return value through
// a template (e.g. make_unique) can corrupt the frame pointer.
static Task *g_worker = nullptr;
static Task *g_priv   = nullptr;

static void reset_state() {
    delete g_worker; g_worker = nullptr;
    delete g_priv;   g_priv   = nullptr;
    g_redirectable_handle = {};
    g_privileged_ran      = false;
    memset(g_scratch_buf, 0, sizeof g_scratch_buf);

    // Create worker: stack → heap → resume past initial_suspend.
    { auto tmp = worker_coro(1); g_worker = new Task(std::move(tmp)); }
    g_worker->handle.resume();   // suspended at checkpoint A

    void *wf = g_worker->handle.address();
    uint32_t tid = 0;
    memcpy(&tid, (char*)wf + 16, sizeof(tid));
    fprintf(stderr, "[DEBUG] worker TypeID at frame+16 = %u\n", tid);

    void *pf = g_priv->handle.address();
    memcpy(&tid, (char*)pf + 16, sizeof(tid));
    fprintf(stderr, "[DEBUG] priv   TypeID at frame+16 = %u\n", tid);

    // Create privileged coro: same safe pattern.
    { auto tmp = privileged_coro(); g_priv = new Task(std::move(tmp)); }
    g_priv->handle.resume();     // suspended at co_await (g_is_admin_ptr set)

    // Point the redirectable handle at the worker frame.
    g_redirectable_handle = g_worker->handle;

    fprintf(stderr, "[VICTIM] State reset. worker_frame=%p\n",
            g_worker->handle.address());
}

// ─────────────────────────────────────────────────────────────────────────────
// §5  THE VULNERABILITY: arbitrary write anywhere in victim memory
// ─────────────────────────────────────────────────────────────────────────────

static void vuln_write_anywhere(void *dest, const uint8_t *src, size_t n) {
    memcpy(dest, src, n);   // ← this IS the vulnerability
}

// ─────────────────────────────────────────────────────────────────────────────
// §6  Protocol handler
// ─────────────────────────────────────────────────────────────────────────────

static void handle_client(int fd) {
    FILE *rx = fdopen(dup(fd), "r");
    FILE *tx = fdopen(fd,      "w");
    if (!rx || !tx) { close(fd); return; }

    fprintf(tx, "READY victim_server pid=%d\n", getpid());
    fflush(tx);

    char line[4096];
    while (fgets(line, sizeof line, rx)) {
        line[strcspn(line, "\r\n")] = '\0';
        if (!line[0]) continue;
        fprintf(stderr, "[VICTIM] ← \"%s\"\n", line);

        // ── INFO ─────────────────────────────────────────────────────────────
        if (strcmp(line, "INFO") == 0) {
            void *wf = g_worker->handle.address();
            void (*rfn)(void*)=nullptr, (*dfn)(void*)=nullptr;
            memcpy(&rfn, (char*)wf + 0, 8);
            memcpy(&dfn, (char*)wf + 8, 8);
            fprintf(tx,
                "OK\n"
                "worker_frame   %p\n"
                "resume_fn      %p\n"
                "destroy_fn     %p\n"
                "hijack_target  %p\n"
                "is_admin_ptr   %p\n"
                "scratch_buf    %p\n"
                "handle_store   %p\n"
                "END\n",
                wf, (void*)rfn, (void*)dfn,
                (void*)hijack_target,
                (void*)g_is_admin_ptr,
                (void*)g_scratch_buf,
                (void*)&g_redirectable_handle);

        // ── WRITE <hex_addr> <n> <hex_data> ──────────────────────────────────
        } else if (strncmp(line, "WRITE ", 6) == 0) {
            unsigned long long raw = 0; int n = 0; char hex[1025]="00";
            int got = sscanf(line+6, "%llx %d %1024s", &raw, &n, hex);
            if (got < 2) { fprintf(tx, "ERR bad WRITE\n"); }
            else {
                uint8_t data[512]={};
                for (int i=0; i<n && i<512; i++) {
                    unsigned v=0; sscanf(hex+i*2,"%2x",&v); data[i]=(uint8_t)v;
                }
                vuln_write_anywhere((void*)(uintptr_t)raw, data, (size_t)n);
                fprintf(tx, "OK wrote %d bytes to 0x%llx\n", n, raw);
                fprintf(stderr, "[VICTIM] Wrote %d bytes to 0x%llx\n", n, raw);
            }

        // ── TRIGGER commands ──────────────────────────────────────────────────
        } else if (strcmp(line, "TRIGGER RESUME") == 0) {
            if (!g_worker->handle || g_worker->handle.done())
                fprintf(tx, "ERR worker done\n");
            else { g_worker->handle.resume(); fprintf(tx, "OK\n"); }

        } else if (strcmp(line, "TRIGGER DESTROY") == 0) {
            if (!g_worker->handle) { fprintf(tx, "ERR null handle\n"); }
            else {
                auto h = g_worker->handle; g_worker->handle = nullptr;
                h.destroy(); fprintf(tx, "OK\n");
            }

        } else if (strcmp(line, "TRIGGER PRIVILEGED") == 0) {
            if (!g_priv->handle || g_priv->handle.done())
                fprintf(tx, "ERR priv done\n");
            else {
                g_priv->handle.resume();
                fprintf(tx, "OK privileged_ran=%s\n",
                        g_privileged_ran ? "true" : "false");
            }

        } else if (strcmp(line, "TRIGGER FAKE") == 0) {
            if (!g_redirectable_handle || g_redirectable_handle.done())
                fprintf(tx, "ERR handle null/done\n");
            else {
                fprintf(stderr, "[VICTIM] Resuming g_redirectable_handle "
                                "(may be redirected by attacker)...\n");
                g_redirectable_handle.resume();
                fprintf(tx, "OK\n");
            }

        // ── RESET / QUIT ──────────────────────────────────────────────────────
        } else if (strcmp(line, "RESET") == 0) {
            reset_state(); fprintf(tx, "OK\n");
        } else if (strcmp(line, "QUIT") == 0) {
            fprintf(tx, "OK bye\n"); break;
        } else {
            fprintf(tx, "ERR unknown: %s\n", line);
        }
        fflush(tx);
    }
    fclose(rx); fclose(tx);
}

// ─────────────────────────────────────────────────────────────────────────────
// §7  main
// ─────────────────────────────────────────────────────────────────────────────
int main() {
    fprintf(stderr,
        "╔══════════════════════════════════════════════════════════════╗\n"
        "║  CFOP Demo — Victim Server (DELIBERATELY VULNERABLE)        ║\n"
        "╚══════════════════════════════════════════════════════════════╝\n");

    reset_state();

    int srv = socket(AF_INET, SOCK_STREAM, 0);
    { int o=1; setsockopt(srv,SOL_SOCKET,SO_REUSEADDR,&o,sizeof o); }

    struct sockaddr_in sa={};
    sa.sin_family=AF_INET; sa.sin_addr.s_addr=htonl(INADDR_LOOPBACK);
    sa.sin_port=htons(PORT);
    if (bind(srv,(struct sockaddr*)&sa,sizeof sa)<0) { perror("bind"); return 1; }
    listen(srv,1);
    fprintf(stderr,"[VICTIM] Listening on 127.0.0.1:%u  pid=%d\n\n",PORT,getpid());

    for (;;) {
        int fd = accept(srv, nullptr, nullptr);
        if (fd < 0) break;
        fprintf(stderr, "[VICTIM] Client connected\n");
        handle_client(fd);
        fprintf(stderr, "[VICTIM] Client disconnected\n\n");
        reset_state();
    }
    close(srv); delete g_worker; delete g_priv;
    return 0;
}
