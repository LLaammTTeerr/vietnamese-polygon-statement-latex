# The layering rule (spec §4.2): Freemarker emits data, the style package
# emits language.
#
# This is the root cause of defect #1. The old problem.tex translated `stdin`
# into "Đầu vào chuẩn" before the value reached LaTeX, and olymp.sty:200 then
# compared that translated string against "stdin" — a comparison that could
# never succeed. Every statement rendered "Vào từ tệp tin văn bản Đầu vào
# chuẩn", i.e. "read from the text file Standard input".
#
# Repairing the comparison would have left the trap in place. This lint
# forbids language in the data layer at all, so the bug is unrepresentable.
#
# Freemarker comments are stripped before checking. The templates document
# this defect by quoting the offending strings, and documentation is not
# emitted output — judging comments would make the lint punish the very
# explanation that keeps the rule from being undone by someone who doesn't
# know why it exists.

strip_comments() {
    python3 -c '
import re, sys, io
src = io.open(sys.argv[1], encoding="utf-8").read()
sys.stdout.write(re.sub(r"<#--.*?-->", "", src, flags=re.S))
' "$1"
}

work="${CASE_BUILD:-build/tests/ftl-lint}"
mkdir -p "$work"

for f in problem.tex statements.ftl tutorials.ftl; do
    [[ -f "$f" ]] || continue
    stripped="$work/$(basename "$f").stripped"
    strip_comments "$f" > "$stripped"

    # Localised I/O names must not be baked into emitted data.
    assert_file_lacks "$stripped" "Đầu vào chuẩn"  "I/O names belong in vnolymp-lang-*.def"
    assert_file_lacks "$stripped" "Đầu ra chuẩn"   "I/O names belong in vnolymp-lang-*.def"
    assert_file_lacks "$stripped" "стандартный"    "leftover Russian localisation"
    assert_file_lacks "$stripped" "standard input" "I/O names belong in vnolymp-lang-*.def"

    # Units, likewise. These drove the Russian plural-agreement block that the
    # rewrite deleted outright.
    assert_file_lacks "$stripped" "giây"      "units belong in vnolymp-lang-*.def"
    assert_file_lacks "$stripped" "секунд"    "leftover Russian pluralisation"
    assert_file_lacks "$stripped" "megabyte"  "units belong in vnolymp-lang-*.def"
    assert_file_lacks "$stripped" "мегабайт"  "leftover Russian pluralisation"

    # \t is LaTeX's tie accent (defect #8). Nothing may redefine it.
    assert_file_lacks "$stripped" '\renewcommand{\t}' \
        "redefining \\t clobbers the tie accent"

    # T2A is Cyrillic (defect #7); it cannot render Vietnamese.
    assert_file_lacks "$stripped" "T2A" \
        "Cyrillic font encoding cannot render Vietnamese"
done

# The stripping must not be so aggressive that it empties the file and makes
# every check above vacuously true.
if [[ -f "$work/problem.tex.stripped" ]]; then
    grep -q 'begin{problem}' "$work/problem.tex.stripped" \
        || _fail "comment stripping removed the template body — the checks above proved nothing"
fi
