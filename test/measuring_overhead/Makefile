# Coroutine-defense overhead measurement — built in every defense variant.
include ../common.mk

# Generate the 6 build variants before the targets reference them.
$(eval $(call build_variants,measuring_overhead))

.PHONY: all variants run clean
all: measuring_overhead
variants: $(measuring_overhead_VARIANTS)

# Quick sanity run of the vulnerable build.
run: measuring_overhead
	./measuring_overhead resume 1000000

clean:
	rm -f $(measuring_overhead_VARIANTS) $(measuring_overhead_CLEAN)
