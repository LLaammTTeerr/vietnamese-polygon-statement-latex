# The two language files must define exactly the same key set.
#
# Without this, adding a Vietnamese string and forgetting its English
# counterpart produces a document that builds cleanly and then errors — or
# worse, prints nothing — only when someone finally builds in English. The
# whole point of extracting a language layer is lost if the layers can drift.
#
# This relies on the one-key-per-line \vnolymp@lang{key}{value} convention
# documented at the top of both files.

keys_of() { grep -o '\\vnolymp@lang{[^}]*}' "$1" | sed 's/.*{\(.*\)}/\1/' | sort; }

vi=vnolymp-lang-vi.def
en=vnolymp-lang-en.def

for f in "$vi" "$en"; do
    [[ -f "$f" ]] || _fail "$f does not exist"
done

if [[ -f "$vi" && -f "$en" ]]; then
    only_vi=$(comm -23 <(keys_of "$vi") <(keys_of "$en") | tr '\n' ' ')
    only_en=$(comm -13 <(keys_of "$vi") <(keys_of "$en") | tr '\n' ' ')

    [[ -z "$only_vi" ]] || _fail "keys defined in Vietnamese but not English: $only_vi"
    [[ -z "$only_en" ]] || _fail "keys defined in English but not Vietnamese: $only_en"

    # Duplicate keys silently shadow one another; the later definition wins.
    for f in "$vi" "$en"; do
        dupes=$(keys_of "$f" | uniq -d | tr '\n' ' ')
        [[ -z "$dupes" ]] || _fail "$f defines duplicate keys: $dupes"
    done

    # A language file that defines nothing would pass every check above.
    n=$(keys_of "$vi" | wc -l)
    [[ "$n" -ge 20 ]] || _fail "only $n keys found in $vi — expected the full set"
fi
