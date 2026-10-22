# Vypíše všechny klíče překladu: tr('…') v lib/ + popisky z vault_types.dart.
# python tool/extract_keys.py > build/keys.txt     (jeden klíč na řádek, \n jako text)
import re, glob, sys

sys.path.insert(0, 'tool')
from wrap_strings import scan_strings  # noqa: E402


def dart_unescape(s):
    return (s.replace("\\'", "'").replace('\\n', '\n').replace('\\$', '$').replace('\\\\', '\\'))


def keys_in(src):
    strs = scan_strings(src)
    out = []
    idx = 0
    while idx < len(strs):
        st, en, raw = strs[idx]
        if src[:st].rstrip().endswith('tr('):
            parts = [raw[1:-1]]
            j = idx + 1
            while j < len(strs) and src[strs[j - 1][1]:strs[j][0]].strip() == '':
                parts.append(strs[j][2][1:-1])
                j += 1
            out.append(dart_unescape(''.join(parts)))
            idx = j
            continue
        idx += 1
    return out


def all_keys():
    keys = []
    for f in sorted(glob.glob('lib/**/*.dart', recursive=True)):
        f = f.replace('\\', '/')
        if f.endswith('.g.dart') or f.startswith('lib/l10n/'):
            continue
        src = open(f, encoding='utf-8').read()
        keys += keys_in(src)
        if f.endswith('vault_types.dart'):
            keys += [dart_unescape(m) for m in re.findall(r"VaultField\('\w+', '((?:[^'\\]|\\.)*)'", src)]
            keys += [dart_unescape(m) for m in re.findall(r"\blabel: '((?:[^'\\]|\\.)*)'", src)]
    seen, uniq = set(), []
    for k in keys:
        if k not in seen:
            seen.add(k)
            uniq.append(k)
    return uniq


if __name__ == '__main__':
    import json
    ks = all_keys()
    if '--json' in sys.argv:
        print(json.dumps(ks, ensure_ascii=False, indent=0))
    else:
        for k in ks:
            print(k.replace('\n', '\\n'))
        print(len(ks), 'klíčů', file=sys.stderr)
