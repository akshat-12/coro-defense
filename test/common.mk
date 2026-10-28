# common.mk — shared config for all CFOP benchmark folders.
# =========================================================
# Each benchmark's Makefile starts with `include ../common.mk`, then calls
# $(call build_variants,<stem>) and $(call build_attacker,<stem>).

# Locate this file (and hence the repo) regardless of the current directory.
_CF_SELF := $(abspath $(lastword $(MAKEFILE_LIST)))
TESTDIR  := $(dir $(_CF_SELF))
ROOT     := $(abspath $(TESTDIR)..)

# ── Toolchain (override on the command line if your paths differ) ─────────────
DEFCLANG ?= $(HOME)/workspace/llvm-build/bin/clang++
OPT      ?= $(HOME)/workspace/llvm-build/bin/opt
CXX      := clang++   # := (not ?=) so make's built-in g++ default doesn't win; CLI still overrides
PLUGIN   ?= $(ROOT)/passes/build/CoroDefensePlugin.so
RUNTIME  ?= $(ROOT)/runtime/build

# ── Flags ──────────────────────────────────────────────────────────────────────
# -O1 -fno-inline keeps coroutine frames on the heap (no HALO elision); -g for
# symbols. INCFLAGS exposes the shared cfop_common.h to every benchmark.
CXXFLAGS           ?= -std=c++20 -Wall -Wextra
VICTIM_FLAGS       ?= -O1 -fno-inline -g
ATTACKER_FLAGS     ?= -O1 -g
CFI_BASELINE_FLAGS ?= -flto=thin -fvisibility=hidden -fsanitize=cfi-icall -fuse-ld=lld
CET_FLAGS          ?= -fcf-protection=full
INCFLAGS           := -I$(TESTDIR)common

# ── build_variants: $(call build_variants,<stem>) ────────────────────────────
# Generates five build rules from <stem>.cpp (a coroutine victim):
#   <stem>              vulnerable baseline (known-good compiler, no defense)
#   <stem>_cfibaseline  stock -fsanitize=cfi-icall (the CFI "Await() a Second" evades)
#   <stem>_cet          Intel CET -fcf-protection=full (IBT + shadow stack)
#   <stem>_cfi          Coroutine-Aware CFI pass (read-only dispatch table)
#   <stem>_shadow       whole-frame Shadow Stack (MPK)
#   <stem>_both         CFI + Shadow
# It also sets <stem>_VARIANTS (all six targets) and <stem>_CLEAN (intermediates).
define build_variants
$(1): $(1).cpp
	$$(DEFCLANG) $$(CXXFLAGS) $$(INCFLAGS) $$(VICTIM_FLAGS) -o $$@ $$<
	@echo "Built: $$@  (vulnerable)"

$(1)_cfibaseline: $(1).cpp
	$$(DEFCLANG) $$(CXXFLAGS) $$(INCFLAGS) $$(VICTIM_FLAGS) $$(CFI_BASELINE_FLAGS) -o $$@ $$<
	@echo "Built: $$@  (stock -fsanitize=cfi-icall baseline)"

$(1)_cet: $(1).cpp
	$$(DEFCLANG) $$(CXXFLAGS) $$(INCFLAGS) $$(VICTIM_FLAGS) $$(CET_FLAGS) -o $$@ $$<
	@echo "Built: $$@  (Intel CET: -fcf-protection=full, IBT+SHSTK)"

$(1)_cfi: $(1).cpp
	$$(DEFCLANG) $$(CXXFLAGS) $$(INCFLAGS) $$(VICTIM_FLAGS) -fpass-plugin=$$(PLUGIN) -o $$@ $$<
	@echo "Built: $$@  (Coroutine-Aware CFI)"

$(1)_shadow: $(1).cpp
	$$(DEFCLANG) $$(CXXFLAGS) $$(INCFLAGS) $$(VICTIM_FLAGS) -emit-llvm -S -o $(1)_shadow.ll $$<
	$$(OPT) -load-pass-plugin=$$(PLUGIN) -passes="coro-shadow-analysis" -S $(1)_shadow.ll -o $(1)_shadow_opt.ll
	$$(DEFCLANG) -g $(1)_shadow_opt.ll -o $$@ -L$$(RUNTIME) -lcoroshadow -lpthread
	@echo "Built: $$@  (Shadow Stack)"

$(1)_both: $(1).cpp
	$$(DEFCLANG) $$(CXXFLAGS) $$(INCFLAGS) $$(VICTIM_FLAGS) -emit-llvm -S -o $(1)_both.ll $$<
	$$(OPT) -load-pass-plugin=$$(PLUGIN) -passes="coro-aware-cfi,coro-shadow-analysis" -S $(1)_both.ll -o $(1)_both_opt.ll
	$$(DEFCLANG) -g $(1)_both_opt.ll -o $$@ -L$$(RUNTIME) -lcoroshadow -lpthread
	@echo "Built: $$@  (CFI + Shadow)"

$(1)_VARIANTS := $(1) $(1)_cfibaseline $(1)_cet $(1)_cfi $(1)_shadow $(1)_both
$(1)_CLEAN    := $(1)_shadow.ll $(1)_shadow_opt.ll $(1)_both.ll $(1)_both_opt.ll
endef

# ── build_attacker: $(call build_attacker,<stem>) ────────────────────────────
# Attackers have no coroutines, so they use the stock host compiler.
define build_attacker
$(1): $(1).cpp
	$$(CXX) $$(CXXFLAGS) $$(INCFLAGS) $$(ATTACKER_FLAGS) -o $$@ $$<
	@echo "Built: $$@"
endef
