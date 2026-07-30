# No .tex file may sit in the repository root except problem.tex.
#
# Authoring a statement outside this repository requires TEXINPUTS to point
# here (docs/AUTHORING.md §1), which makes every root file visible to that
# build. A root-level .tex therefore competes for its name with the author's
# own statement: give a statement the same name and the engine can resolve the
# lookup to our file instead, compile a document the author never wrote, and
# report
#
#     ! LaTeX Error: Environment problem undefined.
#
# at a line in a file they have never opened. Nothing in the message names the
# cause. Two legacy entry points, statement.tex and contest.tex, sat here and
# produced exactly this failure; `statement.tex` is the single likeliest name
# for an author's own file, which made it the worst possible squatter.
#
# problem.tex is the one unavoidable case, because Polygon requires that exact
# name on a problem's Files page. It stays, and §1 documents it as reserved.

allowed="problem.tex"

for path in ./*.tex; do
    # A root with no .tex at all would leave the glob unexpanded.
    [[ -e "$path" ]] || continue

    name="$(basename "$path")"
    [[ " $allowed " == *" $name "* ]] || _fail \
        "$name sits in the repository root, where it can shadow an author's own statement of the same name; move it under samples/ or docs/"
done

# The allowlist must not quietly become a list of files that no longer exist:
# were problem.tex renamed or removed, every check above would still pass while
# the Polygon contract silently broke.
[[ -f problem.tex ]] || _fail \
    "problem.tex is missing from the repository root — Polygon requires it under that exact name"
