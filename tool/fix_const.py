# Po obalení textů tr('…') odstraní „const“ u výrazů, které teď nejsou konstantní.
# Opakuje flutter analyze, dokud chyby nezmizí. python tool/fix_const.py
import re, subprocess, collections

ERR = re.compile(r"error - .* - (lib[\\/][^:]+):(\d+):(\d+) - (const_\w+|non_constant_\w+|invalid_constant)")


def analyze():
    p = subprocess.run('flutter analyze', shell=True, capture_output=True, text=True, encoding='utf-8')
    return [(m.group(1).replace('\\', '/'), int(m.group(2)), int(m.group(3)), m.group(4))
            for m in ERR.finditer(p.stdout + p.stderr)]


def offset(src, line, col):
    lines = src.split('\n')
    return sum(len(l) + 1 for l in lines[:line - 1]) + col - 1


def remove_enclosing_const(src, pos):
    """Od pozice chyby jde ven přes závorky a odstraní nejbližší „const“ před otevírací závorkou."""
    depth = 0
    i = pos
    while i > 0:
        i -= 1
        ch = src[i]
        if ch in ')]}':
            depth += 1
        elif ch in '([{':
            if depth:
                depth -= 1
                continue
            # vstup do nadřazené závorky: co je před ní?
            j = i
            # přeskoč jméno konstruktoru / typ (Text, EdgeInsets.all, <String>)
            k = j
            while k > 0 and (src[k - 1].isalnum() or src[k - 1] in '_.<>, '):
                if src[k - 1] in ' ' and src[k - 1 - 5:k - 1] == 'const':
                    break
                k -= 1
            m = re.search(r'\bconst\s+$', src[max(0, k - 12):k])
            seg = src[max(0, k - 12):j]
            mm = re.search(r'\bconst\s+[\w.<>, ]*$', seg)
            if mm:
                a = max(0, k - 12) + mm.start()
                return src[:a] + src[a + len('const'):].lstrip(' ') if False else src[:a] + src[a:].replace('const ', '', 1)
        elif ch == ';':
            break
    # deklarace: const x = …  ->  final x = …
    ls = src.rfind('\n', 0, pos) + 1
    line_end = src.find('\n', pos)
    seg = src[ls:line_end]
    if re.search(r'\bconst\s+\w+\s*=', seg) or re.search(r'\bstatic const\b', seg):
        return src[:ls] + seg.replace('const ', 'final ', 1) + src[line_end:]
    return None


for it in range(40):
    errs = analyze()
    if not errs:
        print('hotovo po', it, 'kolech')
        break
    by_file = collections.defaultdict(list)
    for f, l, c, kind in errs:
        by_file[f].append((l, c, kind))
    changed = 0
    for f, items in by_file.items():
        src = open(f, encoding='utf-8').read()
        # od konce, ať se pozice neposouvají; jen jedna oprava na řádek za kolo
        seen = set()
        for l, c, kind in sorted(items, reverse=True):
            if l in seen:
                continue
            seen.add(l)
            new = remove_enclosing_const(src, offset(src, l, c))
            if new and new != src:
                src = new
                changed += 1
        open(f, 'w', encoding='utf-8', newline='').write(src)
    print('kolo', it, 'chyb', len(errs), 'oprav', changed)
    if not changed:
        for e in errs[:20]:
            print('  ručně:', e)
        break
