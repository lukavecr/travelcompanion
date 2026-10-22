# Najde řetězce s mezerou a písmeny, které nejsou v tr() – podezřelé nepřeložené texty.
import re, sys
sys.path.insert(0, 'tool')
from wrap_strings import scan_strings, EXCLUDE  # noqa: E402
from find_strings import files  # noqa: E402

for f in files():
    if f in EXCLUDE:
        continue
    src = open(f, encoding='utf-8').read()
    for st, en, raw in scan_strings(src):
        body = raw[1:-1]
        before = src[:st].rstrip()
        if before.endswith('tr(') or not re.search(r'[A-Za-zÁ-ž]{2,}', body):
            continue
        if not re.search(r'[a-zá-ž]{2,} [a-zá-ž(]', body) and not re.search(r'\d+ [a-zá-ž]{3,}', body):
            continue
        if re.match(r'^(https?:|package:|[a-z_]+\.|SELECT|PRAGMA|sms:|tel:|mailto:)', body):
            continue
        line = src.count('\n', 0, st) + 1
        print(f'{f}:{line}: {body[:90]}')
