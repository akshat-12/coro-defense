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

# ── Defended build (Coroutine-Aware CFI) ───────────────────────────────────────
# Must use the clang we rebuilt with the TypeID-after-promise frame change, and
# load the CFI pass plugin so resume/destroy go through the read-only dispatch
# table.  Override on the command line if your paths differ, e.g.:
#   make victim_cfi DEFCLANG=/path/to/clang++ PLUGIN=/path/to/CoroDefensePlugin.so
DEFCLANG := $(HOME)/workspace/llvm-build/bin/clang++
PLUGIN   := ../passes/build/CoroDefensePlugin.so
OPT      := $(HOME)/workspace/llvm-build/bin/opt
RUNTIME  := $(HOME)/workspace/coro-defense/runtime/build

# Victim variant binaries (all names must be defined before any target below
# references them — make expands prerequisites at parse time).
VICTIM_CFI    := victim_cfi
VICTIM_SHADOW := victim_shadow
VICTIM_BOTH   := victim_both

.PHONY: all defended shadow both variants \
        run_victim run_victim_cfi run_victim_shadow run_victim_both \
        run_attack run_attack_1 run_attack_2 run_attack_3 run_attack_4 \
        run_attack_5 demo ir clean help

all: $(VICTIM) $(ATTACKER)

defended: $(VICTIM_CFI) $(ATTACKER)

# Build all four victim variants (plus the attacker):
#   victim_server  — vulnerable, no defense
#   victim_cfi     — Coroutine-Aware CFI only
#   victim_shadow  — Shadow Stack only
#   victim_both    — CFI + Shadow Stack
variants: $(VICTIM) $(VICTIM_CFI) $(VICTIM_SHADOW) $(VICTIM_BOTH) $(ATTACKER)
	@echo ""
	@echo "Built all four victim variants: $(VICTIM) $(VICTIM_CFI) $(VICTIM_SHADOW) $(VICTIM_BOTH)"

# Vulnerable baseline: SAME known-good compiler as the defended variants
# (llvm-build, which has the TypeID-after-promise frame fix so coroutines run),
# but with NO defense pass loaded.  This keeps the frame layout identical across
# all four variants so the ONLY difference is the defense — note the stock
# clang++ on PATH (llvm-install) is a stale build that mis-lowers coroutines and
# crashes, so we deliberately do not use it here.
$(VICTIM): victim_server.cpp
	$(DEFCLANG) $(CXXFLAGS) $(VICTIM_FLAGS) -o $@ $<
	@echo "Built: $@  (vulnerable baseline, no defense)"

$(VICTIM_CFI): victim_server.cpp
	$(DEFCLANG) $(CXXFLAGS) $(VICTIM_FLAGS) -fpass-plugin=$(PLUGIN) -o $@ $<
	@echo "Built: $@  (Coroutine-Aware CFI enabled)"

run_victim_cfi: $(VICTIM_CFI)
	@echo "Starting DEFENDED victim server on 127.0.0.1:4444 …"
	./$(VICTIM_CFI)

# ── Shadow-only build (Shadow Stack, no CFI) ───────────────────────────────────
# Loading the plugin with -fpass-plugin ALWAYS auto-runs CoroAwareCFIPass (it is
# registered on the OptimizerLast extension point), so a plain clang build can
# never give us the Shadow Stack by itself.  To get the shadow stack ALONE we go
# through opt and explicitly select only the "coro-shadow-analysis" pass, then
# link against the shadow-stack runtime (libcoroshadow.a).
# Override paths on the command line if yours differ, e.g.:
#   make shadow OPT=/path/to/opt RUNTIME=/path/to/runtime/build
shadow: $(VICTIM_SHADOW) $(ATTACKER)

$(VICTIM_SHADOW): victim_server.cpp
	$(DEFCLANG) $(CXXFLAGS) $(VICTIM_FLAGS) -emit-llvm -S -o victim_shadow.ll $<
	$(OPT) -load-pass-plugin=$(PLUGIN) -passes="coro-shadow-analysis" \
	       -S victim_shadow.ll -o victim_shadow_opt.ll
	$(DEFCLANG) -g victim_shadow_opt.ll -o $@ -L$(RUNTIME) -lcoroshadow -lpthread
	@echo "Built: $@  (Shadow Stack only, no CFI)"

run_victim_shadow: $(VICTIM_SHADOW)
	@echo "Starting SHADOW-STACK victim server on 127.0.0.1:4444 …"
	./$(VICTIM_SHADOW)

# ── Both defenses (CFI + Shadow Stack) ─────────────────────────────────────────
# Same opt-based route as the shadow-only build, but we select BOTH passes.
# Order matters: coro-aware-cfi runs first (it replaces the raw indirect
# resume/destroy calls with __coro_dispatch_* calls), then coro-shadow-analysis
# wraps those dispatch calls with register/verify.  Links the shadow runtime.
both: $(VICTIM_BOTH) $(ATTACKER)

$(VICTIM_BOTH): victim_server.cpp
	$(DEFCLANG) $(CXXFLAGS) $(VICTIM_FLAGS) -emit-llvm -S -o victim_both.ll $<
	$(OPT) -load-pass-plugin=$(PLUGIN) \
	       -passes="coro-aware-cfi,coro-shadow-analysis" \
	       -S victim_both.ll -o victim_both_opt.ll
	$(DEFCLANG) -g victim_both_opt.ll -o $@ -L$(RUNTIME) -lcoroshadow -lpthread
	@echo "Built: $@  (Coroutine-Aware CFI + Shadow Stack)"

run_victim_both: $(VICTIM_BOTH)
	@echo "Starting CFI+SHADOW victim server on 127.0.0.1:4444 …"
	./$(VICTIM_BOTH)

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
	rm -f $(VICTIM) $(VICTIM_CFI) $(VICTIM_SHADOW) $(VICTIM_BOTH) $(ATTACKER) \
	      victim_pre.ll victim_post.ll victim_cfi.ll \
	      victim_shadow.ll victim_shadow_opt.ll \
	      victim_both.ll victim_both_opt.ll

help:
	@echo "Targets:"
	@echo "  all          Build victim_server (vulnerable) and attacker"
	@echo "  defended     Build victim_cfi    (Coroutine-Aware CFI only)"
	@echo "  shadow       Build victim_shadow (Shadow Stack only)"
	@echo "  both         Build victim_both   (CFI + Shadow Stack)"
	@echo "  variants     Build all four victim variants + attacker"
	@echo "  run_victim[_cfi|_shadow|_both]  Start a given victim (foreground)"
	@echo "  run_attack   Run all five attacks against a running victim"
	@echo "  run_attack_N Run only attack N (1–5)"
	@echo "  demo         Full automated demo (victim in background)"
	@echo "  ir           Dump LLVM IR before and after coroutine lowering"
	@echo "  clean        Remove built files"
