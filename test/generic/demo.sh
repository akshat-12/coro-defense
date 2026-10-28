#!/usr/bin/env bash
# demo.sh — Annotated CFOP split-process demo
# ============================================
# Runs the victim server in the background and executes each attack
# one at a time, with explanations between each.
#
# Usage:
#   chmod +x demo.sh && ./demo.sh
#
# Requires: make, clang++, netcat (nc) or the built attacker binary.

set -euo pipefail
cd "$(dirname "$0")"

RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
RST='\033[0m'

# ── Build ──────────────────────────────────────────────────────────────────────
echo -e "${BLU}[demo] Building victim_server and attacker...${RST}"
make -s all
echo ""

# ── Start victim ───────────────────────────────────────────────────────────────
echo -e "${GRN}[demo] Starting victim server in background...${RST}"
./victim_server 2>victim.log &
VICTIM_PID=$!
echo "       PID: $VICTIM_PID  |  log: victim.log"
echo ""

# Give the server a moment to bind.
sleep 0.4

# ── Attack 1 ───────────────────────────────────────────────────────────────────
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo -e "${YEL} ATTACK 1: Resume Pointer Overwrite${RST}"
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo ""
echo "  The attacker leaks the victim's coroutine frame address (INFO),"
echo "  then uses the write-anywhere vulnerability to replace frame[0]"
echo "  (the resume function pointer) with the address of hijack_target."
echo "  The next TRIGGER RESUME makes the victim call hijack_target instead"
echo "  of the legitimate coroutine body."
echo ""
./attacker 1
echo ""
echo -e "${GRN}[demo] Victim log for attack 1:${RST}"
grep -E 'HIJACK|hijack|overwrite|resume' victim.log | tail -10 || true
echo ""
sleep 0.5

# ── Attack 2 ───────────────────────────────────────────────────────────────────
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo -e "${YEL} ATTACK 2: Destroy Pointer Overwrite${RST}"
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo ""
echo "  Same idea, but frame[8] (the destroy pointer) is overwritten."
echo "  The hijack fires when the victim calls handle.destroy() — which"
echo "  happens during normal cleanup and at program exit."
echo ""
./attacker 2
echo ""
sleep 0.5

# ── Attack 3 ───────────────────────────────────────────────────────────────────
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo -e "${YEL} ATTACK 3: Data-Only Attack (DOA)${RST}"
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo ""
echo "  No function pointer is touched.  The attacker uses the INFO leak"
echo "  to find the exact address of 'bool is_admin' inside the heap frame"
echo "  of the privileged coroutine, then writes 0x01 to it."
echo ""
echo "  ${RED}This attack completely bypasses CFI-based defenses.${RST}"
echo "  CFI only protects function pointer call sites; it is blind to"
echo "  data variables that influence control flow."
echo ""
./attacker 3
echo ""
sleep 0.5

# ── Attack 4 ───────────────────────────────────────────────────────────────────
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo -e "${YEL} ATTACK 4: Fake Frame Injection${RST}"
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo ""
echo "  The attacker crafts a fake coroutine frame (containing hijack_target"
echo "  at offset 0) and writes it into victim memory (scratch_buf)."
echo "  Then the attacker overwrites g_redirectable_handle — a coroutine"
echo "  handle stored in the victim's BSS — to point at the fake frame."
echo "  TRIGGER FAKE makes the victim call .resume() on the corrupted handle."
echo ""
./attacker 4
echo ""
sleep 0.5

# ── Attack 5 ───────────────────────────────────────────────────────────────────
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo -e "${YEL} ATTACK 5: Scheduler-Queue CFP${RST}"
echo -e "${YEL}══════════════════════════════════════════════════════${RST}"
echo ""
echo "  Demonstrates that any stored coroutine_handle is a Controlled Frame"
echo "  Pointer.  The attacker poisons the worker frame's resume_fn, then"
echo "  makes the scheduler (TRIGGER FAKE) resume via the poisoned handle."
echo "  In ScyllaDB this would be triggered by the next I/O completion."
echo ""
./attacker 5
echo ""
sleep 0.5

# ── Summary ────────────────────────────────────────────────────────────────────
echo -e "${BLU}══════════════════════════════════════════════════════${RST}"
echo -e "${BLU} SUMMARY${RST}"
echo -e "${BLU}══════════════════════════════════════════════════════${RST}"
echo ""
echo "  All five attacks succeeded using only two cross-process primitives:"
echo "    1. INFO  — read addresses from victim (simulates mem-leak / ASLR bypass)"
echo "    2. WRITE — write bytes to victim addr (simulates heap overflow / UAF)"
echo ""
echo "  Defense status:"
echo "    Attacks 1,2,4,5: blocked by Coroutine-Aware CFI (dispatch table)"
echo "    Attack 3 (DOA):  blocked ONLY by the Shadow Stack (not by CFI)"
echo "    All attacks:     blocked by CFI + Shadow Stack combined"
echo ""

# ── Kill victim ────────────────────────────────────────────────────────────────
echo -e "${BLU}[demo] Stopping victim (PID $VICTIM_PID)...${RST}"
kill "$VICTIM_PID" 2>/dev/null || true
wait "$VICTIM_PID" 2>/dev/null || true
rm -f victim.log
echo "[demo] Done."
