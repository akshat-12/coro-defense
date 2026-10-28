# Didactic harness: one coroutine server with a generic arbitrary-write command
# and five attacks (TCP :4444). This is the original, address-transparent demo.
include ../common.mk

ATTACKER := attacker

# Generate rules + *_VARIANTS var before any target that references them.
$(eval $(call build_variants,victim_server))
$(eval $(call build_attacker,attacker))

.PHONY: all variants run run_attack demo ir clean
all: victim_server $(ATTACKER)
variants: $(victim_server_VARIANTS) $(ATTACKER)

# Run all five attacks (run_attack) or a single one (run_attack_N).
run: run_attack
run_attack: victim_server $(ATTACKER)
	@pkill -9 -x victim_server 2>/dev/null || true; \
	 ./victim_server & VP=$$!; sleep 0.5; ./$(ATTACKER) all; sleep 0.3; kill $$VP 2>/dev/null || true
run_attack_%: victim_server $(ATTACKER)
	@pkill -9 -x victim_server 2>/dev/null || true; \
	 ./victim_server & VP=$$!; sleep 0.5; ./$(ATTACKER) $*; sleep 0.3; kill $$VP 2>/dev/null || true

# Annotated walkthrough (builds, runs each attack with explanations).
demo: all
	./demo.sh

# Dump the coroutine-lowering IR (frame struct visible).
ir: victim_server.cpp
	$(DEFCLANG) -std=c++20 -O1 -fno-inline $(INCFLAGS) -emit-llvm -S -o victim_post.ll victim_server.cpp
	@echo "Wrote victim_post.ll  (resume@0, destroy@8, promise@16)"

clean:
	rm -f $(victim_server_VARIANTS) $(ATTACKER) $(victim_server_CLEAN) victim_post.ll victim.log
