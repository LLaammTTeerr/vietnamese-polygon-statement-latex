# Assertion helpers for the statement-template test suite.
#
# Sourced by tests/run.sh before each case's assert.sh. The following are set
# by the runner and may be used by assertions:
#
#   CASE_NAME       name of the case directory
#   CASE_BUILD      build directory for this case
#   CASE_PDF        path to the produced PDF (may not exist)
#   CASE_LOG        path to the engine log
#   CASE_TEXT       path to pdftotext output (may not exist)
#   CASE_EXIT       engine exit status
#
# Every helper records a failure via `_fail` and returns non-zero rather than
# aborting, so a single case can report several problems in one run.

_fail() {
    ASSERT_FAILURES+=("$1")
    return 1
}

_have_pdf() {
    [[ -f "$CASE_PDF" ]] || return 1
}

# --- compilation -------------------------------------------------------------

assert_compiles() {
    if [[ "$CASE_EXIT" -ne 0 ]] || ! _have_pdf; then
        local detail
        detail=$(grep -m1 -A2 '^! ' "$CASE_LOG" 2>/dev/null | tr '\n' ' ')
        _fail "expected a successful build, but the engine exited ${CASE_EXIT}${detail:+ — ${detail}}"
        return 1
    fi
}

assert_fails_to_compile() {
    if [[ "$CASE_EXIT" -eq 0 ]] && _have_pdf; then
        _fail "expected the build to fail, but it succeeded"
        return 1
    fi
}

# --- PDF text content --------------------------------------------------------
#
# Assertions run against `pdftotext` output. Note that pdftotext joins a
# heading to the following paragraph when the heading does not end a line,
# which is exactly how defect #2 (a section command missing its \section{})
# becomes observable.

assert_pdf_contains() {
    _have_pdf || { _fail "no PDF produced, cannot check for '$1'"; return 1; }
    grep -qF -- "$1" "$CASE_TEXT" \
        || _fail "expected the PDF to contain '$1'"
}

assert_pdf_not_contains() {
    _have_pdf || { _fail "no PDF produced, cannot check absence of '$1'"; return 1; }
    if grep -qF -- "$1" "$CASE_TEXT"; then
        _fail "expected the PDF NOT to contain '$1', but it does"
        return 1
    fi
}

# Asserts a line consisting of exactly this text, ignoring surrounding
# whitespace. Use for headings that must stand alone on their own line.
assert_pdf_has_line() {
    _have_pdf || { _fail "no PDF produced, cannot check line '$1'"; return 1; }
    if ! sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$CASE_TEXT" | grep -qxF -- "$1"; then
        local got
        got=$(grep -m1 -F -- "$1" "$CASE_TEXT" | sed 's/^[[:space:]]*//')
        _fail "expected a line consisting of exactly '$1'${got:+, but found it embedded in: '${got}'}"
        return 1
    fi
}

# --- engine log --------------------------------------------------------------

# LuaTeX writes missing-glyph warnings as:
#   Missing character: There is no X (U+1EA9) in font [Name.otf]...
# Note the SQUARE brackets. An earlier ad-hoc check in this project used a
# pattern expecting single quotes, matched nothing, and produced a false
# "zero missing glyphs" result for a font that was missing 24 of them. The
# harness self-test in tests/cases/selftest-missing-glyph guards this.
assert_no_missing_glyphs() {
    local hits
    hits=$(grep -c 'Missing character' "$CASE_LOG" 2>/dev/null || true)
    if [[ "${hits:-0}" -gt 0 ]]; then
        local which
        which=$(grep -o 'in font \[[^]]*\]' "$CASE_LOG" | sort -u | tr '\n' ' ')
        _fail "${hits} missing glyph(s) — ${which}"
        return 1
    fi
}

assert_no_undefined() {
    if grep -q 'Undefined control sequence' "$CASE_LOG" 2>/dev/null; then
        local what
        what=$(grep -A1 'Undefined control sequence' "$CASE_LOG" | grep -o '\\\\[A-Za-z@]*$' | head -1)
        _fail "undefined control sequence${what:+ — ${what}}"
        return 1
    fi
    if grep -qE 'Reference .* undefined|Citation .* undefined' "$CASE_LOG" 2>/dev/null; then
        _fail "undefined reference"
        return 1
    fi
}

# Overfull boxes are how the current template's fixed-width sample tables fail
# on long lines: silently, by running text past the margin.
assert_no_overfull() {
    local limit="${1:-1.0}"
    local worst
    worst=$(grep -o 'Overfull \\hbox ([0-9.]*pt' "$CASE_LOG" 2>/dev/null \
            | grep -o '[0-9.]*' | sort -gr | head -1)
    if [[ -n "$worst" ]] && awk "BEGIN{exit !($worst > $limit)}"; then
        _fail "overfull hbox of ${worst}pt exceeds the ${limit}pt threshold"
        return 1
    fi
}

# --- static lint -------------------------------------------------------------

assert_file_lacks() {
    local file="$1" needle="$2" why="${3:-}"
    [[ -f "$file" ]] || { _fail "$file does not exist"; return 1; }
    if grep -qF -- "$needle" "$file"; then
        _fail "$file must not contain '$needle'${why:+ — ${why}}"
        return 1
    fi
}
