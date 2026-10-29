/*
 * dataonly_victim.cpp — Data-only attack on a coroutine frame (TCP :4447)
 * =======================================================================
 * The privileged coroutine keeps a security decision (`is_admin`) and a small
 * `prefs[]` array spilled in its frame across a suspend. The bug is a classic
 * unchecked indexed write — `prefs[idx] = val` with attacker-controlled idx —
 * so a large/negative idx reaches the `is_admin` byte elsewhere in the frame.
 *
 * No function pointer is touched: this flips a *decision*, not a control-flow
 * target. Control-flow defenses (CFI, CET, our coro-aware CFI) therefore cannot
 * see it; only the whole-frame Shadow Stack catches it (the frame's bytes no
 * longer match the trusted snapshot).
 *
 * Protocol:
 *   INFO              leak prefs/is_admin/hijack_target (assumed info leak)
 *   SETPREF <i> <v>   prefs[i] = v   — the bug (idx unchecked, may be negative)
 *   TRIGGER           resume the privileged coroutine (checks is_admin)
 */
#include "cfop_common.h"
#include <cstdlib>
#include <sys/socket.h>
#include <netinet/in.h>

static constexpr uint16_t PORT = 4447;

static volatile bool *g_is_admin = nullptr;  // &is_admin inside the frame
static uint8_t       *g_prefs    = nullptr;  // &prefs[0] inside the frame
static bool           g_granted  = false;

static Task priv_coro() {
    volatile bool is_admin = false;
    uint8_t       prefs[16] = {};
    g_is_admin = &is_admin;      // escape -> forces both into the frame
    g_prefs    = prefs;
    fprintf(stderr, "[VICTIM] priv: checking credentials, now suspended\n");
    co_await std::suspend_always{};        // attack window: flip is_admin here
    prefs[0] = prefs[0];                    // keep prefs live across the suspend
    if (is_admin) {
        fprintf(stderr, "[VICTIM] priv: *** ACCESS GRANTED (is_admin=true) ***\n");
        g_granted = true;
    } else {
        fprintf(stderr, "[VICTIM] priv: access denied (is_admin=false)\n");
    }
}

static void handle_client(int fd) {
    FILE *rx = fdopen(dup(fd), "r");
    FILE *tx = fdopen(fd, "w");
    if (!rx || !tx) { close(fd); return; }

    g_granted = false;
    Task t = priv_coro();
    t.handle.resume();                      // park at the co_await (sets g_prefs/g_is_admin)

    fprintf(tx, "READY dataonly_victim pid=%d\n", getpid()); fflush(tx);
    fprintf(stderr, "[VICTIM] frame=%p prefs=%p is_admin=%p\n",
            t.handle.address(), (void *)g_prefs, (void *)g_is_admin);

    char line[4096];
    while (fgets(line, sizeof line, rx)) {
        line[strcspn(line, "\r\n")] = '\0';
        if (!line[0]) continue;

        if (!strcmp(line, "INFO")) {
            fprintf(tx, "OK\nprefs %p\nis_admin %p\nhijack_target %p\nEND\n",
                    (void *)g_prefs, (void *)g_is_admin, (void *)&hijack_target);

        } else if (!strncmp(line, "SETPREF ", 8)) {
            long idx = 0; unsigned val = 0;
            if (sscanf(line + 8, "%ld %u", &idx, &val) == 2) {
                g_prefs[idx] = (uint8_t)val;   // <-- BUG: idx unchecked
                fprintf(tx, "OK prefs[%ld]=%u\n", idx, val & 0xff);
                fprintf(stderr, "[VICTIM] prefs[%ld] = %u\n", idx, val & 0xff);
            } else fprintf(tx, "ERR bad SETPREF\n");

        } else if (!strcmp(line, "TRIGGER")) {
            if (!t.handle || t.handle.done()) fprintf(tx, "ERR priv done\n");
            else {
                t.handle.resume();
                fprintf(tx, "OK granted=%s\n", g_granted ? "true" : "false");
            }

        } else if (!strcmp(line, "QUIT")) { fprintf(tx, "OK bye\n"); break; }
        else fprintf(tx, "ERR unknown\n");
        fflush(tx);
    }
    fclose(rx); fclose(tx);
}

int main() {
    fprintf(stderr, "=== CFOP Data-only attack: is_admin flip via frame OOB ===\n");
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
