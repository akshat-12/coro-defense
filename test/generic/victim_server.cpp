/**
 * victim_server.cpp — CFOP demo victim
 * ====================================
 * A coroutine-based TCP server with a deliberately planted arbitrary-write
 * primitive (modelling a heap overflow / use-after-free). Over a line protocol
 * on 127.0.0.1:4444 an external attacker can:
 *
 *   INFO     leak the addresses it needs (live frame, code pointers, buffers)
 *   WRITE    write arbitrary bytes to any victim address   ← the vulnerability
 *   TRIGGER  make the victim resume/destroy a coroutine     ← fires the
 * payload RESET    rebuild the coroutine state
 *
 * The attack: a C++ coroutine frame begins with two function pointers —
 * frame[0] = resume, frame[8] = destroy — that handle.resume()/.destroy()
 * call indirectly. Corrupting either with the WRITE primitive redirects that
 * indirect call. This is CFOP (Coroutine Frame-Oriented Programming).
 *
 * Build with -fno-inline so HALO (heap-allocation elision) is disabled and the
 * frames stay on the heap where the attacker can reach them:
 *   clang++ -std=c++20 -O1 -fno-inline -g -o victim_server victim_server.cpp
 */

#include <coroutine>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <exception>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <utility>

static constexpr uint16_t PORT = 4444;

// ── Task: a minimal eager-suspend coroutine type ────────────────────────────
// Layout is ABI-fixed: the promise sits at frame+16, after the resume/destroy
// pointers at frame+0 and frame+8. Do not add fields ahead of the promise.
struct Task {
    struct promise_type {
        Task get_return_object() noexcept {
            return Task{
                std::coroutine_handle<promise_type>::from_promise(*this)};
        }
        std::suspend_always initial_suspend() noexcept {
            return {};
        }
        std::suspend_always final_suspend() noexcept {
            return {};
        }
        void return_void() noexcept {}
        void unhandled_exception() noexcept {
            std::terminate();
        }
    };
    std::coroutine_handle<promise_type> handle;

    explicit Task(std::coroutine_handle<promise_type> h) noexcept
        : handle(h) {}
    Task() noexcept : handle(nullptr) {}
    Task(Task &&o) noexcept : handle(std::exchange(o.handle, nullptr)) {}
    Task &operator=(Task &&o) noexcept {
        if (handle)
            handle.destroy();
        handle = std::exchange(o.handle, nullptr);
        return *this;
    }
    Task(const Task &) = delete;
    Task &operator=(const Task &) = delete;
    ~Task() {
        if (handle)
            handle.destroy();
    }
};

// ── Hijack target
// ──────────────────────────────────────────────────────────── Stands in for a
// one-gadget / execve in a real exploit. It lives in .text; the attacker leaks
// its address via INFO and points a frame's resume/destroy slot at it. Called
// with the frame pointer, exactly like a real resume stub.
[[gnu::noinline]]
static void hijack_target(void *frame) {
    fprintf(stderr,
            "[VICTIM] HIJACK_TARGET executing inside victim PID %d"
            " (would be execve/ROP in a real exploit)\n",
            getpid());
    if (FILE *f = popen("id", "r")) {
        char buf[128] = "";
        if (fread(buf, 1, sizeof buf - 1, f))
            fprintf(stderr, "[VICTIM]  id -> %s", buf);
        pclose(f);
    }
    // Clear the resume slot so handle.done() is true afterwards and the caller
    // doesn't re-enter a now-inconsistent frame.
    if (frame) {
        void *nul = nullptr;
        memcpy(frame, &nul, sizeof nul);
    }
}

// ── Coroutines under attack
// ────────────────────────────────────────────────── worker_coro: target of
// the control-flow attacks (1, 2, 4, 5).
static Task worker_coro(int id) {
    fprintf(stderr,
            "[VICTIM] Worker-%d: running, suspended at checkpoint A\n",
            id);
    co_await std::suspend_always{}; // attack window
    fprintf(stderr, "[VICTIM] Worker-%d: resumed past A\n", id);
    co_await std::suspend_always{};
    fprintf(stderr, "[VICTIM] Worker-%d: completed\n", id);
}

// privileged_coro: target of the data-only attack (3). `is_admin` lives in the
// heap frame; flipping it needs no corrupted pointer, so control-flow defenses
// cannot see it. volatile keeps the check reading from memory.
static volatile bool *g_is_admin_ptr = nullptr;
static bool g_privileged_ran = false;

static Task privileged_coro() {
    volatile bool is_admin = false;
    g_is_admin_ptr = &is_admin; // exposed via INFO
    fprintf(stderr,
            "[VICTIM] PrivCoro: checking credentials, now suspended\n");
    co_await std::suspend_always{}; // attack window: write is_admin here
    g_is_admin_ptr = nullptr;

    if (is_admin) {
        fprintf(stderr,
                "[VICTIM] PrivCoro: *** ACCESS GRANTED (is_admin=true) ***\n");
        g_privileged_ran = true;
    } else {
        fprintf(stderr, "[VICTIM] PrivCoro: access denied (is_admin=false)\n");
    }
}

// ── Attacker-visible state
// ───────────────────────────────────────────────────
static std::coroutine_handle<>
    g_redirectable_handle{};                   // a bare void*; retargetable
alignas(16) static uint8_t g_scratch_buf[512]; // staging area for a fake frame
static Task *g_worker = nullptr;
static Task *g_priv = nullptr;

static void reset_state() {
    delete g_worker;
    delete g_priv;
    g_redirectable_handle = {};
    g_privileged_ran = false;
    memset(g_scratch_buf, 0, sizeof g_scratch_buf);

    // Build each coroutine and resume once so it parks at its attack window.
    g_worker = new Task(worker_coro(1));
    g_worker->handle.resume(); // suspended at checkpoint A
    g_priv = new Task(privileged_coro());
    g_priv->handle.resume(); // suspended at the credential check

    g_redirectable_handle =
        g_worker->handle; // models a handle in a scheduler queue
    fprintf(stderr,
            "[VICTIM] State reset. worker_frame=%p\n",
            g_worker->handle.address());
}

// ── The vulnerability: an unchecked write to any address
// ─────────────────────
static void vuln_write_anywhere(void *dest, const uint8_t *src, size_t n) {
    memcpy(dest, src, n);
}

// ── Line protocol
// ────────────────────────────────────────────────────────────
static void handle_client(int fd) {
    FILE *rx = fdopen(dup(fd), "r");
    FILE *tx = fdopen(fd, "w");
    if (!rx || !tx) {
        close(fd);
        return;
    }

    fprintf(tx, "READY victim_server pid=%d\n", getpid());
    fflush(tx);

    char line[4096];
    while (fgets(line, sizeof line, rx)) {
        line[strcspn(line, "\r\n")] = '\0';
        if (!line[0])
            continue;
        fprintf(stderr, "[VICTIM] <- \"%s\"\n", line);

        if (strcmp(line, "INFO") == 0) {
            void *wf = g_worker->handle.address();
            void *rfn = nullptr, *dfn = nullptr;
            memcpy(&rfn, (char *)wf + 0, 8); // resume pointer
            memcpy(&dfn, (char *)wf + 8, 8); // destroy pointer
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
                    wf,
                    rfn,
                    dfn,
                    (void *)hijack_target,
                    (void *)g_is_admin_ptr,
                    (void *)g_scratch_buf,
                    (void *)&g_redirectable_handle);

        } else if (strncmp(line, "WRITE ", 6) == 0) {
            unsigned long long addr = 0;
            int n = 0;
            char hex[1025] = "00";
            if (sscanf(line + 6, "%llx %d %1024s", &addr, &n, hex) < 2) {
                fprintf(tx, "ERR bad WRITE\n");
            } else {
                uint8_t data[512] = {};
                for (int i = 0; i < n && i < 512; i++) {
                    unsigned v = 0;
                    sscanf(hex + i * 2, "%2x", &v);
                    data[i] = (uint8_t)v;
                }
                vuln_write_anywhere((void *)(uintptr_t)addr, data, (size_t)n);
                fprintf(tx, "OK wrote %d bytes to 0x%llx\n", n, addr);
                fprintf(
                    stderr, "[VICTIM] Wrote %d bytes to 0x%llx\n", n, addr);
            }

        } else if (strcmp(line, "TRIGGER RESUME") == 0) {
            if (!g_worker->handle || g_worker->handle.done())
                fprintf(tx, "ERR worker done\n");
            else {
                g_worker->handle.resume();
                fprintf(tx, "OK\n");
            }

        } else if (strcmp(line, "TRIGGER DESTROY") == 0) {
            if (!g_worker->handle) {
                fprintf(tx, "ERR null handle\n");
            } else {
                std::exchange(g_worker->handle, nullptr).destroy();
                fprintf(tx, "OK\n");
            }

        } else if (strcmp(line, "TRIGGER PRIVILEGED") == 0) {
            if (!g_priv->handle || g_priv->handle.done())
                fprintf(tx, "ERR priv done\n");
            else {
                g_priv->handle.resume();
                fprintf(tx,
                        "OK privileged_ran=%s\n",
                        g_privileged_ran ? "true" : "false");
            }

        } else if (strcmp(line, "TRIGGER FAKE") == 0) {
            if (!g_redirectable_handle || g_redirectable_handle.done()) {
                fprintf(tx, "ERR handle null/done\n");
            } else {
                fprintf(stderr,
                        "[VICTIM] Resuming g_redirectable_handle (may be "
                        "redirected)...\n");
                g_redirectable_handle.resume();
                fprintf(tx, "OK\n");
            }

        } else if (strcmp(line, "RESET") == 0) {
            reset_state();
            fprintf(tx, "OK\n");
        } else if (strcmp(line, "QUIT") == 0) {
            fprintf(tx, "OK bye\n");
            break;
        } else {
            fprintf(tx, "ERR unknown: %s\n", line);
        }
        fflush(tx);
    }
    fclose(rx);
    fclose(tx);
}

int main() {
    fprintf(stderr, "[VICTIM] CFOP demo victim (DELIBERATELY VULNERABLE)\n");
    reset_state();

    int srv = socket(AF_INET, SOCK_STREAM, 0);
    int one = 1;
    setsockopt(srv, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one);

    sockaddr_in sa = {};
    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    sa.sin_port = htons(PORT);
    if (bind(srv, (sockaddr *)&sa, sizeof sa) < 0) {
        perror("bind");
        return 1;
    }
    listen(srv, 1);
    fprintf(stderr,
            "[VICTIM] Listening on 127.0.0.1:%u  pid=%d\n\n",
            PORT,
            getpid());

    for (int fd; (fd = accept(srv, nullptr, nullptr)) >= 0;) {
        fprintf(stderr, "[VICTIM] Client connected\n");
        handle_client(fd);
        fprintf(stderr, "[VICTIM] Client disconnected\n\n");
        reset_state();
    }
    close(srv);
    delete g_worker;
    delete g_priv;
    return 0;
}
