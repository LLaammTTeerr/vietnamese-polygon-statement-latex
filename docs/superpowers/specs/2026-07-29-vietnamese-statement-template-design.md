# Vietnamese contest-statement LaTeX template — design

Date: 2026-07-29
Status: approved, pending implementation plan

## 1. Context

This repository is a Vietnamese fork of [olymp.sty](https://github.com/GassaFM/olymp.sty)
used to typeset competitive-programming statements authored on
[Polygon](https://polygon.codeforces.com). It consists of five files: a
537-line `olymp.sty`, two Freemarker templates (`problem.tex`, `statements.ftl`)
that Polygon expands server-side, and two local scaffolding files
(`contest.tex`, `statement.tex`).

It has accumulated correctness bugs and structural problems that make it
unpleasant to write in and unsafe to rely on for a real contest.

### 1.1 Confirmed defects

| # | Location | Defect |
|---|----------|--------|
| 1 | `olymp.sty:200,210` | `\IfStrEq{\inputfilename}{stdin}` never matches, because `problem.tex:2-6` already translated `stdin` to `Đầu vào chuẩn` before the value reached the macro. Every statement therefore prints *"Vào từ tệp tin văn bản **Đầu vào chuẩn**"* — "read from the text file *Standard input*". |
| 2 | `olymp.sty:189` | `\Explanation` lacks the `\section{}` that all its siblings have, so it renders as inline body text instead of a heading. |
| 3 | `olymp.sty:340` | `\@feedback` is used but never defined anywhere. Without the `hidesetting` option the document fails to compile; `contest.tex:9` passes `hidesetting` to avoid this, which suppresses the entire limits table. Time and memory limits passed at `statement.tex:1` are consequently never displayed. |
| 4 | `contest.tex:15` | `ulem` is loaded without `[normalem]`, silently redefining `\emph` to underline throughout. |
| 5 | `olymp.sty:20` | `\@landscapetrue` is set but `\if@landscape` was never created with `\newif`. The `landscape` option fails immediately. |
| 6 | `olymp.sty:259` | `\if@arabic` is likewise undeclared. The `tutorial` environment fails whenever both `\ShortProblemTitle` and `\ProblemIndex` are undefined. |
| 7 | `statements.ftl:19-21` | Declares `[T2A]{fontenc}`, which is Cyrillic, with no T5 or `vntex`. The local `contest.tex:4` declares `[T5]`. The two entry points disagree on font encoding. |
| 8 | `olymp.sty:86`, `statements.ftl:51` | `\renewcommand{\t}` overwrites LaTeX's tie-accent `\t`; `statements.ftl` then redefines it again with a different arity. |
| 9 | `olymp.sty:354` | `\lastproblemdorigin` is a typo for `\lastproblemorigin`, so problem origin is never restored between problems. |

### 1.2 Structural problems

- Page geometry is computed by hand via `\hoffset`/`\voffset` (`olymp.sty:37-53`).
  The 12 pt branch yields a negative top margin.
- `lastpage` is reimplemented inline (`olymp.sty:59-64`) while `contest.tex:19`
  separately loads `zref[totpages]` for the same purpose.
- `\headheight=2cm` is reserved for a header that does not exist.
- Dead code: `\kw@Page`, `\kw@of`, `\kw@version`, `\kw@revision`,
  `\kw@SubtaskOne` … `\kw@SubtaskSix`, `\kw@notstated`.
- Two unrelated subtask mechanisms coexist: `\Subtask` (a bare section) and
  `\SubtaskWithScore` (a counter-driven heading).
- Vietnamese prose is hardcoded inside macro bodies (`olymp.sty:201,211`),
  mixed with formatting and control flow.
- Roughly ten user-visible strings remain untranslated: `Developer:`,
  `Specification`, `Feedback:`, `not stated`, `version`, `revision`.
- Terminology is internally inconsistent: `\kw@Scoring` is "Tính điểm" while
  `\kw@Subtask` is "Chấm Điểm", with non-standard capitalisation.
- Sample tests are typeset with `\verbatiminput` inside a fixed-width `tabular`
  minipage, which cannot wrap and silently overflows on long sample lines.

### 1.3 Root cause

A single file mixes four concerns: user-visible language strings, page-layout
arithmetic, visual styling, and the authoring API. Defect #1 is the clearest
symptom — six lines of `\InputFile` contain hardcoded Vietnamese prose, a string
comparison, and formatting, and the comparison is wrong because a *different*
file already performed the translation. Separating these concerns is what makes
the remaining work tractable.

### 1.4 Status of `examples/`

`examples/p1` and `examples/p2` are past statements. They are **reference
material for deciding the API, not authority over it.** No API shape, default,
or behaviour may be adopted merely because an example uses it; each requires
explicit approval from the author.

This is a standing constraint, not a one-off. The old statements contain the
very habits this rewrite exists to eliminate — hand-typed and mutually
inconsistent units (`1 giây` in one, `1 second` in the other, `256 megabytes`
in both), a `tabular` declaring ten columns while using five, duplicated
`\Constraints` and `\Subtask` blocks, and a reference to a missing image.
Treating them as ground truth would launder those mistakes into the new design
as requirements.

The I/O default in §5.1 is the worked example: both statements use `.inp`/`.out`
files, and the author nevertheless chose `stdin`/`stdout`. The examples describe
the past, not the target.

## 2. Goals and non-goals

### Goals

- Correctness: every defect in §1.1 fixed, with regression tests that fail if
  any returns.
- A statement that is pleasant to author and looks deliberately designed.
- One template serving both hand-written `.tex` statements and Polygon package
  exports.
- Colour and print (black-and-white photocopy) output from one source.
- Vietnamese and English from one source.
- Contest booklet and single-problem PDF from one source.

### Non-goals

- Server-side rendering on Polygon's own "In PDF" button. Builds are local, so
  the template is free to require LuaLaTeX, `fontspec`, and `tcolorbox`.
  Polygon-side preview is explicitly out of scope.
- Backward compatibility with upstream `olymp.sty` beyond the commands this
  repository actually uses.
- Languages other than Vietnamese and English.

## 3. Decisions

Settled with the author; recorded here so they are not relitigated.

| Decision | Value | Rationale |
|---|---|---|
| Engine | LuaLaTeX | Best `fontspec` and `microtype` support. No requirement favours XeTeX. |
| Build location | Local only | Unlocks OpenType fonts and `tcolorbox`. |
| Body font | Source Serif Pro | Verified complete Vietnamese coverage; see §3.1. |
| Heading/UI font | Source Sans Pro | Same superfamily, verified complete. |
| Sample font | Source Code Pro | Same superfamily, verified complete. |
| Math font | STIX Two Math, Latin/digit ranges overridden to Source Serif | See §7.2. |
| Accent | `#A8122C` | Author's choice; 7.53:1 white-text contrast, 51/255 grayscale. |
| Paper | A4, 11 pt | The two current entry points disagree (12 pt vs 11 pt); 11 pt chosen. |
| Terminology | VOI / national-olympiad style | Author's choice; see §6. |
| Package name | `vnolymp` | `olymp.sty` retained as a compatibility shim. |
| API compatibility | "Mostly" — small breaks permitted | Author's choice; see §5.3. |

### 3.1 Font evidence

All candidate fonts were compiled under LuaLaTeX against the complete
Vietnamese precomposed set (134 characters, U+00C0–U+1EF9) and the log
inspected for missing glyphs.

| Font | Missing glyphs | Verdict |
|---|---|---|
| Source Serif Pro | 0 | Selected (body) |
| Source Sans Pro | 0 | Selected (headings/UI) |
| Source Code Pro | 0 | Selected (samples) |
| Libertinus Serif | 0 | Viable alternative |
| TeX Gyre Pagella | 0 | Viable alternative |
| Noto Serif | 0 | Viable alternative |
| **XCharter** | **24** | **Rejected** |
| **DejaVu Sans Mono** | **46** | **Rejected** |

XCharter is missing the entire hook-above (dấu hỏi) tone class —
`ả ẻ ỉ ỏ ủ ỷ ẩ ẳ ể ổ ở ử` and capitals — rendering them as tofu. DejaVu Sans
Mono additionally lacks most circumflex-plus-tone combinations. Neither may be
used for Vietnamese text.

This check must be retained as an automated test (§9.3), because font coverage
is invisible until it is measured and a TeX Live upgrade could change it.

## 4. Architecture

```
vnolymp.sty            entry point: option parsing, load order
  vnolymp-lang-vi.def  every user-visible Vietnamese string
  vnolymp-lang-en.def  every user-visible English string
  vnolymp-style.def    fonts, colours, geometry, tcolorbox styles, head/foot
  vnolymp-problem.def  problem environment, section headings, limits panel, subtasks
  vnolymp-example.def  sample-test environments
  vnolymp-compat.def   deprecated command names mapped onto the new API
olymp.sty              shim: \RequirePackage{vnolymp}
```

Each module has one responsibility. Retuning wording touches only a `-lang-`
file; restyling touches only `-style.def`. No module hardcodes prose.

### 4.1 Package options

| Option | Values | Default | Effect |
|---|---|---|---|
| colour mode | `color` / `print` | `color` | `print` replaces every accent fill with a grey tint and every accent rule with black. |
| document mode | `booklet` / `standalone` | `booklet` | `standalone` suppresses cover page and running head. |
| language | `vietnamese` / `english` | `vietnamese` | Selects the `-lang-` file. |
| page breaks | `pagebreak` / `nopagebreak` | `pagebreak` | Whether each problem starts a new page. |
| `hidelimits` | flag | off | Suppresses the limits panel. Replaces `hidesetting`, which existed only to dodge defect #3. |

### 4.2 Layering rule

**Freemarker emits data; the style package emits language.**

This is the central invariant and the fix for defect #1. Today `problem.tex`
translates `stdin` into `Đầu vào chuẩn` and `1000` into `1 giây` before the
values reach LaTeX, which is why `olymp.sty`'s comparison against `stdin` can
never succeed.

Under the new rule the Freemarker layer emits the raw tokens `stdin` and
`stdout` and the raw integers `1` and `256`. The style package decides that
`stdin` renders as "Đầu vào chuẩn" and that `1` renders as "1 giây".

Consequences:

- Defect #1 becomes unrepresentable rather than merely fixed.
- The Russian plural-agreement block at `problem.tex:12-37` is deleted entirely;
  pluralisation is a language-layer concern.
- English mode works with no additional Freemarker changes.
- Hand-written statements and Polygon-generated statements present the *same*
  shape to the style package, so §2's "one template, two workflows" goal is met
  by construction rather than by branching.

## 5. Authoring API

### 5.1 Problem environment

Positional arguments are why the sixth "points" argument required the
`\@ifnextchar` hack at `olymp.sty:491-498`. The new API is key–value, parsed
with `expkv-def`:

```latex
\begin{problem}[
  input = stdin, output = stdout,
  time = 1, memory = 256,
  points = 100,
  author = Lâm, origin = {VOI 2024},
]{Dãy con tăng dài nhất}
  ...
\end{problem}
```

`time` is in seconds and `memory` in mebibytes (rendered "MB", following
contest convention), both as bare numbers. Units and
their Vietnamese or English rendering are supplied by the language layer.
`input` and `output` accept the literal tokens `stdin`/`stdout` or a filename.
All keys are optional; omitted keys are omitted from the limits panel.

**`stdin`/`stdout` are the primary case; named files are the branch.**
Approved by the author. Note that this deliberately diverges from the past
statements in `examples/`, which both use `.inp`/`.out` pairs — the author's
intended direction is online-judge style, and the old statements do not
constrain it (see §1.4).

Both branches must nonetheless be correct, since the filename case still
appears in the limits panel and in sample-block column headings — and it is
precisely the branch that defect #1 rendered nonsensical.

### 5.2 Sections and blocks

Section commands are unchanged in name: `\InputFile`, `\OutputFile`,
`\Constraints`, `\Examples`, `\Note`, `\Explanation`, `\Interaction`,
`\Scoring`. `\Explanation` gains the `\section{}` it is missing (defect #2).

Subtasks unify into one environment, replacing both `\Subtask` and
`\SubtaskWithScore`. **Flat form only** — approved by the author:

```latex
\begin{subtasks}
  \subtask{30}{$n \le 20$}
  \subtask{30}{$n \le 2000$, và tất cả các đỉnh có bậc không quá $2$}
  \subtask{40}{Không có ràng buộc gì thêm}
\end{subtasks}
```

A constraint *matrix* — one column per constrained variable — is deliberately
**not** given dedicated API surface. It is rare enough that the cost of a
`columns` key outweighs the benefit. Instead a thin styling wrapper is
provided, inside which the author writes an ordinary `tabular`:

```latex
\begin{subtasktable}{$N$ & $M$ & $a_{x,y}$}
  ... ordinary tabular rows ...
\end{subtasktable}
```

The wrapper supplies the rules, tinting, header treatment and spacing so a
hand-written matrix still matches the rest of the document; the author retains
full control of the columns. This keeps the common case one line per subtask
and the rare case fully general, without a mode flag.

Samples keep their current commands:

```latex
\begin{example}
  \exmpfile{example.01}{example.01.a}   % from files, as Polygon exports
  \exmp{3 \\ 1 2 3}{6}                  % inline
\end{example}
```

### 5.3 Compatibility

`vnolymp-compat.def` maps the legacy positional form
`\begin{problem}{name}{in}{out}{TL}{ML}{pts}` onto the key–value form, so
existing statements compile unchanged. It also aliases `\Subtask` and
`\SubtaskWithScore` onto the `subtasks` environment, emitting a deprecation
warning.

Accepted breaks, per the author's "small breaks OK":

- `\SubtaskWithScore`'s automatic numbering counter is removed; the `subtasks`
  environment numbers its own entries.
- The `hidesetting` option is renamed `hidelimits`. `hidesetting` remains as a
  deprecated alias.
- The `landscape` option is removed rather than repaired (defect #5); it was
  never functional, so nothing can depend on it.

A `sed` migration script and a note in the authoring guide cover these.

## 6. Language layer

`vnolymp-lang-vi.def` holds every user-visible string. VOI / national-olympiad
wording, per the author's choice:

| Key | Vietnamese |
|---|---|
| section: input | Dữ liệu |
| section: output | Kết quả |
| section: constraints | Ràng buộc |
| section: scoring | Chấm điểm |
| section: examples | Ví dụ |
| section: explanation | Giải thích |
| section: notes | Chú ý |
| section: interaction | Tương tác |
| panel: input file | Tệp vào |
| panel: output file | Tệp ra |
| panel: time limit | Giới hạn thời gian |
| panel: memory limit | Giới hạn bộ nhớ |
| panel: author | Tác giả |
| panel: origin | Nguồn |
| value: stdin | Đầu vào chuẩn |
| value: stdout | Đầu ra chuẩn |
| unit: seconds | giây |
| unit: megabytes | MB |
| points | điểm |
| footer | Trang {n} trên {m} |

Capitalisation is normalised — the current file's "Chấm Điểm" is corrected.
The untranslated strings listed in §1.2 are translated. Dead keys are deleted.

`vnolymp-lang-en.def` mirrors this exactly. A test asserts the two files define
identical key sets, so adding a Vietnamese string without its English
counterpart fails the build.

## 7. Visual design

Direction: boxed and colour-tinted, per the author's choice.

### 7.1 Layout

- A4, 11 pt, margins via `geometry` at roughly 20 mm, replacing the manual
  `\hoffset`/`\voffset` arithmetic and its negative-top-margin bug.
- `microtype` enabled.

### 7.2 Fonts

```
body      Source Serif Pro
headings  Source Sans Pro (semibold)
samples   Source Code Pro
math      STIX Two Math, with the latin/Latin/num ranges overridden
          to Source Serif Pro via unicode-math's range= mechanism
```

### 7.2.1 TeX ligatures — a migration hazard

`fontspec` does **not** apply TeX's input ligatures by default. Verified under
LuaLaTeX: with default settings `` `H' `` renders as a literal backtick and
apostrophe, and `--` / `---` remain literal hyphens. With `Ligatures=TeX` they
become ‘H’ and proper en/em dashes.

This is not hypothetical. `examples/p2/contest.tex:14-18` writes
`` $\texttt{`H'}$ `` intending ‘H’, and its subtask table uses `---`. Migrating
to LuaLaTeX without `Ligatures=TeX` would silently degrade prose rather than
fail loudly, which is the worst failure mode available.

Policy — the monospace half was delegated to the implementer and decided as
follows:

- **Serif and sans: `Ligatures=TeX`.** Unambiguously correct for prose: `--`
  becomes an en dash, ``` ``…'' ``` becomes curly quotes.
- **All monospace: ligatures off.** Monospace exists to display literal
  characters. A mono font that silently rewrites `` ` `` as ‘ can never show a
  backtick, which fails the first time a statement quotes shell syntax, a C
  string literal, or Markdown. Prose-level quoting belongs in the surrounding
  serif — ``ký tự `H'`` still yields ‘H’ because the prose font has TeX
  ligatures enabled.
- **Sample-test blocks: ligatures off**, as a special case of the above.
  Sample data is verbatim and must reproduce byte for byte; a `--` inside test
  data must never become an en dash.

Migration consequence: the `` \texttt{`H'} `` idiom now renders literally.
The authoring guide documents writing `\texttt{H}` with the quotation marks in
the surrounding prose instead. The migration script flags occurrences rather
than rewriting them, since the intent is not mechanically recoverable.

### 7.2.2 Math

The math override matters: nearly all mathematics in a CP statement is
variables, subscripts, and powers of ten (`$n$`, `$a_i$`, `$10^5$`). Taking
those glyphs from the body font makes inline mathematics blend with the prose,
while STIX supplies relations and operators. To be confirmed visually during
implementation; if it disappoints, the fallbacks are plain STIX Two Math or
Libertinus Math.

### 7.3 Components

- **Problem header** — full-width `tcolorbox`, `#A8122C` fill, white Source Sans
  semibold, index and title flush left, points flush right. In `print` mode:
  13 % black fill, black text.
- **Limits panel** — tinted box beneath the header, a genuine 2×2 `tabular`
  grid. The specimen exposed that `\hfill` strands the right-hand label against
  its own value; alignment must be tabular, not glue.
- **Section headings** — accent-coloured left bar plus Source Sans semibold, no
  numbering.
- **Samples** — `tcolorbox` with tinted title rows, **with line wrapping
  enabled**, fixing the silent overflow described in §1.2.
- **Chú ý** — left-rule callout block.
- **Subtasks** — table with alternating tinted rows.
- **Booklet** — cover page carrying contest name, location, date and an overview
  table of all problems (name, time, memory, points); running header with a thin
  accent rule; footer "Trang 3 trên 12" using the previously dead `\kw@Page`
  and `\kw@of` keywords.
- **Standalone** — cover and running head suppressed.

## 8. Freemarker layer

- `problem.tex` — per-problem template. Rewritten to emit raw data per §4.2.
  The language-conditional and plural-agreement logic is deleted.
- `statements.ftl` — contest wrapper. `[T2A]{fontenc}` and `[utf8]{inputenc}`
  are removed (defect #7); the preamble becomes a LuaLaTeX preamble loading
  `vnolymp`. The `\renewcommand{\t}` at line 51 is removed (defect #8).
- `tutorials.ftl` — added. The repository currently lacks it; the VNOI fork has
  one, and tutorials otherwise fall back to Polygon's unstyled default.

These templates still execute on Polygon's server during package export, so
they must remain valid Freemarker even though the resulting PDF is built
locally.

Explicit consequence: because the emitted preamble requires LuaLaTeX,
`fontspec` and `tcolorbox`, Polygon's own "In PDF" preview button will stop
working. This is accepted, not overlooked — it follows directly from the
local-only decision in §3, and it is the price of §2's typography goals. Package
export, which is what the local build consumes, is unaffected.

## 9. Build and test

### 9.1 Build

`latexmkrc` configured for LuaLaTeX, plus a `Makefile`: `make` builds, `make
test` runs the suite, `make clean` removes artefacts.

### 9.2 Samples

- `samples/minimal/` — smallest valid problem.
- `samples/kitchen-sink/` — exercises every feature: subtasks, an image,
  interactive protocol, multiple samples, deliberately over-long sample lines,
  and heavy diacritic text.
- `samples/booklet/` — four problems with a cover page.

**All fixtures are written fresh.** Per the author's decision, `examples/` is
reference material only and does not enter the test suite (§1.4). Writing
fixtures deliberately keeps the old statements' habits — hand-typed units,
malformed tables, duplicated blocks — out of the regression baseline.

The fixtures must nonetheless *cover* the features those statements exercise,
which is what they were read for:

| Feature | Seen in | Fixture |
|---|---|---|
| Named-file I/O (`.inp`/`.out`) | p1, p2 | `kitchen-sink` |
| `itemize`-based input description | p1 | `kitchen-sink` |
| Percentage subtasks | p1 | `minimal` |
| Multiple sample pairs | p1 | `kitchen-sink` |
| `\includegraphics` with caption | p1 | `kitchen-sink` |
| Hand-written constraint matrix | p2 | `kitchen-sink` (via `subtasktable`) |
| Inline `\texttt` literals | p2 | `kitchen-sink` (pins §7.2.1) |
| `\Explanation` as a heading | p2 | `minimal` (pins defect #2) |

### 9.3 Tests

Three layers, because "it compiled" is not the same as "it is correct".

1. **Compilation matrix** — every sample across
   `color`/`print` × `booklet`/`standalone` × `vietnamese`/`english`.
2. **Log assertions** — fail on any missing glyph, undefined control sequence,
   undefined reference, or overfull hbox beyond a threshold. Missing-glyph
   detection is what disqualified XCharter (§3.1) and what would have caught
   defect #7.
3. **Content assertions** via `pdftotext` — assert on extracted text. At
   minimum:
   - the string `tệp tin văn bản Đầu vào chuẩn` must never appear, pinning
     defect #1 permanently;
   - a statement containing `` \texttt{`H'} `` must extract as ‘H’, not as a
     backtick, pinning §7.2.1;
   - sample-test blocks containing a literal `--` must extract as `--`, proving
     ligatures stayed off where they must.

Additionally, a key-parity test between the two `-lang-` files (§6).

Note on log assertions: LuaTeX writes missing-glyph warnings as
`... in font [Name.otf]` with square brackets. An earlier check in this project
used a pattern expecting single quotes, matched nothing, and produced a false
"zero missing glyphs" result. The test must be verified against a font known to
fail — XCharter serves as that fixture.

### 9.4 CI

GitHub Actions on a TeX Live container runs the full suite on every push and
uploads the built PDFs as artefacts.

## 10. Documentation

- `README.md` — what this is, how to build, how to use with Polygon.
- `docs/AUTHORING.md` — command reference with examples, plus the migration
  notes from §5.3.

## 11. Risks

| Risk | Mitigation |
|---|---|
| A TeX Live upgrade changes font coverage | The §9.3 missing-glyph test fails the build rather than shipping tofu. |
| STIX/Source math pairing looks wrong | Confirm visually during implementation; documented fallbacks in §7.2. |
| The author's existing statements use commands not surveyed here | `examples/` was surveyed for feature coverage (§9.2 table) and the fixtures reproduce every construct found. Further gaps are handled by adding compat shims as they surface, not by importing old statements. |
| Polygon changes its Freemarker contract | The Freemarker layer is thin and emits raw data, so a change affects only `problem.tex` and the two `.ftl` files. |
| Scope is large enough to stall | Sequenced into independently verifiable stages, §12. |

## 12. Implementation sequence

This is a rewrite rather than a patch, so it is sequenced such that every stage
ends with something that compiles and is testable. The stages are ordered by
dependency, not by visibility.

1. **Harness first** — `latexmkrc`, `Makefile`, the `minimal` sample, and the
   §9.3 test runner, validated against the *current* `olymp.sty`. The suite must
   reproduce defects #1 and #2 as failures before anything is rewritten;
   otherwise there is no evidence the tests can detect their return.
2. **Skeleton and language layer** — `vnolymp.sty` with option parsing, plus
   both `-lang-` files and the parity test.
3. **Problem environment** — key–value API, limits panel, sections, subtasks.
   Closes defects #2, #3, #5, #6, #9.
4. **Freemarker layer** — rewrite to emit raw data per §4.2. Closes defects #1,
   #7, #8. The content assertion from §9.3 turns green here.
5. **Visual design** — `vnolymp-style.def`: fonts, colours, tcolorbox styles,
   header/footer, cover page. The largest stage, and the one needing visual
   review rather than only automated checks.
6. **Samples, compat shim, docs, CI** — `kitchen-sink` and `booklet` fixtures,
   `vnolymp-compat.def` validated against the legacy-syntax fixture,
   `README.md`, `docs/AUTHORING.md`, GitHub Actions.

Stage 1 is deliberately first. Writing tests against the broken template proves
they detect the defects, rather than trusting a suite that has only ever seen
correct output.
