# Performance microbenchmark — built in every defense variant.
include ../common.mk

# Generate the 6 build variants (bench, bench_cfibaseline, bench_cet,
# bench_cfi, bench_shadow, bench_both) before the targets reference them.
$(eval $(call build_variants,bench))

.PHONY: all variants run clean
all: bench
variants: $(bench_VARIANTS)

# Quick sanity run of the vulnerable build.
run: bench
	./bench resume 1000000

clean:
	rm -f $(bench_VARIANTS) $(bench_CLEAN)
