# Data-only attack: flip a security decision (is_admin) spilled in the frame,
# touching no pointer. Only the whole-frame Shadow Stack catches it. (TCP :4447)
include ../common.mk

# Generate rules + *_VARIANTS var before any target that references them.
$(eval $(call build_variants,dataonly_victim))
$(eval $(call build_attacker,dataonly_attacker))

.PHONY: all variants run clean
all: dataonly_victim dataonly_attacker
variants: $(dataonly_victim_VARIANTS) dataonly_attacker

run: dataonly_victim dataonly_attacker
	@pkill -9 -x dataonly_victim 2>/dev/null || true; \
	 ./dataonly_victim & VP=$$!; sleep 0.5; ./dataonly_attacker; sleep 0.3; kill $$VP 2>/dev/null || true

clean:
	rm -f $(dataonly_victim_VARIANTS) dataonly_attacker $(dataonly_victim_CLEAN)
