/*
 * sched_victim.cpp — CFOP Primitive 3: dangling handle in a scheduler queue
 * =========================================================================
 * Realistic bug: an async scheduler keeps coroutine_handles in a ready-queue
 * for later resumption. The owning object is torn down (frame freed) while its
 * handle is still queued — a dangling queued handle. The attacker's staged
 * input reclaims the freed frame, so when the scheduler later pops and resumes
 * that handle, the indirect call through frame[0] lands on attacker code.
 *
 * This is the temporal variant that makes coroutines special: a suspended
 * coroutine is a long-lived, serialized continuation sitting in the heap /
 * a scheduler queue — unlike an ephemeral stack frame.
 *
 * Protocol (127.0.0.1:4446):
 *   INFO          leak frame/hijack_target (assumed info leak)
 *   STAGE <hex>   write bytes into the reclaimed frame (attacker-controlled)
 *   RUN           scheduler pops the queued handle and resumes it
 */
#include "cfop_common.h"
#include <cstdlib>
#include <deque>
#include <sys/socket.h>
#include <netinet/in.h>

static constexpr uint16_t PORT = 4446;
static std::deque<std::coroutine_handle<>> ready_queue;

static Task worker() {
    fprintf(stderr, "[VICTIM] worker: running, suspended and queued for later\n");
    co_await std::suspend_always{};
    fprintf(stderr, "[VICTIM] worker: resumed by scheduler on the legit path\n");
}

static void handle_client(int fd) {
    FILE *rx = fdopen(dup(fd), "r");
    FILE *tx = fdopen(fd, "w");
    if (!rx || !tx) { close(fd); return; }

    ready_queue.clear();

    // Create + park a worker, then schedule its handle for later resumption.
    Task t = worker();
    t.handle.resume();
    void  *frame = t.handle.address();
    size_t sz    = chunk_size(frame);
    ready_queue.push_back(t.handle);          // handle now lives in the queue

    // BUG: the owning Task is torn down (frame freed) while its handle is still
    // queued -> a dangling queued handle. The staging buffer allocated next
    // reclaims the freed frame chunk.
    t.handle.destroy();
    t.handle = nullptr;
    char *reclaim = new char[sz];
    memset(reclaim, 0, sz);

    fprintf(tx, "READY sched_victim pid=%d\n", getpid()); fflush(tx);
    fprintf(stderr, "[VICTIM] frame=%p usable=%zu reclaim=%p %s\n",
            frame, sz, (void *)reclaim,
            reclaim == frame ? "(reclaimed freed frame)" : "(did NOT reclaim)");

    char line[8192];
    while (fgets(line, sizeof line, rx)) {
        line[strcspn(line, "\r\n")] = '\0';
        if (!line[0]) continue;

        if (!strcmp(line, "INFO")) {
            fprintf(tx, "OK\nframe %p\nhijack_target %p\nEND\n",
                    frame, (void *)&hijack_target);

        } else if (!strncmp(line, "STAGE ", 6)) {
            const char *hex = line + 6;
            size_t n = strlen(hex) / 2; if (n > sz) n = sz;
            for (size_t i = 0; i < n; i++) {
                unsigned v = 0; sscanf(hex + i * 2, "%2x", &v); reclaim[i] = (char)v;
            }
            fprintf(tx, "OK staged %zu bytes into the reclaimed frame\n", n);
            fprintf(stderr, "[VICTIM] staged %zu bytes into reclaimed frame\n", n);

        } else if (!strcmp(line, "RUN")) {
            if (ready_queue.empty()) { fprintf(tx, "ERR queue empty\n"); }
            else {
                auto h = ready_queue.front(); ready_queue.pop_front();
                fprintf(stderr, "[VICTIM] scheduler resuming queued handle %p...\n",
                        h.address());
                h.resume();                   // dangling -> frame[0] (attacker)
                fprintf(tx, "OK\n");
            }

        } else if (!strcmp(line, "QUIT")) { fprintf(tx, "OK bye\n"); break; }
        else fprintf(tx, "ERR unknown\n");
        fflush(tx);
    }
    fclose(rx); fclose(tx);   // leak `reclaim` (holds the frame image)
}

int main() {
    fprintf(stderr, "=== CFOP Primitive 3: dangling handle in scheduler queue ===\n");
    int srv = socket(AF_INET, SOCK_STREAM, 0);
    int one = 1; setsockopt(srv, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one);
    sockaddr_in sa = {}; sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = htonl(INADDR_LOOPBACK); sa.sin_port = htons(PORT);
    if (bind(srv, (sockaddr *)&sa, sizeof sa) < 0) { perror("bind"); return 1; }
    listen(srv, 1);
    fprintf(stderr, "[VICTIM] Listening on 127.0.0.1:%u pid=%d\n\n", PORT, getpid());
    for (int fd; (fd = accept(srv, nullptr, nullptr)) >= 0; ) {
        fprintf(stderr, "[VICTIM] client connected\n");
        handle_client(fd);
        fprintf(stderr, "[VICTIM] client disconnected\n\n");
    }
    return 0;
}
