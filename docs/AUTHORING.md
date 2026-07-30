# Authoring statements with `vnolymp`

Complete command reference. Every construct below is exercised by a fixture in
`samples/`, so anything documented here is known to work.

Design rationale lives in
`docs/superpowers/specs/2026-07-29-vietnamese-statement-template-design.md`;
this file is the usage contract.

---

## 1. Document skeleton

```latex
\documentclass[11pt, a4paper, oneside]{article}
\usepackage[vietnamese, color, booklet]{vnolymp}

\begin{document}
\contest{Kỳ thi chọn học sinh giỏi Quốc gia}{Hà Nội}{Tháng 3, 2026}
\vnolympcover

\input{p1}
\input{p2}
\end{document}
```

**Build with LuaLaTeX, twice.**

```
lualatex statement.tex && lualatex statement.tex
```

Two passes are not optional. The footer's page total and the cover's
problem-overview table both come from the `.aux` file written by the previous
run. A single pass produces a document with `??` in the footer and an **empty
overview table, with no error**. `latexmk` handles this automatically.

### Building from a problem directory

A statement normally lives in its own problem directory, not in this
repository. Point `TEXINPUTS` at a checkout so the engine can find
`vnolymp.sty` and its modules:

```
export TEXINPUTS=".:/path/to/vietnamese-polygon-statement-latex:"
latexmk -lualatex -interaction=nonstopmode mystatement.tex
```

**Keep `.` first, and do not name your own file `problem.tex`.** `TEXINPUTS`
makes every file in the checkout visible to your build, and the checkout
contains `problem.tex` — the Freemarker template Polygon requires under that
exact name. Give your statement the same name and the lookup can resolve to
the template instead of your file. LuaLaTeX then compiles a document you did
not write and reports

```
! LaTeX Error: Environment problem undefined.
```

with a line number pointing into a file you have never opened. Nothing in the
message names the real cause, so the failure is expensive to diagnose the
first time.

### Package options

| Option | Values | Default | Effect |
|---|---|---|---|
| colour | `color` \| `print` | `color` | `print` replaces the accent with greys for photocopying. |
| document | `booklet` \| `standalone` | `booklet` | `standalone` suppresses the cover and running head. |
| language | `vietnamese` \| `english` | `vietnamese` | Selects the string file. |
| page breaks | `pagebreak` \| `nopagebreak` | `pagebreak` | Whether each problem starts a new page. |
| `hidelimits` | flag | off | Suppresses the limits panel entirely. |

Options are independent and combine freely:
`\usepackage[english, print, standalone, nopagebreak]{vnolymp}`.

### Contest metadata

```latex
\contest{<name>}{<location>}{<date>}
```

All three are free text and may be empty. Consumed by the cover page and the
running head.

```latex
\vnolympcover
```

Emits the cover page: contest name, location, date, and a table of every
problem with its limits and points. **Does nothing in `standalone` mode.** It is
explicit rather than automatic so a document can place front matter before it.

---

## 2. The `problem` environment

```latex
\begin{problem}[<key = value, ...>]{<title>}
  ...
\end{problem}
```

The **title is a mandatory argument**; everything else is an optional key list.

### Keys

| Key | Value | Notes |
|---|---|---|
| `input` | `stdin` or a filename | `stdin` renders as "Đầu vào chuẩn"; anything else is shown as a filename. |
| `output` | `stdout` or a filename | As above. |
| `time` | a bare number, seconds | The unit comes from the language file. Do **not** write `time = 1 giây`. |
| `memory` | a bare number, mebibytes | Rendered as "MB". Do **not** write `memory = 256 MB`. |
| `points` | a number | Shown at the right of the header. Omitted if absent. |
| `author` | free text | Optional panel row. |
| `origin` | free text | Optional panel row. |
| `index` | a number | Overrides the automatic problem counter. |

Every key is optional. **An omitted key produces no panel row at all** — it is
not printed blank or as "not stated".

`time` and `memory` take bare numbers because the package, not the author,
owns the wording. This is what makes the English build work and what stops the
units drifting between problems.

```latex
\begin{problem}[
  input  = stdin, output = stdout,
  time   = 1, memory = 256, points = 100,
  author = {Phan Bình Nguyên Lâm}, origin = {VOI 2026},
]{Dãy con tăng dài nhất}
```

Wrap any value containing a comma or equals sign in braces, as with `author`
above.

### Numbering

A problem is headed "Bài N." **only when the document contains more than one
problem.** A single-problem PDF shows just the title: a number exists to tell
problems apart, and with one problem there is nothing to tell it apart from.

The count comes from the `.aux` file, so — like the page total and the cover
table — it settles on the **second pass**. On a first-ever run nothing is
numbered.

Editorials count too: two `tutorial` environments are numbered, one is not.

`index` overrides the counter and resynchronises it, so `index = 5` is followed
by 6, 7, ….

---

## 3. Sections

Each command emits **a heading and nothing else**. The body is your prose.

| Command | Vietnamese | English |
|---|---|---|
| `\InputFile` | Dữ liệu | Input |
| `\OutputFile` | Kết quả | Output |
| `\Constraints` | Ràng buộc | Constraints |
| `\Scoring` | Chấm điểm | Scoring |
| `\Examples` | Ví dụ | Examples |
| `\Explanation` | Giải thích | Explanation |
| `\Note` | Chú ý | Notes |
| `\Interaction` | Tương tác | Interaction |

`\Example` and `\Examples` are the same command, as are `\Note` and `\Notes`,
and `\Explanation` and `\Explanations`. Vietnamese does not inflect for number.

Statement text goes directly after `\begin{problem}`, before any section
command.

---

## 4. Subtasks

```latex
\begin{subtasks}
  \subtask{30}{$n \le 20$}
  \subtask{30}{$n \le 2000$, mọi đỉnh có bậc không quá $2$}
  \subtask{40}{Không có ràng buộc gì thêm}
\end{subtasks}
```

Renders a table with columns Subtask / Điểm / Ràng buộc.

- The environment **emits its own "Chấm điểm" heading**. Do not write
  `\Scoring` before it.
- The first argument is a **percentage of the problem's total score**, as a
  bare number. The package adds the `%`.
- The percentages **must sum to 100**. If they do not, the build emits a
  warning naming the problem. It is a warning, not an error, so a
  work-in-progress still compiles.

There is no dedicated command for a constraint *matrix* — one column per
constrained variable. Write an ordinary `tabular`; see
`samples/kitchen-sink/kitchen-sink.tex`. Such a table will not automatically
match the document's tinting.

---

## 5. Sample tests

```latex
\Examples
\begin{example}
\exmpfile{ex1.in}{ex1.out}%
\exmpfile{ex2.in}{ex2.out}%
\end{example}
```

`\exmpfile{<input file>}{<output file>}` reads sample data from files — the
form a Polygon package export produces. Each call adds one row.

The trailing `%` matters: without it the newline becomes a spurious space in
the table.

**Inline sample data is not supported.** `\exmp{...}{...}` exists only to raise
a clear error pointing here. Verbatim content cannot be passed as a macro
argument — LaTeX tokenises arguments before the macro body can change
catcodes — so no such command can preserve your data byte for byte. Put sample
data in files and use `\exmpfile`.

That is also where the data belongs: it is what a Polygon export produces and
what the checker reads, so keeping one copy means the statement cannot
disagree with the tests.

The table's column headings name the streams — "Đầu vào chuẩn" / "Đầu ra
chuẩn", or the filenames for a file-based problem. **Line numbers appear
outside the table's left border and number the input lines.**

Long lines wrap, with a visible `↪` continuation marker so a wrap is never
mistaken for a newline. See the second sample in `samples/kitchen-sink/`.

For data too wide to sit in half the page, `examplewide` stacks input above
output instead:

```latex
\begin{examplewide}
\exmpfile{ex.in}{ex.out}%
\end{examplewide}
```

### Figures

`graphicx` is already loaded. Place the image beside the statement:

```latex
\begin{center}
  \includegraphics[width=0.45\linewidth]{tree.png}

  Cây trong ví dụ thứ nhất
\end{center}
```

---

## 6. Editorials

```latex
\begin{tutorial}{Dãy con tăng dài nhất}
  ...
\end{tutorial}
```

Same heading as a problem, without the limits panel. Accepts the same optional
key list.

---

## 7. Things that will surprise you

**`\texttt` does not apply TeX quote ligatures.** In monospace, `` `H' ``
prints as a literal backtick and apostrophe, deliberately — a mono font that
rewrote a backtick as a curly quote could never display one, which matters the
moment a statement quotes shell syntax or a C string literal. For quotation
marks around a character, put them in the surrounding prose:
``ký tự \texttt{H}`` or ``ký tự `H'`` in body text, which does have the
ligatures.

**Sample data is byte-exact.** Ligatures are off inside sample blocks, so a
`--` in test data stays two hyphens.

**Two compiler passes.** See §1.

**`\t` is LaTeX's tie accent.** Do not redefine it to mean `\texttt`; the
package this replaces did, and broke the accent. Use `\texttt`.

---

## 8. Migrating an old statement

The legacy syntax still builds, with a deprecation warning:

```latex
\begin{problem}{Tên bài}{treecut.inp}{treecut.out}{1 giây}{256 megabytes}
```

To modernise it:

| Old | New |
|---|---|
| `\begin{problem}{T}{in}{out}{1 giây}{256 MB}` | `\begin{problem}[input=in, output=out, time=1, memory=256]{T}` |
| `\usepackage{olymp}` | `\usepackage{vnolymp}` |
| `\Subtask` + hand-built table | `subtasks` environment |
| `\SubtaskWithScore{30}` | `\subtask{30}{<constraint>}` |
| `\exmp{...}{...}` | `\exmpfile{in}{out}` — move the data into files |
| `hidesetting` option | `hidelimits` option |
| `landscape` option | removed — it never worked |

Note the limits: positionally they are prose (`1 giây`) and print verbatim;
as keys they are bare numbers and the package supplies the unit. Passing
`time = 1 giây` would render "1 giây giây".
