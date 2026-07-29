# The tutorial environment, which tutorials.ftl generates as
# \begin{tutorial}{Name}. Documented in docs/AUTHORING.md §6 and previously
# untested — the editorial path had no coverage at all, which is how the
# repository ended up with no tutorials.ftl in the first place.
#
# A tutorial is headed like a problem but carries no limits panel: an editorial
# restates the problem it discusses, so repeating the limits is noise.

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

assert_pdf_contains "Bài 1."
assert_pdf_contains "Dãy con tăng dài nhất"
assert_pdf_contains "Bài 2."
assert_pdf_contains "Xếp gỗ"

# No limits panel.
assert_pdf_not_contains "Giới hạn thời gian"
assert_pdf_not_contains "Giới hạn bộ nhớ"
