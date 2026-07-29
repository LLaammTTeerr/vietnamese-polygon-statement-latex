#!/usr/bin/env bash
#
# Statement-template test runner.
#
# Each directory under tests/cases/ is one case, and contains either:
#
#   body.tex   a statement body, compiled inside the preamble named by
#              tests/config.sh, then checked by assert.sh
#   lint.sh    a static check over repository files, with no compilation
#
# Optional per-case files:
#
#   opts       package options, replacing the default from tests/config.sh
#   preamble   a preamble overriding tests/config.sh, for harness self-tests
#   engine     an engine overriding tests/config.sh
#
# Usage: tests/run.sh [case-name ...]

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck source=tests/config.sh
source tests/config.sh
# shellcheck source=tests/lib/assert.sh
source tests/lib/assert.sh

BUILD="$ROOT/build/tests"
mkdir -p "$BUILD"

# Let the engine find olymp.sty / vnolymp.sty from the repository root.
export TEXINPUTS="$ROOT:$ROOT/tex:"

if [[ $# -gt 0 ]]; then
    CASES=()
    for name in "$@"; do CASES+=("tests/cases/$name"); done
else
    mapfile -t CASES < <(find tests/cases -mindepth 1 -maxdepth 1 -type d | sort)
fi

total=0; passed=0
# Must be initialised: under `set -u` an empty, never-assigned array is
# unbound, so a fully passing run would itself fail.
FAILED_CASES=()

bold=$'\e[1m'; red=$'\e[31m'; grn=$'\e[32m'; dim=$'\e[2m'; off=$'\e[0m'
[[ -t 1 ]] || { bold=""; red=""; grn=""; dim=""; off=""; }

for dir in "${CASES[@]}"; do
    [[ -d "$dir" ]] || { echo "no such case: $dir" >&2; exit 2; }

    CASE_NAME="$(basename "$dir")"
    CASE_BUILD="$BUILD/$CASE_NAME"
    ASSERT_FAILURES=()
    total=$((total + 1))

    # A case that cannot assert anything must never report success. Without
    # this, a missing assert.sh leaves ASSERT_FAILURES empty and the case
    # passes silently — a green result that checked nothing at all.
    if [[ ! -f "$dir/lint.sh" && ! -f "$dir/assert.sh" ]]; then
        FAILED_CASES+=("$CASE_NAME")
        printf '%s  FAIL%s  %s\n' "$red" "$off" "$CASE_NAME"
        printf '%s        case has neither lint.sh nor assert.sh%s\n' "$dim" "$off"
        continue
    fi

    if [[ -f "$dir/lint.sh" ]]; then
        # Static check: no compilation, assertions run directly.
        # shellcheck disable=SC1090
        source "$dir/lint.sh"
    else
        rm -rf "$CASE_BUILD"; mkdir -p "$CASE_BUILD"

        engine="$DEFAULT_ENGINE"
        [[ -f "$dir/engine" ]] && engine="$(tr -d '[:space:]' < "$dir/engine")"

        preamble="$DEFAULT_PREAMBLE"
        [[ -f "$dir/preamble" ]] && preamble="tests/$(tr -d '[:space:]' < "$dir/preamble")"

        opts="$DEFAULT_OPTS"
        [[ -f "$dir/opts" ]] && opts="$(tr -d '\n' < "$dir/opts")"

        # Assemble the document: preamble with options substituted, then body.
        sed "s/%%OPTS%%/$opts/" "$preamble" > "$CASE_BUILD/doc.tex"
        {
            echo '\begin{document}'
            echo '\contest{Kỳ thi thử}{Hà Nội}{2026}'
            cat "$dir/body.tex"
            echo '\end{document}'
        } >> "$CASE_BUILD/doc.tex"

        # Case assets (sample files, images) live beside body.tex.
        find "$dir" -maxdepth 1 -type f \
             ! -name 'body.tex' ! -name 'assert.sh' ! -name 'opts' \
             ! -name 'preamble' ! -name 'engine' \
             -exec cp {} "$CASE_BUILD/" \;

        ( cd "$CASE_BUILD" && "$engine" -interaction=nonstopmode \
              -halt-on-error doc.tex >engine.stdout 2>&1 )
        CASE_EXIT=$?

        CASE_PDF="$CASE_BUILD/doc.pdf"
        CASE_LOG="$CASE_BUILD/doc.log"
        CASE_TEXT="$CASE_BUILD/doc.txt"
        # Layout mode preserves column structure, which plain extraction
        # destroys — it emits a table column-first, so a row's cells end up far
        # apart and nothing can assert that a given row reads as it should.
        CASE_LAYOUT="$CASE_BUILD/doc.layout.txt"
        if [[ -f "$CASE_PDF" ]]; then
            pdftotext "$CASE_PDF" "$CASE_TEXT" 2>/dev/null
            pdftotext -layout "$CASE_PDF" "$CASE_LAYOUT" 2>/dev/null
        fi

        export CASE_NAME CASE_BUILD CASE_PDF CASE_LOG CASE_TEXT CASE_LAYOUT CASE_EXIT
        # shellcheck disable=SC1090
        source "$dir/assert.sh"
    fi

    if [[ ${#ASSERT_FAILURES[@]} -eq 0 ]]; then
        passed=$((passed + 1))
        printf '%s  PASS%s  %s\n' "$grn" "$off" "$CASE_NAME"
    else
        FAILED_CASES+=("$CASE_NAME")
        printf '%s  FAIL%s  %s\n' "$red" "$off" "$CASE_NAME"
        for f in "${ASSERT_FAILURES[@]}"; do
            printf '%s        %s%s\n' "$dim" "$f" "$off"
        done
    fi
done

echo
if [[ ${#FAILED_CASES[@]} -eq 0 ]]; then
    printf '%s%d/%d cases passed%s\n' "$bold$grn" "$passed" "$total" "$off"
    exit 0
else
    printf '%s%d/%d cases passed — failed: %s%s\n' \
        "$bold$red" "$passed" "$total" "${FAILED_CASES[*]}" "$off"
    exit 1
fi
