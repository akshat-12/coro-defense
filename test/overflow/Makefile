# Primitive 1: heap overflow into an adjacent coroutine frame (TCP :4445)
include ../common.mk

# Generate rules + *_VARIANTS var before any target that references them.
$(eval $(call build_variants,overflow_victim))
$(eval $(call build_attacker,overflow_attacker))

.PHONY: all variants run clean
all: overflow_victim overflow_attacker
variants: $(overflow_victim_VARIANTS) overflow_attacker

# Start the vulnerable victim, run the attacker, then stop the victim.
run: overflow_victim overflow_attacker
	@pkill -9 -x overflow_victim 2>/dev/null || true; \
	 ./overflow_victim & VP=$$!; sleep 0.5; ./overflow_attacker; sleep 0.3; kill $$VP 2>/dev/null || true

clean:
	rm -f $(overflow_victim_VARIANTS) overflow_attacker $(overflow_victim_CLEAN)
