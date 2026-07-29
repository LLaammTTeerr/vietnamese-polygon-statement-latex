# examplewide stacks input above output, for sample data too wide to sit in
# half the page. Documented in docs/AUTHORING.md and previously untested —
# every other case uses the side-by-side `example` environment.

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

assert_pdf_contains "10 20"
assert_pdf_contains "30"
assert_pdf_contains "Đầu vào chuẩn"
assert_pdf_contains "Đầu ra chuẩn"
