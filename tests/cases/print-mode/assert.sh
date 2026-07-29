# print mode replaces every accent fill with a grey and every accent rule with
# black, for booklets that will be photocopied. Every component must survive
# the switch — the header bar, panel, subtask table and sample boxes all change
# colour, and a missing colour definition would only surface here.

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

assert_pdf_contains "Bài 1."
assert_pdf_contains "Giới hạn thời gian"
assert_layout_matches '^ *1 +40% +'
# Sample table headings are Vietnamese prose, not the raw token.
assert_pdf_contains "Đầu vào chuẩn"
