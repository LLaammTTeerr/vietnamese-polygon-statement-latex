# The Vietnamese language layer resolves end to end, through a real build
# rather than by inspecting the .def source.
#
# Also guards the wording decisions in spec §6: sentence case throughout, and
# "Chấm điểm" for scoring. The file this replaces defined both "Tính điểm" and
# "Chấm Điểm" for the same concept, with inconsistent capitalisation.

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

assert_pdf_contains "Dữ liệu"
assert_pdf_contains "Kết quả"
assert_pdf_contains "Chấm điểm"
assert_pdf_contains "Giới hạn thời gian"
assert_pdf_contains "Giới hạn bộ nhớ"
assert_pdf_contains "Đầu vào chuẩn"
assert_pdf_contains "Bài"
assert_pdf_contains "điểm"

# Title Case regressions.
assert_pdf_not_contains "Chấm Điểm"
