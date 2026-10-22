# Vygeneruje lib/l10n/en.dart, de.dart, es.dart z tool/translations_src.py a zkontroluje úplnost.
# python tool/gen_translations.py
import re, sys

sys.path.insert(0, 'tool')
from translations_src import T, KEEP  # noqa: E402
from extract_keys import all_keys  # noqa: E402

LANGS = ['en', 'de', 'es']
PH = re.compile(r'\{(\w+)\}')


def dart(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$').replace('\n', '\\n') + "'"


keys = all_keys()
missing = [k for k in keys if k not in T and k not in KEEP]
unused = [k for k in T if k not in keys]
bad = []
for k, vals in T.items():
    for lang, v in zip(LANGS, vals):
        if sorted(PH.findall(k)) != sorted(PH.findall(v)):
            bad.append((lang, k, v))

for k in missing:
    print('CHYBÍ PŘEKLAD:', k.replace('\n', '\\n'))
for k in unused:
    print('nepoužito:', k.replace('\n', '\\n'))
for lang, k, v in bad:
    print('ŠPATNÉ PROMĚNNÉ', lang, '|', k, '|', v)

for i, lang in enumerate(LANGS):
    lines = [f'// VYGENEROVÁNO z tool/translations_src.py (python tool/gen_translations.py) – needitovat ručně.',
             '// ignore_for_file: lines_longer_than_80_chars',
             f'const {lang} = <String, String>{{']
    # extrahované klíče + ty, co extraktor nevidí (tr uvnitř ${…}, tr(proměnná))
    for k in keys + [k for k in T if k not in keys]:
        if k in T:
            lines.append(f'  {dart(k)}: {dart(T[k][i])},')
    lines.append('};')
    open(f'lib/l10n/{lang}.dart', 'w', encoding='utf-8', newline='').write('\n'.join(lines) + '\n')

print(f'klíčů {len(keys)}, přeloženo {sum(1 for k in keys if k in T)}, chybí {len(missing)}, '
      f'špatné proměnné {len(bad)}')
sys.exit(1 if missing or bad else 0)
