# Vygeneruje lib/core/week_start_localizations.dart: obal MaterialLocalizations, který vše předává
# dál a mění jen firstDayOfWeekIndex. Spuštění: python tool/gen_week_start.py
import re
src = open('C:/src/flutter/packages/flutter/lib/src/material/material_localizations.dart', encoding='utf-8').read()
body = src[src.index('abstract class MaterialLocalizations'):]
body = body[body.index('{')+1:]
# konec třídy = první řádek "}" na začátku
body = body[:re.search(r'^}', body, re.M).start()]
lines = body.split('\n')
decls = []
i = 0
while i < len(lines):
    ln = lines[i]
    if re.match(r'^  [A-Za-z]', ln) and not ln.strip().startswith(('@', '//', 'static')):
        buf = ln.strip()
        while not re.search(r';\s*$|\{\s*$|=>', buf):
            i += 1
            buf += ' ' + lines[i].strip()
        sig = re.split(r'\s*(\{\s*$|=>|;)', buf)[0].strip()
        # sig bez těla: "Type get name" nebo "Type name(params)"
        if sig.endswith(')') and '(' in sig:
            pass
        decls.append(sig)
    i += 1
out = []
for sig in decls:
    m = re.match(r'^(.+?)\s+get\s+(\w+)$', sig)
    if m:
        t, n = m.groups()
        if n == 'firstDayOfWeekIndex':
            continue
        out.append(f'  @override\n  {t} get {n} => _b.{n};')
        continue
    m = re.match(r'^(.+?)\s+(\w+)\((.*)\)$', sig)
    if not m:
        raise SystemExit('neznámá deklarace: ' + sig)
    t, n, params = m.groups()
    args = []
    named = re.search(r'\{(.*)\}', params)
    pos = re.sub(r'\{.*\}|\[|\]', '', params)
    for p in [x.strip() for x in pos.split(',') if x.strip()]:
        args.append(p.split()[-1].split('=')[0])
    if named:
        for p in [x.strip() for x in named.group(1).split(',') if x.strip()]:
            nm = p.replace('required ', '').split('=')[0].split()[-1]
            args.append(f'{nm}: {nm}')
    out.append(f'  @override\n  {t} {n}({params}) => _b.{n}({", ".join(args)});')
hdr = '''// VYGENEROVÁNO: python tool/gen_week_start.py – needitovat ručně.
// ignore_for_file: deprecated_member_use, annotate_overrides
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_settings.dart';

/// MaterialLocalizations se zvoleným prvním dnem týdne (0 = neděle, 1 = pondělí, 6 = sobota).
class WeekStartMaterialLocalizations implements MaterialLocalizations {
  WeekStartMaterialLocalizations(this._b, this.firstDayOfWeekIndex);
  final MaterialLocalizations _b;

  @override
  final int firstDayOfWeekIndex;

'''
tail = '''

/// Delegát: texty Material v jazyce aplikace + první den týdne z nastavení.
class WeekStartMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const WeekStartMaterialDelegate();

  @override
  bool isSupported(Locale locale) => GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async => WeekStartMaterialLocalizations(
      await GlobalMaterialLocalizations.delegate.load(locale), AppSettings.instance.weekStart);

  @override
  bool shouldReload(WeekStartMaterialDelegate old) => true;
}
'''
open('lib/core/week_start_localizations.dart', 'w', encoding='utf-8', newline='').write(hdr + '\n\n'.join(out) + '\n}\n' + tail)
print(len(out), 'members')
