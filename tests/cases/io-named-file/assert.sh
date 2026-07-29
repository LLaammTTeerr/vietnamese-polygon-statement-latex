# Named-file I/O is the branch, not the default (spec §5.1), but it must be
# correct: the actual filename has to reach the page. Green against the legacy
# template; kept as a regression guard across the rewrite.
#
# ./opts carries `hidesetting` only because the legacy template cannot build
# without it (defect #3). Drop the opts file once tests/config.sh points at
# vnolymp.

assert_compiles
assert_pdf_contains "treecut.inp"
assert_pdf_contains "treecut.out"
