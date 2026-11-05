#!/usr/bin/env bash
# measuring_overhead.sh — measure coroutine-defense overhead with perf-stat hardware
# counters (retired instructions / cycles per op), which are deterministic and
# immune to the code-alignment and CPU-frequency noise that corrupts wall-clock
# ns at the single-digit-ns scale.
#
# Per-op counts are isolated with the DELTA method: run the same binary at N and
# 2N iterations and subtract, which cancels all fixed startup/teardown cost so
# the result is exactly the per-iteration work.
set -u
cd "$(dirname "$0")"

PIN=""; command -v taskset >/dev/null && PIN="taskset -c 2"
VARIANTS=(measuring_overhead measuring_overhead_cfi measuring_overhead_shadow measuring_overhead_both measuring_overhead_cfibaseline measuring_overhead_cet)
LABELS=(vulnerable cfi shadow both cfibaseline cet)
MODES=(resume createdestroy)
declare -A N=( [resume]=2000000 [createdestroy]=500000 )   # delta uses N and 2N
REPS=3                                                      # perf repeats; min taken

echo "== building overhead-measurement variants =="
make -C measuring_overhead variants >/tmp/measuring_overhead_build.log 2>&1 || { echo "build failed:"; cat /tmp/measuring_overhead_build.log; exit 1; }
echo "   ok (pin: ${PIN:-none})"

# ── pick a working perf event set ─────────────────────────────────────────────
EVENTS=""
if command -v perf >/dev/null; then
    for ev in "instructions,cycles" "instructions:u,cycles:u"; do
        v=$($PIN perf stat -x, -e "$ev" ./measuring_overhead/measuring_overhead resume 1000 2>&1 >/dev/null \
              | awk -F, '$3 ~ /instructions/ {print $1}')
        case "$v" in ''|*[!0-9]*) ;; *) EVENTS="$ev"; break;; esac
    done
fi
if [ -z "$EVENTS" ]; then
    echo ""
    echo "!! perf hardware counters unavailable (not installed, or perf_event_paranoid too high)."
    echo "   Enable with:  sudo sysctl kernel.perf_event_paranoid=1   (or run this under sudo)."
    echo "   Falling back to wall-clock ns/op (noisy at this scale)."
    PERF=0
else
    echo "   perf events: $EVENTS"
    PERF=1
fi

# instr,cycles for one run (min of REPS); echoes "<instr> <cycles>"
perf_counts() {  # $1=bin $2=mode $3=iters
    local bin=$1 mode=$2 iters=$3 bi=1e18 bc=1e18 i c out
    for _ in $(seq 1 "$REPS"); do
        out=$($PIN perf stat -x, -e "$EVENTS" "./$bin" "$mode" "$iters" 2>&1 >/dev/null)
        i=$(echo "$out" | awk -F, '$3 ~ /instructions/ {print $1}')
        c=$(echo "$out" | awk -F, '$3 ~ /cycles/        {print $1}')
        [ -n "$i" ] && bi=$(awk -v a="$i" -v b="$bi" 'BEGIN{print (a<b)?a:b}')
        [ -n "$c" ] && bc=$(awk -v a="$c" -v b="$bc" 'BEGIN{print (a<b)?a:b}')
    done
    echo "$bi $bc"
}

# ns/op (10-run average) — kept as a noisy reference
ns_avg() { local bin=$1 mode=$2 it=$3
    for _ in $(seq 1 10); do $PIN "./$bin" "$mode" "$it" 2>/dev/null | sed -n 's/.*NS_PER_OP=//p'; done \
      | awk '{s+=$1;n++} END{if(n) printf "%.2f", s/n; else print "NA"}'; }

hdr() { printf "%-14s" "$1"; shift; for l in "$@"; do printf "%12s" "$l"; done; echo
        printf -- "--------------------------------------------------------------------------------------------\n"; }

declare -A INSTR CYC
if [ "$PERF" = 1 ]; then
    for mode in "${MODES[@]}"; do
        n=${N[$mode]}; n2=$((n*2))
        for i in "${!VARIANTS[@]}"; do
            read i1 c1 < <(perf_counts "measuring_overhead/${VARIANTS[$i]}" "$mode" "$n")
            read i2 c2 < <(perf_counts "measuring_overhead/${VARIANTS[$i]}" "$mode" "$n2")
            INSTR["${LABELS[$i]},$mode"]=$(awk -v a="$i2" -v b="$i1" -v n="$n" 'BEGIN{printf "%.1f",(a-b)/n}')
            CYC["${LABELS[$i]},$mode"]=$(awk   -v a="$c2" -v b="$c1" -v n="$n" 'BEGIN{printf "%.1f",(a-b)/n}')
        done
    done

    echo ""; echo "== A) retired INSTRUCTIONS per op  (deterministic — the true cost of the defense) =="
    hdr "mode" "${LABELS[@]}"
    for mode in "${MODES[@]}"; do printf "%-14s" "$mode"
        for l in "${LABELS[@]}"; do printf "%12s" "${INSTR[$l,$mode]}"; done; echo; done

    echo ""; echo "== B) CYCLES per op  (frequency-independent at fixed clock; still layout-sensitive) =="
    hdr "mode" "${LABELS[@]}"
    for mode in "${MODES[@]}"; do printf "%-14s" "$mode"
        for l in "${LABELS[@]}"; do printf "%12s" "${CYC[$l,$mode]}"; done; echo; done

    echo ""; echo "== C) overhead vs vulnerable, by INSTRUCTIONS/op (%) =="
    hdr "mode" "${LABELS[@]}"
    for mode in "${MODES[@]}"; do printf "%-14s" "$mode"
        base=${INSTR[vulnerable,$mode]}
        for l in "${LABELS[@]}"; do
            printf "%12s" "$(awk -v a="${INSTR[$l,$mode]}" -v b="$base" 'BEGIN{if(b>0)printf "%+.1f%%",(a/b-1)*100; else print "NA"}')"
        done; echo; done
fi

echo ""; echo "== D) wall-clock ns/op (reference — NOISY: code alignment & CPU frequency dominate here) =="
hdr "mode" "${LABELS[@]}"
for mode in "${MODES[@]}"; do printf "%-14s" "$mode"
    for v in "${VARIANTS[@]}"; do printf "%12s" "$(ns_avg "measuring_overhead/$v" "$mode" "${N[$mode]}")"; done; echo; done

echo ""
echo "Notes:"
echo "  * INSTRUCTIONS/op (A) is the trustworthy figure: deterministic, isolates the defense's"
echo "    extra work. cfibaseline uses thinLTO (different pipeline) so it is NOT comparable."
echo "  * ns/op (D) at ~6 ns is dominated by code alignment — a defense can look faster purely"
echo "    from where its loop lands in memory; use A, not D, for the overhead claim."