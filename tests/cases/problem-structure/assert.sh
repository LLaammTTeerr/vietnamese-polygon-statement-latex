# The problem environment end to end: key-value metadata, limits panel,
# section headings, subtasks, samples.

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

# Header: "Bài 1." from the auto counter, with points.
assert_pdf_contains "Bài 1."
assert_pdf_contains "Dãy con tăng dài nhất"
assert_pdf_contains "100"

# Limits panel — defect #3 made these silently vanish for every statement
# that used the hidesetting workaround, which was every statement.
assert_pdf_contains "Giới hạn thời gian"
assert_pdf_contains "1 giây"
assert_pdf_contains "Giới hạn bộ nhớ"
assert_pdf_contains "256 MB"
assert_pdf_contains "Lâm"
assert_pdf_contains "VOI 2024"

# stdin renders as prose, and NOT as the nonsense defect #1 produced.
assert_pdf_contains "Đầu vào chuẩn"
assert_pdf_contains "Đầu ra chuẩn"
assert_pdf_not_contains "tệp tin văn bản"

# Section headings stand alone. Defect #2 was \Explanation running into its
# own body text; every heading is checked so the fix can't regress in one
# command while passing in the others.
assert_pdf_has_line "Dữ liệu"
assert_pdf_has_line "Kết quả"
assert_pdf_has_line "Ràng buộc"
assert_pdf_has_line "Ví dụ"
assert_pdf_has_line "Giải thích"

# Sections emit a heading only — no injected I/O sentence.
assert_pdf_not_contains "Vào từ thiết bị"
assert_pdf_not_contains "bàn phím"

# Subtasks: the environment supplies its own "Chấm điểm" heading, the table
# headers, and the per-cent signs.
assert_pdf_has_line "Chấm điểm"
assert_pdf_contains "Subtask"

# Row-level assertions, because a plain "contains 30%" check passes even when
# every row is numbered identically — which is exactly the bug this caught:
# the counter was appended unexpanded, so all three rows rendered as "3".
assert_layout_matches '^ *1 +30% +'
assert_layout_matches '^ *2 +30% +'
assert_layout_matches '^ *3 +40% +'

# Sample block: headings name the stream the way the judge does, and the data
# survives verbatim.
assert_pdf_contains "stdin"
assert_pdf_contains "stdout"
assert_pdf_contains "1 2 3"
