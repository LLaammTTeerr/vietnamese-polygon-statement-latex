# Harness self-test — this case tests the tests.
#
# assert_no_missing_glyphs is the suite's defence against shipping tofu, and it
# is only as good as the pattern it greps for. During design an ad-hoc check
# expected LuaTeX to write "in font 'Name.otf'" with single quotes. LuaTeX
# actually writes "in font [Name.otf]" with square brackets, so the check
# matched nothing and confidently reported zero missing glyphs for XCharter —
# a font missing all 24 Vietnamese hook-above characters.
#
# This case feeds the detector a font known to fail and requires it to notice.
# If LuaTeX ever changes its log format, this goes red and tells us the real
# assertion has silently stopped working.

if ! grep -q 'Missing character' "$CASE_LOG"; then
    _fail "expected missing-glyph warnings from XCharter but found none — either the log format changed or the font gained the glyphs; assert_no_missing_glyphs may be silently inert"
fi

if ! grep -q 'in font \[' "$CASE_LOG"; then
    _fail "log no longer uses the 'in font [Name]' square-bracket form that assert_no_missing_glyphs greps for"
fi

# And specifically the hook-above class, so a partial coverage change is caught.
for ch in 'ả' 'ể' 'ổ' 'ử'; do
    grep -q "There is no $ch" "$CASE_LOG" \
        || _fail "expected XCharter to be missing '$ch'"
done
