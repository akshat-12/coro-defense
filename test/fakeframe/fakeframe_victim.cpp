/*
 * fakeframe_victim.cpp — CFOP fake-frame injection (TCP :4448)
 * ============================================================
 * The attacker does not corrupt a real frame's pointer; it crafts an ENTIRELY
 * fake frame in a buffer it controls and redirects a stored coroutine_handle at
 * it. The bug here is a heap overflow of a Session.buf that overwrites the
 * adjacent stored handle pointer. Resuming that handle then calls the fake
 * frame's resume pointer.
 *
 *   struct Session { char buf[64]; coroutine_handle<> h; };  // h right after buf
 *
 * Protocol:
 *   INFO            leak buf/handle_store/scratch/hijack_target (assumed leak)
 *   STAGE <hex>     write bytes into the scratch buffer (the fake frame)
 *   SEND  <hex>     copy into Session.buf — the bug (overflows into h)
 *   TRIGGER         resume the stored handle
 */
#include "cfop_common.h"
#include <cstdlib>
#include <sys/socket.h>
#include <netinet/in.h>

static constexpr uint16_t PORT = 4448;

struct Session { char buf[64]; std::coroutine_handle<> h; };
alignas(16) static uint8_t g_scratch[256];   // attacker stages the fake frame here

static Task worker() {
    fprintf(stderr, "[VICTIM] worker: running, suspended\n");
    co_await std::suspend_always{};
    fprintf(stderr, "[VICTIM] worker: resumed on the legit path\n");
}

static void handle_client(int fd) {
    FILE *rx = fdopen(dup(fd), "r");
    FILE *tx = fdopen(fd, "w");
    if (!rx || !tx) { close(fd); return; }

    memset(g_scratch, 0, sizeof g_scratch);
    Session *s = new Session();
    memset(s->buf, 0, sizeof s->buf);
    Task t = worker();
    t.handle.resume();            // park worker
    s->h = t.handle;              // legitimate stored handle

    fprintf(tx, "READY fakeframe_victim pid=%d\n", getpid()); fflush(tx);
    fprintf(stderr, "[VICTIM] buf=%p handle_store=%p scratch=%p\n",
            (void *)s->buf, (void *)&s->h, (void *)g_scratch);

    char line[8192];
    while (fgets(line, sizeof line, rx)) {
        line[strcspn(line, "\r\n")] = '\0';
        if (!line[0]) continue;

        if (!strcmp(line, "INFO")) {
            fprintf(tx,
                    "OK\nbuf %p\nhandle_store %p\nscratch %p\nhijack_target %p\nEND\n",
                    (void *)s->buf, (void *)&s->h, (void *)g_scratch,
                    (void *)&hijack_target);

        } else if (!strncmp(line, "STAGE ", 6)) {
            const char *hex = line + 6;
            size_t n = strlen(hex) / 2; if (n > sizeof g_scratch) n = sizeof g_scratch;
            for (size_t i = 0; i < n; i++) {
                unsigned v = 0; sscanf(hex + i * 2, "%2x", &v); g_scratch[i] = (uint8_t)v;
            }
            fprintf(tx, "OK staged %zu bytes of fake frame\n", n);

        } else if (!strncmp(line, "SEND ", 5)) {
            const char *hex = line + 5;
            size_t n = strlen(hex) / 2;
            static uint8_t data[8192];
            for (size_t i = 0; i < n && i < sizeof data; i++) {
                unsigned v = 0; sscanf(hex + i * 2, "%2x", &v); data[i] = (uint8_t)v;
            }
            memcpy(s->buf, data, n);     // <-- BUG: overflows into s->h
            fprintf(tx, "OK copied %zu bytes into a 64-byte buffer\n", n);
            fprintf(stderr, "[VICTIM] copied %zu bytes into Session.buf\n", n);

        } else if (!strcmp(line, "TRIGGER")) {
            if (!s->h || s->h.done()) fprintf(tx, "ERR handle null/done\n");
            else {
                fprintf(stderr, "[VICTIM] resuming stored handle %p...\n", s->h.address());
                s->h.resume();           // may now point at the fake frame
                fprintf(tx, "OK\n");
            }

        } else if (!strcmp(line, "QUIT")) { fprintf(tx, "OK bye\n"); break; }
        else fprintf(tx, "ERR unknown\n");
        fflush(tx);
    }
    fclose(rx); fclose(tx);
    t.handle = nullptr;   // leak worker frame; s->h may be corrupted
}

int main() {
    fprintf(stderr, "=== CFOP Fake-frame injection: redirect a stored handle ===\n");
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
