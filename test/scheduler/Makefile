# Primitive 3: dangling handle in a scheduler queue (TCP :4446)
include ../common.mk

# Generate rules + *_VARIANTS var before any target that references them.
$(eval $(call build_variants,sched_victim))
$(eval $(call build_attacker,sched_attacker))

.PHONY: all variants run clean
all: sched_victim sched_attacker
variants: $(sched_victim_VARIANTS) sched_attacker

# Start the vulnerable victim, run the attacker, then stop the victim.
run: sched_victim sched_attacker
	@pkill -9 -x sched_victim 2>/dev/null || true; \
	 ./sched_victim & VP=$$!; sleep 0.5; ./sched_attacker; sleep 0.3; kill $$VP 2>/dev/null || true

clean:
	rm -f $(sched_victim_VARIANTS) sched_attacker $(sched_victim_CLEAN)
