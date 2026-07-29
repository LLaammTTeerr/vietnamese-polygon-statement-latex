# The layering rule (spec §4.2): Freemarker emits data, the style package
# emits language.
#
# This is the root cause of defect #1. problem.tex translates `stdin` into
# "Đầu vào chuẩn" before the value ever reaches LaTeX, and olymp.sty:200 then
# compares that translated string against "stdin" — a comparison that can never
# succeed. Every statement consequently renders "Vào từ tệp tin văn bản Đầu vào
# chuẩn", i.e. "read from the text file Standard input".
#
# Fixing the comparison would only paper over it. The durable fix is to forbid
# language in the data layer entirely, which is what this lint enforces: the
# Freemarker templates must emit the bare tokens `stdin`/`stdout` and bare
# integers, leaving all wording and pluralisation to the language files.

for f in problem.tex statements.ftl; do
    [[ -f "$f" ]] || continue

    # Localised I/O names must not be baked into emitted data.
    assert_file_lacks "$f" "Đầu vào chuẩn"  "I/O names belong in vnolymp-lang-*.def"
    assert_file_lacks "$f" "Đầu ra chuẩn"   "I/O names belong in vnolymp-lang-*.def"
    assert_file_lacks "$f" "стандартный"    "leftover Russian localisation"
    assert_file_lacks "$f" "standard input" "I/O names belong in vnolymp-lang-*.def"

    # Units, likewise. These drove the Russian plural-agreement block that the
    # rewrite deletes outright.
    assert_file_lacks "$f" "giây"      "units belong in vnolymp-lang-*.def"
    assert_file_lacks "$f" "секунд"    "leftover Russian pluralisation"
    assert_file_lacks "$f" "megabyte"  "units belong in vnolymp-lang-*.def"
    assert_file_lacks "$f" "мегабайт"  "leftover Russian pluralisation"
done

# \t is LaTeX's tie accent. statements.ftl:51 redefines it with a different
# arity than olymp.sty:86 does (defect #8); neither should redefine it at all.
if [[ -f statements.ftl ]]; then
    assert_file_lacks statements.ftl '\renewcommand{\t}' \
        "redefining \\t clobbers the tie accent"
fi

# T2A is Cyrillic (defect #7). Vietnamese needs T5 under pdfLaTeX, or a
# Unicode engine — which is what the rewrite adopts.
if [[ -f statements.ftl ]]; then
    assert_file_lacks statements.ftl "T2A" \
        "Cyrillic font encoding cannot render Vietnamese"
fi
