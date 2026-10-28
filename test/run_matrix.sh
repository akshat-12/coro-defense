#!/usr/bin/env bash
# run_matrix.sh — run each realistic CFOP primitive against every defense variant
# and print the attack x defense table. Expects `make variants` to have built the
# binaries (the top-level `make matrix` target does that first).
set -u
cd "$(dirname "$0")"
LOGDIR="$(mktemp -d)"
trap 'rm -rf "$LOGDIR"' EXIT

classify() {   # $1=logfile  $2=exitcode-or-"live"
  local log="$1" ec="$2"
  grep -q "HIJACK_TARGET executing" "$log" 2>/dev/null && { echo "HIJACKED"; return; }
  grep -qE "frame data tampered|unregistered frame|CoroShadow] ATTACK" "$log" 2>/dev/null && { echo "BLOCK(shadow)"; return; }
  [ "$ec" = "132" ] && { echo "BLOCK(SIGILL)"; return; }
  [ "$ec" = "134" ] && { echo "BLOCK(abort)"; return; }
  echo "neutralized"
}

run_inproc() { # $1=binary path
  local bin="$1" log="$LOGDIR/$(basename "$1").log"
  [ -x "$bin" ] || { echo "MISSING"; return; }
  "$bin" >"$log" 2>&1; classify "$log" "$?"
}

run_net() {    # $1=victim path  $2=attacker path  $3=port
  local bin="$1" att="$2" port="$3" log="$LOGDIR/$(basename "$1").log"
  [ -x "$bin" ] && [ -x "$att" ] || { echo "MISSING"; return; }
  pkill -9 -x "$(basename "$bin")" 2>/dev/null
  for i in $(seq 1 40); do (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null && { exec 3>&-; sleep 0.1; } || break; done
  "$bin" >"$log" 2>&1 & local vp=$!
  for i in $(seq 1 60); do grep -q "Listening on" "$log" 2>/dev/null && break; kill -0 $vp 2>/dev/null || break; sleep 0.05; done
  "$att" >/dev/null 2>&1; sleep 0.4
  local ec
  if kill -0 $vp 2>/dev/null; then kill -9 $vp 2>/dev/null; wait $vp 2>/dev/null; ec=live
  else wait $vp 2>/dev/null; ec=$?; fi
  classify "$log" "$ec"
}

hdr() { printf "%-14s | %-10s %-13s %-12s %-14s %-14s\n" "$@"; }
hdr "PRIMITIVE" "vulnerable" "cfibaseline" "coro-cfi" "shadow" "both"
printf -- "---------------+---------------------------------------------------------------------\n"

printf "%-14s | %-10s %-13s %-12s %-14s %-14s\n" "1 Overflow" \
  "$(run_net overflow/overflow_victim            overflow/overflow_attacker 4445)" \
  "$(run_net overflow/overflow_victim_cfibaseline overflow/overflow_attacker 4445)" \
  "$(run_net overflow/overflow_victim_cfi        overflow/overflow_attacker 4445)" \
  "$(run_net overflow/overflow_victim_shadow     overflow/overflow_attacker 4445)" \
  "$(run_net overflow/overflow_victim_both       overflow/overflow_attacker 4445)"

printf "%-14s | %-10s %-13s %-12s %-14s %-14s\n" "2 UAF" \
  "$(run_inproc uaf/uaf_poc)"             "$(run_inproc uaf/uaf_poc_cfibaseline)" \
  "$(run_inproc uaf/uaf_poc_cfi)"         "$(run_inproc uaf/uaf_poc_shadow)" \
  "$(run_inproc uaf/uaf_poc_both)"

printf "%-14s | %-10s %-13s %-12s %-14s %-14s\n" "3 Scheduler" \
  "$(run_net scheduler/sched_victim            scheduler/sched_attacker 4446)" \
  "$(run_net scheduler/sched_victim_cfibaseline scheduler/sched_attacker 4446)" \
  "$(run_net scheduler/sched_victim_cfi        scheduler/sched_attacker 4446)" \
  "$(run_net scheduler/sched_victim_shadow     scheduler/sched_attacker 4446)" \
  "$(run_net scheduler/sched_victim_both       scheduler/sched_attacker 4446)"

pkill -9 -x overflow_victim 2>/dev/null; pkill -9 -x sched_victim 2>/dev/null
echo ""
echo "HIJACKED = attack succeeded; neutralized = coro-cfi dispatched safely;"
echo "BLOCK(shadow/abort/SIGILL) = defense stopped it."
