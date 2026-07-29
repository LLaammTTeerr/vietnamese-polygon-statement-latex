.PHONY: help test clean

help:
	@echo "make test   — run the statement-template test suite"
	@echo "make clean  — remove build artefacts"
	@echo
	@echo "Run a single case:  tests/run.sh <case-name>"
	@echo "Cases live in tests/cases/."

test:
	@tests/run.sh

clean:
	rm -rf build
