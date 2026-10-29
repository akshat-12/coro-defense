# Fake-frame injection: redirect a stored coroutine_handle (via a buffer
# overflow) at an attacker-crafted fake frame. (TCP :4448)
include ../common.mk

# Generate rules + *_VARIANTS var before any target that references them.
$(eval $(call build_variants,fakeframe_victim))
$(eval $(call build_attacker,fakeframe_attacker))

.PHONY: all variants run clean
all: fakeframe_victim fakeframe_attacker
variants: $(fakeframe_victim_VARIANTS) fakeframe_attacker

run: fakeframe_victim fakeframe_attacker
	@pkill -9 -x fakeframe_victim 2>/dev/null || true; \
	 ./fakeframe_victim & VP=$$!; sleep 0.5; ./fakeframe_attacker; sleep 0.3; kill $$VP 2>/dev/null || true

clean:
	rm -f $(fakeframe_victim_VARIANTS) fakeframe_attacker $(fakeframe_victim_CLEAN)
