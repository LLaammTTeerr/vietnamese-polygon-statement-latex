# The template requires a Unicode engine: it uses fontspec with the Source
# family for Vietnamese coverage (spec §3.1) and unicode-math.
$pdf_mode = 4;    # LuaLaTeX
$out_dir  = 'build';

# olymp.sty / vnolymp.sty live at the repository root.
ensure_path('TEXINPUTS', '.');

$clean_ext = 'synctex.gz run.xml bbl fdb_latexmk fls';
