# Which template the suite currently exercises.
#
# This file is the migration switch. Today it points at the legacy pdfLaTeX
# template so the suite runs against the code being replaced, and the failing
# cases document real defects rather than a missing package. As the rewrite
# lands (spec §12), flip these to the LuaLaTeX vnolymp preamble; the same
# assertions must then pass.
#
#   DEFAULT_ENGINE=lualatex
#   DEFAULT_PREAMBLE=tests/preamble-vnolymp.tex

DEFAULT_ENGINE=pdflatex
DEFAULT_PREAMBLE=tests/preamble-legacy.tex
DEFAULT_OPTS=nopagebreak
