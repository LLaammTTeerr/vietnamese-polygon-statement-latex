# The English layer resolves through the same code path, proving the language
# split actually works rather than Vietnamese merely being hardcoded further
# down. This is the case that would have caught the leftover English strings
# in the old file ("Developer:", "Specification", "not stated") had it existed.

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

assert_pdf_contains "Input"
assert_pdf_contains "Output"
assert_pdf_contains "Scoring"
assert_pdf_contains "Time limit"
assert_pdf_contains "standard input"
assert_pdf_contains "Problem"

# Vietnamese must not leak through in an English build.
assert_pdf_not_contains "Dữ liệu"
assert_pdf_not_contains "Giới hạn"
