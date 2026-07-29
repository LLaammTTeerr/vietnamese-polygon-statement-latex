.PHONY: help test samples clean

# vnolymp.sty and its modules live at the repository root, so the engine has to
# be able to find them from inside samples/<name>/.
export TEXINPUTS := $(CURDIR):$(TEXINPUTS)

SAMPLES := $(notdir $(patsubst %/,%,$(wildcard samples/*/)))

help:
	@echo "make test     — run the statement-template test suite"
	@echo "make samples  — build every sample into build/samples/"
	@echo "make clean    — remove build artefacts"
	@echo
	@echo "Run a single case:  tests/run.sh <case-name>"
	@echo "Cases live in tests/cases/; samples in samples/."

test:
	@tests/run.sh

# Two passes, always. The footer's page total and the cover's problem-overview
# table both come from the .aux file written by the previous run; a single pass
# silently produces "??" and an empty table.
samples:
	@mkdir -p build/samples
	@for s in $(SAMPLES); do \
	    echo "  building $$s"; \
	    ( cd samples/$$s && \
	      lualatex -interaction=nonstopmode -halt-on-error $$s.tex >/dev/null && \
	      lualatex -interaction=nonstopmode -halt-on-error $$s.tex >/dev/null ) \
	      || { echo "  FAILED: $$s"; exit 1; }; \
	    cp samples/$$s/$$s.pdf build/samples/; \
	done
	@echo "PDFs in build/samples/"

# Artefacts are removed BY NAME, never by glob. Sample expected-output files
# are also called *.out, and an `rm samples/*/*.out` intended for LaTeX's
# hyperref artefacts has already destroyed them once.
clean:
	rm -rf build
	@for s in $(SAMPLES); do \
	    rm -f samples/$$s/$$s.aux samples/$$s/$$s.log \
	          samples/$$s/$$s.out samples/$$s/$$s.pdf; \
	done
