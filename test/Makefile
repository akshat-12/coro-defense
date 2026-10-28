# CFOP Split Demo Makefile
# =========================
# Builds the victim server and the attacker client as separate binaries.
#
# Usage:
#   make               # build both binaries
#   make run_victim    # start the victim in the foreground (leave it running)
#   make run_attack    # in another terminal: run all attacks
#   make run_attack_1  # run only attack 1 (resume overwrite)
#   make demo          # start victim in background + run all attacks, then kill victim

CXX      := clang++
CXXFLAGS := -std=c++20 -Wall -Wextra

# -O1 -fno-inline: keep coroutine frames on the heap (prevent HALO elision).
# -g: retain symbols so you can read the IR and debug.
VICTIM_FLAGS  := -O1 -fno-inline -g
ATTACKER_FLAGS := -O1 -g

VICTIM  := victim_server
ATTACKER := attacker

.PHONY: all run_victim run_attack run_attack_1 run_attack_2 run_attack_3 \
        run_attack_4 run_attack_5 demo ir clean help

all: $(VICTIM) $(ATTACKER)

$(VICTIM): victim_server.cpp
	$(CXX) $(CXXFLAGS) $(VICTIM_FLAGS) -o $@ $<
	@echo "Built: $@"

$(ATTACKER): attacker.cpp
	$(CXX) $(CXXFLAGS) $(ATTACKER_FLAGS) -o $@ $<
	@echo "Built: $@"

# ── Running ───────────────────────────────────────────────────────────────────

run_victim: $(VICTIM)
	@echo "Starting victim server on 127.0.0.1:4444 …"
	@echo "(leave this running; open another terminal and run 'make run_attack')"
	./$(VICTIM)

run_attack: $(ATTACKER)
	./$(ATTACKER) all

run_attack_1: $(ATTACKER)
	./$(ATTACKER) 1

run_attack_2: $(ATTACKER)
	./$(ATTACKER) 2

run_attack_3: $(ATTACKER)
	./$(ATTACKER) 3

run_attack_4: $(ATTACKER)
	./$(ATTACKER) 4

run_attack_5: $(ATTACKER)
	./$(ATTACKER) 5

# ── Full automated demo ────────────────────────────────────────────────────────
# Starts the victim in the background, waits for it to be ready,
# runs all attacks, then kills the victim.
demo: $(VICTIM) $(ATTACKER)
	@echo "=== Starting victim in background ==="
	./$(VICTIM) &
	@VICTIM_PID=$$!; \
	echo "Victim PID: $$VICTIM_PID"; \
	sleep 0.5; \
	echo ""; \
	echo "=== Running all attacks ==="; \
	./$(ATTACKER) all; \
	echo ""; \
	echo "=== Killing victim (PID $$VICTIM_PID) ==="; \
	kill $$VICTIM_PID 2>/dev/null || true

# ── Inspect IR (useful for your LLVM pass) ────────────────────────────────────
# Dump the victim's coroutine-lowering IR at each pipeline stage.
ir_pre: victim_server.cpp
	$(CXX) -std=c++20 -O1 -fno-inline \
	       -emit-llvm -Xclang -disable-llvm-passes \
	       -S -o victim_pre.ll $<
	@echo "Written: victim_pre.ll  (raw coroutine intrinsics)"

ir_post: victim_server.cpp
	$(CXX) -std=c++20 -O1 -fno-inline \
	       -emit-llvm -S -o victim_post.ll $<
	@echo "Written: victim_post.ll  (after CoroSplit — frame struct visible)"

ir: ir_pre ir_post
	@echo ""
	@echo "Look for '.resume' / '.destroy' functions in victim_post.ll."
	@echo "The frame struct is the first argument type of each stub."
	@echo "Offset 0 = resume_fn, offset 8 = destroy_fn — these are what CFOP corrupts."

# ── Clean ─────────────────────────────────────────────────────────────────────
clean:
	rm -f $(VICTIM) $(ATTACKER) victim_pre.ll victim_post.ll

help:
	@echo "Targets:"
	@echo "  all          Build victim_server and attacker"
	@echo "  run_victim   Start the victim server (foreground)"
	@echo "  run_attack   Run all five attacks against a running victim"
	@echo "  run_attack_N Run only attack N (1–5)"
	@echo "  demo         Full automated demo (victim in background)"
	@echo "  ir           Dump LLVM IR before and after coroutine lowering"
	@echo "  clean        Remove built files"
