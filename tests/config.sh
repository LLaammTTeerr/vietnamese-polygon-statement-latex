# Which template the suite exercises.
#
# This was the migration switch. It originally selected a legacy pdfLaTeX
# preamble so the suite ran against the code being replaced, and the failing
# cases documented real defects rather than a missing package. It now selects
# vnolymp, and the same assertions pass — see the stage 1 and stage 3 commits
# for the red and green sides of that transition.
#
# The legacy preamble was removed once olymp.sty became a shim, since it can no
# longer be built under pdfLaTeX. Documents using the old syntax are still
# covered, by tests/cases/olymp-shim.

DEFAULT_ENGINE=lualatex
DEFAULT_PREAMBLE=tests/preamble-vnolymp.tex
DEFAULT_OPTS=nopagebreak
