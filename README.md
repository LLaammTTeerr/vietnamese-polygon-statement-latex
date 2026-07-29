# vnolymp

LaTeX package for typesetting competitive-programming statements in
Vietnamese, for problems authored on
[Polygon](https://polygon.codeforces.com).

A rewrite of this repository's Vietnamese fork of
[olymp.sty](https://github.com/GassaFM/olymp.sty).

---

## Requirements

- **LuaLaTeX** — required, not optional. The package uses `fontspec` and
  OpenType fonts for Vietnamese diacritics.
- TeX Live 2023 or newer with these packages: `tcolorbox`, `fvextra`,
  `expkv-def`, `unicode-math`, `hhline`, `tabularx`, `colortbl`, `lastpage`,
  `microtype`, `fancyhdr`, `etoolbox`, `xstring`, plus the **Latin Modern**
  and **Source Sans Pro** font families.

On Debian or Ubuntu, `texlive-full` covers everything;
`texlive-fonts-extra` is the package that supplies Source Sans Pro.

On a plain TeX Live installation — including the `texlive/texlive` Docker
image, which does **not** ship it — install it with:

```
tlmgr install sourcesanspro
```

The package checks for it at load time and says so, rather than leaving you
with fontspec's "cannot be found" error.

Running the test suite additionally needs `poppler-utils` (for `pdftotext`
and `pdfinfo`), `python3`, and the `xcharter` font — the last is deliberate:
one test feeds XCharter to the missing-glyph detector *because* it lacks the
Vietnamese hook-above characters.

## Quick start

```latex
\documentclass[11pt, a4paper, oneside]{article}
\usepackage[vietnamese, color, booklet]{vnolymp}

\begin{document}
\contest{Kỳ thi chọn học sinh giỏi Quốc gia}{Hà Nội}{Tháng 3, 2026}
\vnolympcover

\begin{problem}[input = stdin, output = stdout,
                time = 1, memory = 256, points = 100]{Dãy con tăng dài nhất}

Cho dãy số nguyên $a_1, a_2, \dots, a_n$.

\InputFile
Dòng đầu chứa số nguyên $n$.

\OutputFile
Một số nguyên duy nhất.

\begin{subtasks}
  \subtask{40}{$n \le 100$}
  \subtask{60}{Không có ràng buộc gì thêm}
\end{subtasks}

\Examples
\begin{example}
\exmpfile{ex.in}{ex.out}%
\end{example}

\end{problem}
\end{document}
```

Build **twice** — the page total and the cover's overview table come from the
`.aux` file:

```
lualatex statement.tex && lualatex statement.tex
```

Full command reference: **[docs/AUTHORING.md](docs/AUTHORING.md)**.

## What it produces

- One accent colour, or a `print` mode in greys that survives photocopying.
- Vietnamese or English from the same source.
- A contest booklet with cover page and problem overview, or a single-problem
  PDF, from the same source.
- Sample tests as a bordered table with line numbers, which **wrap** rather
  than running off the page.

## Using it with Polygon

Upload to your problem's or contest's **Files** page:

| File | Purpose |
|---|---|
| `problem.tex` | per-problem statement template |
| `statements.ftl` | contest statement wrapper |
| `tutorials.ftl` | contest editorial wrapper |

Then export the package and build locally.

**Polygon's own "In PDF" preview will not work.** The generated preamble
requires LuaLaTeX, `fontspec` and `tcolorbox`, which Polygon's server-side
pdfLaTeX does not provide. This is a deliberate trade: building locally is what
allows the typography. Package *export* — what the local build consumes — is
unaffected.

The Freemarker templates emit only data: the bare tokens `stdin`/`stdout` and
bare integers for the limits. All wording comes from
`vnolymp-lang-vi.def` / `vnolymp-lang-en.def`. Do not reintroduce translated
strings into the templates; `tests/cases/ftl-emits-raw-data` will fail if you
do, and the reason is worth reading.

## Layout

```
vnolymp.sty            entry point: options, load order
  vnolymp-lang-vi.def  every Vietnamese string
  vnolymp-lang-en.def  every English string
  vnolymp-problem.def  problem environment, sections, subtasks
  vnolymp-example.def  sample-test tables
  vnolymp-style.def    fonts, colour, geometry, every visual component
  vnolymp-compat.def   legacy syntax, deprecated
olymp.sty              shim, so \usepackage{olymp} still works

problem.tex            Freemarker: one problem
statements.ftl         Freemarker: contest statements
tutorials.ftl          Freemarker: contest editorials

samples/               fixtures, also useful as worked examples
tests/                 the test suite
docs/AUTHORING.md      command reference
```

Each module has one job. Retuning wording touches only a `-lang-` file;
restyling touches only `-style.def`.

## Development

```
tests/run.sh            run everything
tests/run.sh <case>     run one case
make test               same as tests/run.sh
make clean              remove build artefacts
```

Cases live in `tests/cases/`. Each has either a `body.tex` plus `assert.sh`, or
a `lint.sh` for static checks. The suite checks three things, because "it
compiled" is not the same as "it is correct":

1. It builds, across the option matrix.
2. The log is clean — no missing glyphs, undefined control sequences, or
   overfull boxes.
3. The extracted text says what it should.

Two cases test the tests: `selftest-missing-glyph` feeds a font known to lack
Vietnamese glyphs to the missing-glyph detector and requires it to fire, and
`lang-parity` fails if the two language files drift apart.

## Compatibility

Existing statements keep building. `\usepackage{olymp}` and the positional
`\begin{problem}{title}{in}{out}{TL}{ML}` form both work and warn once. See
§8 of [docs/AUTHORING.md](docs/AUTHORING.md) for migration.

Three deliberate breaks: `\SubtaskWithScore`'s counter is gone, `hidesetting`
is renamed `hidelimits`, and the `landscape` option is removed — it set a flag
against an `\if` that was never declared, so it could only ever crash.

## Licence

Derived from [olymp.sty](https://github.com/GassaFM/olymp.sty); see that
project for original authors and licence.
