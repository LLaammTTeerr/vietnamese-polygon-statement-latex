# Defect #2 — olymp.sty:189 defines \Explanation without the \section{} that
# every sibling section command has, so the heading runs into the paragraph
# that follows it and the PDF reads "Giải thíchTrong ví dụ thứ nhất...".
#
# Expected: the heading stands alone on its own line, like every other section.
#
# The body is still written in the legacy positional syntax, deliberately: this
# case went red→green across the rewrite without being edited, so the green is
# evidence the defect is fixed rather than evidence the test was reworded. It
# now also exercises the compat shim.

assert_compiles
assert_pdf_has_line "Giải thích"
assert_pdf_not_contains "Giải thíchTrong"
