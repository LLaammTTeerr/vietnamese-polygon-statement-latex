# Named-file I/O is the branch, not the default (spec §5.1), but it must be
# correct: the actual filename has to reach the page. Green against the legacy
# template; kept as a regression guard across the rewrite.
#
# The filename now reaches the page via the limits panel rather than via a
# sentence injected into the Input section, since section commands emit a
# heading and nothing else.

assert_compiles
assert_pdf_contains "treecut.inp"
assert_pdf_contains "treecut.out"
