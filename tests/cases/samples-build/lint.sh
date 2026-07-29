# Every sample under samples/ must build cleanly.
#
# These are the fixtures from spec §9.2. They are checked here rather than
# duplicated as ordinary cases, because their whole value is being complete,
# realistic statements — copying their bodies into tests/cases/ would mean
# maintaining the same text twice and letting the two drift.
#
# Three conditions, not just "it compiled":
#
#   * exit status zero and a PDF produced
#   * no missing glyphs — the guard that disqualified XCharter (spec §3.1)
#   * no overfull box beyond threshold — this is what catches sample data too
#     wide for its column, the silent margin overflow of the old template.
#     kitchen-sink deliberately contains a 240-token line to keep that honest.

for dir in samples/*/; do
    name=$(basename "$dir")
    main="$dir$name.tex"
    [[ -f "$main" ]] || continue

    out="${CASE_BUILD:-build/tests/samples-build}/$name"
    rm -rf "$out"; mkdir -p "$out"
    cp "$dir"* "$out/" 2>/dev/null

    ok=1
    for pass in 1 2; do
        ( cd "$out" && lualatex -interaction=nonstopmode -halt-on-error \
              "$name.tex" >"pass$pass.out" 2>&1 ) || ok=0
    done

    log="$out/$name.log"

    if [[ "$ok" -ne 1 || ! -f "$out/$name.pdf" ]]; then
        detail=$(grep -m1 -A2 '^! ' "$log" 2>/dev/null | tr '\n' ' ')
        _fail "sample '$name' failed to build${detail:+ — ${detail}}"
        continue
    fi

    glyphs=$(grep -c 'Missing character' "$log" 2>/dev/null || true)
    [[ "${glyphs:-0}" -eq 0 ]] \
        || _fail "sample '$name' has ${glyphs} missing glyph(s)"

    grep -q 'Undefined control sequence' "$log" 2>/dev/null \
        && _fail "sample '$name' has an undefined control sequence"

    worst=$(grep -o 'Overfull \\hbox ([0-9.]*pt' "$log" 2>/dev/null \
            | grep -o '[0-9.]*' | sort -gr | head -1)
    if [[ -n "$worst" ]] && awk "BEGIN{exit !($worst > 1.0)}"; then
        _fail "sample '$name' has an overfull hbox of ${worst}pt — sample data or a table is running past the margin"
    fi
done

# A samples/ directory that quietly emptied would pass every check above.
n=$(find samples -mindepth 1 -maxdepth 1 -type d | wc -l)
[[ "$n" -ge 3 ]] \
    || _fail "expected at least 3 sample directories, found $n"
