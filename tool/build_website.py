# Sestaví vícejazyčný web: website/*.html (angličtina, zdroj) -> website/cs|de|es/*.html
# + přepínač jazyků a hreflang ve všech verzích. Opakovatelné. python tool/build_website.py
import os, re, sys

sys.path.insert(0, 'tool')
from website_i18n import COMMON, INDEX, PRIVACY, DELETE, SECURITY  # noqa: E402

SITE = 'https://comesviae.web.app'
LANGS = ['en', 'cs', 'de', 'es']
NAMES = {'en': 'EN', 'cs': 'CS', 'de': 'DE', 'es': 'ES'}
PAGES = {'index.html': INDEX, 'privacy.html': PRIVACY, 'delete-account.html': DELETE, 'security.html': SECURITY}


def url(lang, page):
    base = '/' if lang == 'en' else f'/{lang}/'
    return base + ('' if page == 'index.html' else page)


def langs_nav(cur, page):
    links = ''.join(
        f'<a href="{url(l, page)}" hreflang="{l}" lang="{l}"' + (' aria-current="true"' if l == cur else '') + f'>{NAMES[l]}</a>'
        for l in LANGS)
    return f'<!--LANGS--><nav class="langs" aria-label="Language">{links}</nav><!--/LANGS-->'


def hreflang(page):
    tags = ''.join(f'<link rel="alternate" hreflang="{l}" href="{SITE}{url(l, page)}">' for l in LANGS)
    tags += f'<link rel="alternate" hreflang="x-default" href="{SITE}{url("en", page)}">'
    return f'<!--HREFLANG-->{tags}<!--/HREFLANG-->'


def put(src, marker, block):
    pat = re.compile(rf'<!--{marker}-->(.*?<!--/{marker}-->)?', re.S)
    assert pat.search(src), marker
    return pat.sub(lambda _: block, src, count=1)


errors = []
for page, items in PAGES.items():
    path = os.path.join('website', page)
    src = open(path, encoding='utf-8').read()
    src = put(src, 'LANGS', langs_nav('en', page))
    src = put(src, 'HREFLANG', hreflang(page))
    open(path, 'w', encoding='utf-8', newline='').write(src)  # anglická verze s přepínačem

    for li, lang in enumerate(LANGS[1:]):
        out = src
        for row in items + COMMON:  # nejdřív celé odstavce, pak společné odkazy uvnitř nich
            en, tr = row[0], row[1 + li]
            if en not in out:
                if row in items:
                    errors.append(f'{lang}/{page}: nenalezeno: {en[:70]}')
                continue
            out = out.replace(en, tr)
        out = out.replace('<html lang="en">', f'<html lang="{lang}">')
        out = re.sub(r'(href|src)="(styles\.css|favicon\.svg|lr-tech-logo\.png)"', r'\1="../\2"', out)
        out = re.sub(r'(img/[a-z0-9_]+)-en\.(webp|png)', rf'\1-{lang}.\2', out)  # obrázek v daném jazyce
        out = re.sub(r'(href|src)="(img/[^"]+)"', r'\1="../\2"', out)
        out = put(out, 'LANGS', langs_nav(lang, page))
        os.makedirs(os.path.join('website', lang), exist_ok=True)
        open(os.path.join('website', lang, page), 'w', encoding='utf-8', newline='').write(out)

if errors:
    print('\n'.join(errors))
    sys.exit(1)
print('hotovo:', ', '.join(f'{l}/' for l in LANGS[1:]))
