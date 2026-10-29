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
  grep -q "ACCESS GRANTED (is_admin=true)" "$log" 2>/dev/null && { echo "GRANTED(data)"; return; }
  [ "$ec" = "132" ] && { echo "BLOCK(SIGILL)"; return; }
  [ "$ec" = "134" ] && { echo "BLOCK(abort)"; return; }
  [ "$ec" = "139" ] && { echo "BLOCK(SIGSEGV)"; return; }
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

# Columns: the suffix appended to each victim stem (empty = vulnerable).
VARIANTS=("" "_cfibaseline" "_cet" "_cfi" "_shadow" "_both")
FMT="%-14s | %-14s %-14s %-14s %-14s %-14s %-14s\n"

printf "$FMT" "PRIMITIVE" "vulnerable" "cfibaseline" "cet" "coro-cfi" "shadow" "both"
printf -- "---------------+----------------------------------------------------------------------------------------\n"

# 1 Overflow (networked :4445)
row=(); for s in "${VARIANTS[@]}"; do row+=("$(run_net "overflow/overflow_victim$s" overflow/overflow_attacker 4445)"); done
printf "$FMT" "1 Overflow" "${row[@]}"

# 2 UAF (in-process)
row=(); for s in "${VARIANTS[@]}"; do row+=("$(run_inproc "uaf/uaf_poc$s")"); done
printf "$FMT" "2 UAF" "${row[@]}"

# 3 Scheduler (networked :4446)
row=(); for s in "${VARIANTS[@]}"; do row+=("$(run_net "scheduler/sched_victim$s" scheduler/sched_attacker 4446)"); done
printf "$FMT" "3 Scheduler" "${row[@]}"

# 4 Fake-frame injection (networked :4448)
row=(); for s in "${VARIANTS[@]}"; do row+=("$(run_net "fakeframe/fakeframe_victim$s" fakeframe/fakeframe_attacker 4448)"); done
printf "$FMT" "4 Fake-frame" "${row[@]}"

# 5 Data-only is_admin flip (networked :4447)
row=(); for s in "${VARIANTS[@]}"; do row+=("$(run_net "dataonly/dataonly_victim$s" dataonly/dataonly_attacker 4447)"); done
printf "$FMT" "5 Data-only" "${row[@]}"

pkill -9 -x overflow_victim 2>/dev/null; pkill -9 -x sched_victim 2>/dev/null
pkill -9 -x fakeframe_victim 2>/dev/null; pkill -9 -x dataonly_victim 2>/dev/null

# CET enforcement status on this host (IBT/SHSTK are only ENFORCED with CPU+OS support).
cet_hw="$(grep -oE 'user_shstk|shstk|ibt' /proc/cpuinfo 2>/dev/null | sort -u | paste -sd, -)"
echo ""
echo "Legend: HIJACKED = control-flow hijack succeeded; neutralized = coro-cfi dispatched safely;"
echo "        GRANTED(data) = data-only attack succeeded (control-flow defenses are blind to it;"
echo "        only the whole-frame shadow stack blocks it);"
echo "        BLOCK(shadow/abort/SIGILL/SIGSEGV) = a defense stopped it."
echo "Note:   'cet' is compiled with -fcf-protection=full (ELF property IBT,SHSTK)."
if [ -z "$cet_hw" ]; then
  echo "        This CPU exposes no CET feature, so CET is NOT hardware-enforced here."
else
  echo "        This CPU exposes CET: $cet_hw"
fi
echo "        Either way the hijack bypasses IBT by design: the gadget is a legit"
echo "        address-taken function (has endbr64), and the shadow stack guards only"
echo "        returns, not the forward indirect call through the coroutine frame."
