# The exact output shape of problem.tex, with Freemarker resolved by hand.
# Freemarker cannot run here, so this is the closest thing to an end-to-end
# check of the template: if the emitted shape stops compiling or stops
# rendering correctly, this goes red.
#
# The decisive assertion is the last one. Under the old pipeline this exact
# problem rendered "Vào từ tệp tin văn bản Đầu vào chuẩn" — "read from the text
# file Standard input" — because problem.tex translated stdin before LaTeX saw
# it. Raw tokens in, prose chosen by the language layer.

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

assert_pdf_contains "1 giây"
assert_pdf_contains "256 MB"
assert_pdf_contains "Đầu vào chuẩn"
assert_pdf_contains "Đầu ra chuẩn"
assert_pdf_not_contains "tệp tin văn bản"
