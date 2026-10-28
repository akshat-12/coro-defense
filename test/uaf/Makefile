# Primitive 2: Use-After-Free reclaim (in-process PoC)
include ../common.mk

# Generate the build rules (and the *_VARIANTS / *_CLEAN vars) BEFORE any target
# that references them — prerequisites are expanded as the Makefile is parsed.
$(eval $(call build_variants,uaf_poc))

.PHONY: all variants run clean
all: uaf_poc
variants: $(uaf_poc_VARIANTS)

run: uaf_poc
	./uaf_poc

clean:
	rm -f $(uaf_poc_VARIANTS) $(uaf_poc_CLEAN)
