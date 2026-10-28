/*
 * overflow_victim.cpp — CFOP Primitive 1: heap overflow into adjacent frame
 * =========================================================================
 * Realistic bug: an unchecked copy into a fixed heap buffer (classic overflow).
 * The victim grooms the buffer so a live coroutine frame sits just above it, so
 * a forward overflow runs into frame[0] (the resume pointer). Resuming the
 * coroutine then makes the indirect call land on attacker-chosen code.
 *
 * Capability used: a linear, forward, contiguous overflow from one buffer
 * (attacker controls length + contents), plus a leaked code address. No
 * arbitrary write. Networked: the attacker is a separate client.
 *
 * Protocol (127.0.0.1:4445):
 *   INFO            leak buf/frame/hijack_target addresses (assumed info leak)
 *   SEND <hexdata>  copy the bytes into buf — the bug (length unchecked)
 *   RESUME          resume the worker coroutine
 */
#include "cfop_common.h"
#include <cstdlib>
#include <sys/socket.h>
#include <netinet/in.h>

static constexpr uint16_t PORT  = 4445;
static constexpr size_t   BUFSZ = 64;

static Task worker() {
    fprintf(stderr, "[VICTIM] worker: running, suspended at checkpoint\n");
    co_await std::suspend_always{};
    fprintf(stderr, "[VICTIM] worker: resumed on the legit path\n");
}

static void handle_client(int fd) {
    FILE *rx = fdopen(dup(fd), "r");
    FILE *tx = fdopen(fd, "w");
    if (!rx || !tx) { close(fd); return; }

    // Groom: allocate the overflow buffer immediately before the coroutine so
    // the frame lands just above it on the heap.
    char *buf = new char[BUFSZ];
    memset(buf, 0, BUFSZ);
    Task t = worker();
    t.handle.resume();                       // park at checkpoint
    void *frame = t.handle.address();
    long  delta = (long)((char *)frame - buf);

    fprintf(tx, "READY overflow_victim pid=%d\n", getpid()); fflush(tx);
    fprintf(stderr, "[VICTIM] buf=%p frame=%p delta=%ld resume_fn=%p\n",
            (void *)buf, frame, delta, frame_resume(frame));

    char line[8192];
    while (fgets(line, sizeof line, rx)) {
        line[strcspn(line, "\r\n")] = '\0';
        if (!line[0]) continue;

        if (!strcmp(line, "INFO")) {
            fprintf(tx, "OK\nbuf %p\nframe %p\nhijack_target %p\nEND\n",
                    (void *)buf, frame, (void *)&hijack_target);

        } else if (!strncmp(line, "SEND ", 5)) {
            const char *hex = line + 5;
            size_t n = strlen(hex) / 2;
            static uint8_t data[8192];
            for (size_t i = 0; i < n && i < sizeof data; i++) {
                unsigned v = 0; sscanf(hex + i * 2, "%2x", &v); data[i] = (uint8_t)v;
            }
            memcpy(buf, data, n);            // <-- BUG: n may exceed BUFSZ
            fprintf(tx, "OK copied %zu bytes into a %zu-byte buffer\n", n, BUFSZ);
            fprintf(stderr, "[VICTIM] copied %zu bytes into buf (size %zu)\n", n, BUFSZ);

        } else if (!strcmp(line, "RESUME")) {
            if (t.handle && !t.handle.done()) { t.handle.resume(); fprintf(tx, "OK\n"); }
            else fprintf(tx, "ERR done\n");

        } else if (!strcmp(line, "QUIT")) { fprintf(tx, "OK bye\n"); break; }
        else fprintf(tx, "ERR unknown\n");
        fflush(tx);
    }
    fclose(rx); fclose(tx);
    // The overflow corrupted heap metadata between buf and frame; leak both
    // rather than freeing a corrupted chunk (keeps the demo teardown clean).
    t.handle = nullptr;
}

int main() {
    fprintf(stderr, "=== CFOP Primitive 1: heap overflow into adjacent frame ===\n");
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
