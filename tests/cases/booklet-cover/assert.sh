# Booklet mode: cover page, overview table, running head, per-problem page
# breaks.
#
# The overview table is the interesting part. It is typeset before the problems
# it describes, so each problem writes its metadata to the .aux file and the
# cover reads the previous run's copy. This only works because the runner
# compiles twice; on a single pass the table is silently empty, which is why
# the row assertions below matter more than they look.

assert_compiles
assert_no_undefined
assert_no_missing_glyphs

# Cover: contest identity and both problems, with limits resolved from .aux.
assert_pdf_contains "Kỳ thi thử"
assert_layout_matches '1 +Bài thứ nhất.*1 giây.*256 MB.*100'
assert_layout_matches '2 +Bài thứ hai.*2 giây.*512 MB.*50'

# Two problems, so both ARE numbered. This is the other half of the rule
# problem-structure pins: numbering appears only when there is more than one
# problem to tell apart. The count comes from the .aux, so it also proves the
# second pass is doing its job.
assert_pdf_contains "Bài 1."
assert_pdf_contains "Bài 2."

# Running head and footer, using page.number/page.of — keywords the old
# package defined and then never referenced.
assert_pdf_contains "Trang"
assert_pdf_contains "trên"

# pagebreak is the booklet default, so two problems plus a cover means the
# document runs to at least three pages.
pages=$(pdfinfo "$CASE_PDF" 2>/dev/null | awk '/^Pages:/{print $2}')
[[ "${pages:-0}" -ge 3 ]] || _fail "expected at least 3 pages (cover + 2 problems), got ${pages:-none}"
