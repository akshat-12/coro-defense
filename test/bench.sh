#!/usr/bin/env bash
# bench.sh — measure the per-operation overhead of the coroutine defenses.
# Builds the bench microbenchmark in every variant and reports:
#   A) ns/op (median of R runs) per variant x mode
#   B) overhead vs the vulnerable baseline (%)
#   C) shadow-stack attribution: full vs NO-PROTECT vs mprotect/op
#
# ns/op is wall time per coroutine op; mprotect/op is counted with strace.
# NOTE: on a host without MPK the shadow uses the mprotect fallback, so its
# numbers are syscall-bound (an upper bound); an MPK host would be far lower.
set -u
cd "$(dirname "$0")"

R=5                                  # runs per data point (median)
PIN=""; command -v taskset >/dev/null && PIN="taskset -c 2"
VARIANTS=(bench bench_cfi bench_shadow bench_both bench_cfibaseline bench_cet)
LABELS=(vulnerable cfi shadow both cfibaseline cet)
MODES=(resume createdestroy resume-big amortized)
declare -A ITERS=( [resume]=500000 [createdestroy]=200000 [resume-big]=500000 [amortized]=200000 )

echo "== building bench variants =="
make -C bench variants >/tmp/bench_build.log 2>&1 || { echo "build failed:"; cat /tmp/bench_build.log; exit 1; }
echo "   ok (R=$R runs/point, pin: ${PIN:-none})"

median() { sort -g | awk '{a[NR]=$1} END{ if(NR==0){print "NA"} else if(NR%2){print a[(NR+1)/2]} else {printf "%.2f", (a[NR/2]+a[NR/2+1])/2} }'; }

run_median() {  # $1=binpath $2=mode $3=iters  [$4=env assignment]
    local bin=$1 mode=$2 iters=$3 envv=${4:-}
    for _ in $(seq 1 $R); do
        $PIN env $envv "./$bin" "$mode" "$iters" 2>/dev/null | sed -n 's/.*NS_PER_OP=//p'
    done | median
}

declare -A NS
echo ""
echo "== A) ns per operation (median of $R) =="
printf "%-14s" "mode"; for l in "${LABELS[@]}"; do printf "%12s" "$l"; done; echo
printf -- "--------------------------------------------------------------------------------------------\n"
for mode in "${MODES[@]}"; do
    printf "%-14s" "$mode"
    for i in "${!VARIANTS[@]}"; do
        v="bench/${VARIANTS[$i]}"; [ "${VARIANTS[$i]}" = bench ] && v="bench/bench"
        val=$(run_median "$v" "$mode" "${ITERS[$mode]}")
        NS["${LABELS[$i]},$mode"]=$val
        printf "%12s" "$val"
    done
    echo
done

echo ""
echo "== B) overhead vs vulnerable (%) =="
printf "%-14s" "mode"; for l in "${LABELS[@]}"; do printf "%12s" "$l"; done; echo
printf -- "--------------------------------------------------------------------------------------------\n"
for mode in "${MODES[@]}"; do
    printf "%-14s" "$mode"
    base=${NS[vulnerable,$mode]}
    for l in "${LABELS[@]}"; do
        v=${NS[$l,$mode]}
        pct=$(awk -v a="$v" -v b="$base" 'BEGIN{ if(b>0) printf "%+.1f%%", (a/b-1)*100; else print "NA"}')
        printf "%12s" "$pct"
    done
    echo
done

echo ""
echo "== C) shadow-stack attribution (resume mode) =="
IT=${ITERS[resume]}
sh_full=$(run_median bench/bench_shadow resume "$IT")
sh_nop=$(run_median  bench/bench_shadow resume "$IT" "CORO_SHADOW_NOPROTECT=1")
vuln=${NS[vulnerable,resume]}
cfi=${NS[cfi,resume]}
mprot="n/a"
if command -v strace >/dev/null; then
    n=20000
    calls=$($PIN strace -f -e trace=mprotect "bench/bench_shadow" resume "$n" 2>&1 >/dev/null | grep -c 'mprotect(')
    mprot=$(awk -v c="$calls" -v n="$n" 'BEGIN{printf "%.2f", c/n}')
fi
printf "  vulnerable resume            : %s ns/op\n" "$vuln"
printf "  coro-cfi resume              : %s ns/op\n" "$cfi"
printf "  shadow resume (full)         : %s ns/op\n" "$sh_full"
printf "  shadow resume (NO-PROTECT)   : %s ns/op   <- snapshot cost only\n" "$sh_nop"
printf "  shadow mprotect syscalls/op  : %s\n" "$mprot"
awk -v f="$sh_full" -v np="$sh_nop" -v vz="$vuln" 'BEGIN{
    printf "  => protection (toggle) cost  : ~%.1f ns/op\n", f-np;
    printf "  => snapshot  (memcpy/memcmp) : ~%.1f ns/op\n", np-vz;
}'

echo ""
# Report the ACTUAL protection mode from the runtime's own startup line.
# MPK is the 'pku'/'ospke' CPU feature — independent of CET (ibt/shstk).
mode_line=$("bench/bench_shadow" resume 1 2>&1 >/dev/null | sed -n 's/.*ready (\([^,]*\).*/\1/p')
echo "Note: shadow protection mode on this host: ${mode_line:-unknown}"
if echo "$mode_line" | grep -qi MPK; then
    echo "      MPK (pku) is present, so each toggle is a userspace WRPKRU (no syscall) —"
    echo "      hence mprotect/op ~0 above, and these numbers represent a real MPK deployment."
else
    echo "      mprotect fallback: toggles are syscalls, so the 'protection' component is an"
    echo "      upper bound; a host with MPK (pku) would shrink it by ~an order of magnitude."
fi
