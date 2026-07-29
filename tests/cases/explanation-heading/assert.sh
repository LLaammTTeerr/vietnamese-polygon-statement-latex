# Defect #2 — olymp.sty:189 defines \Explanation without the \section{} that
# every sibling section command has, so the heading runs into the paragraph
# that follows it and the PDF reads "Giải thíchTrong ví dụ thứ nhất...".
#
# Expected: the heading stands alone on its own line, like every other section.
#
# ./opts carries `hidesetting` only because the legacy template cannot build
# without it (defect #3, pinned separately by the limits-panel case). Drop the
# opts file once tests/config.sh points at vnolymp, so this case isolates
# defect #2 and nothing else.

assert_compiles
assert_pdf_has_line "Giải thích"
assert_pdf_not_contains "Giải thíchTrong"
