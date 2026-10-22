# Obalí české texty v lib/ funkcí tr('…') (lib/l10n/tr.dart). Jednorázová pomůcka pro překlad.
# python tool/wrap_strings.py soubor.dart [další…]   (bez souborů = všechny cílové soubory)
# Proměnné v textu: '…$x…' / '…${výraz}…'  ->  tr('…{x}…', {'x': x})
import re, sys, glob

CZ = re.compile(r"[áčďéěíňóřšťúůýžÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ]")
EXCLUDE = (
    'lib/core/country_info.dart',      # data: názvy zemí a klíčová slova (uložené v DB)
    'lib/documents/field_extractor.dart',
    'lib/features/documents/field_extractor.dart',  # slova z OCR
    'lib/features/money/receipt_reader.dart',       # slova z OCR
    'lib/core/geocode.dart',
    'lib/features/pro/pro_service.dart',
    'lib/features/vault/vault_types.dart',          # const definice – překládá se při zobrazení
    'lib/core/week_start_localizations.dart',
    'lib/core/format.dart',
)


def scan_strings(src):
    """Najde jednoduché i složené řetězce '…' (vč. ${…} s vnořenými řetězci). Vrací (start, end, raw)."""
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if src.startswith('//', i):
            j = src.find('\n', i)
            i = n if j < 0 else j
            continue
        if src.startswith('/*', i):
            j = src.find('*/', i)
            i = n if j < 0 else j + 2
            continue
        if c == '"':
            j = i + 1
            while j < n and src[j] != '"':
                j += 2 if src[j] == '\\' else 1
            i = j + 1
            continue
        if c == "'":
            if src.startswith("'''", i):
                j = src.find("'''", i + 3)
                i = j + 3
                continue
            if i > 0 and src[i - 1] == 'r':  # r'regex'
                j = src.find("'", i + 1)
                i = j + 1
                continue
            j = i + 1
            depth = 0
            while j < n:
                ch = src[j]
                if ch == '\\':
                    j += 2
                    continue
                if depth == 0 and ch == "'":
                    break
                if src.startswith('${', j):
                    depth += 1
                    j += 2
                    # projdi výraz, vnořené řetězce přeskoč
                    while j < n and depth > 0:
                        if src[j] == "'":
                            k = j + 1
                            while k < n and src[k] != "'":
                                k += 2 if src[k] == '\\' else 1
                            j = k + 1
                            continue
                        if src[j] == '{':
                            depth += 1
                        elif src[j] == '}':
                            depth -= 1
                        j += 1
                    continue
                if ch == '\n':
                    break
                j += 1
            out.append((i, j + 1, src[i:j + 1]))
            i = j + 1
            continue
        i += 1
    return out


UI_CTX = re.compile(r"(Text\(|label:|labelText:|title:|tooltip:|hintText:|helpText:|subtitle:|content:|confirmLabel:|heading:|\?|:|=>|return)\s*$")


def is_ui(raw, before=''):
    body = raw[1:-1]
    plain = re.sub(r'\$\{.*?\}|\$\w+', '', body)
    if CZ.search(plain):
        return True
    p = plain.strip()
    if re.match(r"^[A-ZÁ-Ž][a-zá-ž]{2,}( [^\s]+)*[ .!?…:]?$", p) and ' ' in p:
        return True
    # jednoslovné popisky („Typ“, „Mapa“) jen v kontextu UI
    return bool(re.fullmatch(r"[A-ZÁ-Ž][a-zá-ž]{1,}", p)) and bool(UI_CTX.search(before))


def convert(raw, used):
    """'Za ${fmtLead(x)} · $t'  ->  ("'Za {lead} · {t}'", "{'lead': fmtLead(x), 't': t}")"""
    body = raw[1:-1]
    args = []
    out = ''
    i = 0
    while i < len(body):
        if body[i] == '\\':
            out += body[i:i + 2]
            i += 2
            continue
        if body.startswith('${', i):
            depth, j = 1, i + 2
            while depth:
                if body[j] == "'":
                    k = j + 1
                    while body[k] != "'":
                        k += 2 if body[k] == '\\' else 1
                    j = k + 1
                    continue
                depth += {'{': 1, '}': -1}.get(body[j], 0)
                j += 1
            expr = body[i + 2:j - 1]
            i = j
        elif body[i] == '$' and i + 1 < len(body) and (body[i + 1].isalpha() or body[i + 1] == '_'):
            m = re.match(r'[A-Za-z_]\w*', body[i + 1:])
            expr = m.group(0)
            i += 1 + len(expr)
        else:
            out += body[i]
            i += 1
            continue
        m = re.findall(r'[A-Za-z_]\w*', re.sub(r"'[^']*'", '', expr))
        base = re.sub(r'^(fmt|format)', '', m[-1] if m and re.fullmatch(r'[\w.!?]+(\(.*\))?', expr) else 'n')
        base = (base[:1].lower() + base[1:]) or 'n'
        name, k = base, 2
        while name in used and used[name] != expr:
            name, k = f'{base}{k}', k + 1
        used[name] = expr
        args.append((name, expr))
        out += '{' + name + '}'
    if not args:
        return "'" + out + "'", None
    return "'" + out + "'", '{' + ', '.join(f"'{a}': {e}" for a, e in dict(args).items()) + '}'


def process(path):
    src = open(path, encoding='utf-8').read()
    strs = scan_strings(src)
    # skupiny sousedních řetězců ('a' 'b')
    groups, cur = [], []
    for s in strs:
        if cur and src[cur[-1][1]:s[0]].strip() == '':
            cur.append(s)
        else:
            if cur:
                groups.append(cur)
            cur = [s]
    if cur:
        groups.append(cur)
    edits = []
    for g in groups:
        start, end = g[0][0], g[-1][1]
        raw_all = "'" + ''.join(x[2][1:-1] for x in g) + "'"
        before = src[:start].rstrip()
        after = src[end:].lstrip()
        if not is_ui(raw_all, before):
            continue
        line_start = src.rfind('\n', 0, start) + 1
        line = src[line_start:start]
        is_key = after.startswith(':') and not before.endswith('?')
        if before.endswith('tr(') or is_key or line.lstrip().startswith(('import', 'export', 'part')):
            continue
        if before.endswith(('case', '==', '!=')) or before.endswith('['):
            continue
        used = {}
        parts, argmaps = [], []
        for x in g:
            lit, args = convert(x[2], used)
            parts.append(lit)
            if args:
                argmaps.append(args)
        if argmaps:
            merged = '{' + ', '.join(a[1:-1] for a in argmaps) + '}'
            repl = 'tr(' + ' '.join(parts) + ', ' + merged + ')'
        else:
            repl = 'tr(' + ' '.join(parts) + ')'
        edits.append((start, end, repl))
    if not edits:
        return 0
    for start, end, repl in reversed(edits):
        src = src[:start] + repl + src[end:]
    if "l10n/tr.dart'" not in src:
        rel = '../' * (path.count('/') - 1) + 'l10n/tr.dart'
        m = list(re.finditer(r"^import '[^']+';\n", src, re.M))
        pos = m[-1].end() if m else 0
        src = src[:pos] + f"import '{rel}';\n" + src[pos:]
    open(path, 'w', encoding='utf-8', newline='').write(src)
    return len(edits)


if __name__ == '__main__':
    targets = sys.argv[1:] or [f.replace('\\', '/') for f in glob.glob('lib/**/*.dart', recursive=True)]
    total = 0
    for f in targets:
        f = f.replace('\\', '/')
        if f.endswith('.g.dart') or f.startswith('lib/l10n/') or f in EXCLUDE:
            continue
        n = process(f)
        if n:
            print(n, f)
        total += n
    print('wrapped', total)
