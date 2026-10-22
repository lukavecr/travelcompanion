# Najde texty pro uživatele (české řetězce) v lib/ – pomůcka pro překlad.
# python tool/find_strings.py            -> přehled po souborech
# python tool/find_strings.py --untr     -> texty, které ještě nejsou obalené t('…')
import re, glob, sys

CZ = re.compile(r"[áčďéěíňóřšťúůýžÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ]")
LIT = re.compile(r"'((?:[^'\\\n]|\\.)*)'")
SKIP = ('.g.dart', 'week_start_localizations.dart')


def files():
    for f in sorted(glob.glob('lib/**/*.dart', recursive=True)):
        f = f.replace('\\', '/')
        if f.endswith(SKIP) or f.startswith('lib/l10n/'):
            continue
        yield f


def strings(f):
    for i, line in enumerate(open(f, encoding='utf-8'), 1):
        s = line.strip()
        if s.startswith(('//', 'import ', 'export ', 'part ')):
            continue
        for m in LIT.finditer(line):
            v = m.group(1)
            if CZ.search(v) or re.match(r"^[A-ZÁ-Ž][a-zá-ž]+( |$)", v):
                before = line[:m.start()]
                k = before.rfind('tr(')
                wrapped = k >= 0 and before[k:].count('(') > before[k:].count(')')
                yield i, v, wrapped


if __name__ == '__main__':
    untr = '--untr' in sys.argv
    total = 0
    per = []
    for f in files():
        items = [x for x in strings(f) if not (untr and x[2])]
        if items:
            per.append((len(items), f, items))
            total += len(items)
    print('strings', total)
    for n, f, items in sorted(per, reverse=True):
        print(n, f)
        if '-v' in sys.argv:
            for i, v, _ in items:
                print('   ', i, v)
