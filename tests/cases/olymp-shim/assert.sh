# A pre-existing document: \usepackage{olymp} plus the positional \begin{problem}
# syntax. Both are deprecated, both must still build.
#
# Limits passed positionally are prose ("1 giây", "256 megabytes") rather than
# numbers, so they print verbatim — the language layer must NOT append a second
# unit and produce "1 giây giây".

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

assert_pdf_contains "Bài cũ"
assert_pdf_contains "treecut.inp"
assert_pdf_contains "1 giây"
assert_pdf_contains "256 megabytes"
assert_pdf_not_contains "giây giây"

# Both deprecations must announce themselves, or nobody will ever migrate.
assert_log_contains "now a shim around vnolymp"
assert_log_contains "Deprecated positional"
