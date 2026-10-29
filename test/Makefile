# Top-level dispatcher for the CFOP benchmarks.
# =============================================
# Each benchmark lives in its own folder with its own Makefile:
#   generic/    didactic arbitrary-write harness, 5 attacks      (:4444)
#   overflow/   Primitive 1: heap overflow into adjacent frame   (:4445)
#   uaf/        Primitive 2: use-after-free reclaim (in-process)
#   scheduler/  Primitive 3: dangling handle in scheduler queue  (:4446)
#   dataonly/   Data-only: flip is_admin in the frame            (:4447)
#   fakeframe/  Fake-frame injection via redirected handle       (:4448)
#
# Usage:
#   make            build the vulnerable victim(s) + attacker(s) in every folder
#   make variants   build every defense/baseline variant everywhere
#   make matrix     build variants, then run the attack x defense table
#   make <folder>   build just that benchmark
#   make clean      clean every folder
# Each folder also works standalone: `cd overflow && make run`.

BENCHES := generic overflow uaf scheduler dataonly fakeframe

.PHONY: all variants matrix clean $(BENCHES)

all:
	@for d in $(BENCHES); do $(MAKE) --no-print-directory -C $$d all; done

variants:
	@for d in $(BENCHES); do $(MAKE) --no-print-directory -C $$d variants; done

matrix: variants
	@./run_matrix.sh

clean:
	@for d in $(BENCHES); do $(MAKE) --no-print-directory -C $$d clean; done

$(BENCHES):
	@$(MAKE) --no-print-directory -C $@ all
