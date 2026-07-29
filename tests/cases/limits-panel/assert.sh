# Defect #3 — olymp.sty:340 uses \@feedback, which is never defined anywhere.
# Without the `hidesetting` option the build dies with "Undefined control
# sequence". contest.tex:9 passes `hidesetting` to dodge this, which also
# suppresses the entire limits table — so the time and memory limits the author
# passes to \begin{problem} are silently never shown.
#
# This case therefore compiles WITHOUT that workaround (see ./opts) and
# requires the limits to actually appear.

assert_compiles
assert_no_undefined
assert_pdf_contains "1 giây"
assert_pdf_contains "256 MB"
