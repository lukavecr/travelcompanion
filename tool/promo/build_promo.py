"""Propagační obrázky: Google Play, web, Instagram, Facebook (cs, en, de, es).

Zdroj: screenshoty z prezentačního režimu (branding/screenshots/raw/<jazyk>_<obrazovka>.png),
texty v promo_texts.py. Každý obrázek je HTML stránka, kterou Chrome vyrenderuje přesně v daném rozměru.
Výstup: branding/promo/<jazyk>/... (hotové PNG) a branding/promo/_html (zdroje).

Spuštění: python tool/promo/build_promo.py [jazyky…]
"""
import os
import pathlib
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
from promo_texts import CTA, FEATURES, SLOGAN, SUB  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[2]
RAW = ROOT / 'branding' / 'screenshots' / 'raw'
OUT = ROOT / 'branding' / 'promo'
HTML = OUT / '_html'
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
LOGO = (ROOT / 'branding' / 'lr-tech-logo-circle-512.png').as_uri()

# značka: kompas z webu (website/index.html, symbol #logo), barva #2DD4A7 = seed motivu aplikace
MARK = '''<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg"><rect width="64" height="64" rx="16" fill="#2dd4a7" opacity=".16"/>
<circle cx="32" cy="32" r="19" fill="none" stroke="#2dd4a7" stroke-width="4"/>
<path d="M32 15v6M32 43v6M15 32h6M43 32h6" stroke="#2dd4a7" stroke-width="3" stroke-linecap="round"/>
<path d="M38.5 25.5 35 35l-9.5 3.5L29 29z" fill="#2dd4a7"/></svg>'''

CSS = '''
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;700;800&display=swap');
*{box-sizing:border-box;margin:0;padding:0}
html,body{width:%(w)dpx;height:%(h)dpx;overflow:hidden}
body{font-family:'Plus Jakarta Sans',sans-serif;color:#e4f1ed;
  background:radial-gradient(120%% 80%% at 85%% 0%%,#145646 0%%,rgba(20,86,70,0) 60%%),
             radial-gradient(90%% 60%% at 0%% 100%%,#173F33 0%%,rgba(23,63,51,0) 70%%),#0b1412;position:relative}
.brand{display:flex;align-items:center;gap:%(bg)dpx;font-weight:800;font-size:%(bf)dpx;letter-spacing:-.01em}
.brand svg{width:%(bm)dpx;height:%(bm)dpx}
h1{font-weight:800;letter-spacing:-.025em;line-height:1.05}
p.sub{font-weight:500;color:#93aea7;line-height:1.35}
.accent{color:#2dd4a7}
.phone{position:absolute;border-radius:%(pr)dpx;border:%(pb)dpx solid #050807;background:#050807;overflow:hidden;
  box-shadow:0 40px 90px rgba(0,0,0,.55),0 0 0 2px rgba(45,212,167,.18)}
.phone img{display:block;width:100%%}
.pill{display:inline-flex;align-items:center;gap:12px;border:2px solid rgba(45,212,167,.5);color:#2dd4a7;
  border-radius:999px;font-weight:700}
.lr{position:absolute;display:flex;align-items:center;gap:12px;color:#8FA59C;font-weight:700}
.lr img{border-radius:50%%}
'''


def page(w, h, body, brand_scale=1.0):
    css = CSS % {'w': w, 'h': h, 'bg': int(14 * brand_scale), 'bf': int(34 * brand_scale), 'bm': int(54 * brand_scale),
                 'pr': int(w * 0.075), 'pb': int(w * 0.013)}
    return f'<!doctype html><html><head><meta charset="utf-8"><style>{css}</style></head><body>{body}</body></html>'


def shot(lang, key):
    f = RAW / f'{lang}_{key}.png'
    if not f.exists():
        f = RAW / f'en_{key}.png'
    return f.as_uri()


def brand(text='Travel Companion'):
    return f'<div class="brand">{MARK}<span>{text}</span></div>'


def phone(src, left, top, width, rot=0, crop_top=0.045):
    # screenshot bez stavového řádku (čas, baterie)
    return (f'<div class="phone" style="left:{left}px;top:{top}px;width:{width}px;height:{int(width * 2400 / 1080 * (1 - crop_top))}px;'
            f'transform:rotate({rot}deg)"><img src="{src}" style="margin-top:-{int(width * 2400 / 1080 * crop_top)}px"></div>')


def lr(left, bottom, size=40, font=24):
    return (f'<div class="lr" style="left:{left}px;bottom:{bottom}px;font-size:{font}px">'
            f'<img src="{LOGO}" width="{size}" height="{size}">LR Tech CZ</div>')


def render(name, w, h, html, transparent=False):
    HTML.mkdir(parents=True, exist_ok=True)
    src = HTML / f'{name.replace("/", "_")}.html'
    src.write_text(html, encoding='utf-8')
    out = OUT / f'{name}.png'
    out.parent.mkdir(parents=True, exist_ok=True)
    extra = ['--default-background-color=00000000'] if transparent else []
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1', *extra,
                    f'--window-size={w},{h}', '--virtual-time-budget=6000', f'--screenshot={out}', src.as_uri()],
                   check=True, capture_output=True)
    print('  ', out.relative_to(ROOT))


def build(lang):
    feats = FEATURES[lang]
    print(lang)
    # --- Google Play: screenshoty s nadpisem 1080×1920 ---
    for i, (key, title, sub) in enumerate(feats, 1):
        body = (f'<div style="position:absolute;left:80px;top:90px;right:80px">'
                f'<h1 style="font-size:84px">{title}</h1><p class="sub" style="font-size:40px;margin-top:26px">{sub}</p></div>'
                + phone(shot(lang, key), 170, 430, 740))
        render(f'{lang}/play/screenshot_{i:02d}_{key}', 1080, 1920, page(1080, 1920, body))

    # --- Google Play: feature graphic 1024×500 ---
    body = (f'<div style="position:absolute;left:60px;top:70px;width:520px">{brand()}'
            f'<h1 style="font-size:50px;margin-top:34px">{SLOGAN[lang]}</h1></div>'
            + phone(shot(lang, '10_vault'), 600, 70, 210, -8) + phone(shot(lang, '02_plan'), 790, 40, 210, 6))
    render(f'{lang}/play/feature_graphic_1024x500', 1024, 500, page(1024, 500, body, 0.9))

    # --- Instagram: karusel 1080×1350 (úvod + funkce) ---
    body = (f'<div style="position:absolute;left:80px;top:90px;right:80px">{brand()}'
            f'<h1 style="font-size:92px;margin-top:60px">{SLOGAN[lang]}</h1>'
            f'<p class="sub" style="font-size:38px;margin-top:30px">{SUB[lang]}</p></div>'
            + phone(shot(lang, '02_plan'), 120, 760, 400, -6) + phone(shot(lang, '08_boarding'), 560, 700, 400, 5))
    render(f'{lang}/instagram/post_01_intro_1080x1350', 1080, 1350, page(1080, 1350, body))
    for i, (key, title, sub) in enumerate(feats[:6], 2):
        body = (f'<div style="position:absolute;left:80px;top:80px;right:80px">'
                f'<div class="pill" style="font-size:26px;padding:10px 22px">{i - 1} / 6</div>'
                f'<h1 style="font-size:80px;margin-top:34px">{title}</h1><p class="sub" style="font-size:36px;margin-top:22px">{sub}</p></div>'
                + phone(shot(lang, key), 250, 470, 580))
        render(f'{lang}/instagram/post_{i:02d}_{key}_1080x1350', 1080, 1350, page(1080, 1350, body))

    # --- Instagram / Facebook stories 1080×1920 ---
    for i, (key, title, sub) in enumerate([feats[2], feats[0], feats[7]], 1):
        body = (f'<div style="position:absolute;left:80px;top:150px;right:80px">{brand()}'
                f'<h1 style="font-size:96px;margin-top:70px">{title}</h1><p class="sub" style="font-size:42px;margin-top:28px">{sub}</p>'
                f'<span class="pill" style="font-size:32px;padding:14px 30px;margin-top:36px">{CTA[lang]}</span></div>'
                + phone(shot(lang, key), 200, 860, 680))
        render(f'{lang}/instagram/story_{i:02d}_{key}_1080x1920', 1080, 1920, page(1080, 1920, body))

    # --- Facebook příspěvek / náhled odkazu (og:image) 1200×630 ---
    body = (f'<div style="position:absolute;left:70px;top:80px;width:600px">{brand()}'
            f'<h1 style="font-size:58px;margin-top:40px">{SLOGAN[lang]}</h1>'
            f'<p class="sub" style="font-size:26px;margin-top:22px">{SUB[lang]}</p></div>'
            + phone(shot(lang, '02_plan'), 720, 70, 230, -6) + phone(shot(lang, '10_vault'), 930, 40, 230, 6))
    render(f'{lang}/facebook/post_og_1200x630', 1200, 630, page(1200, 630, body))

    # --- Facebook titulní fotka 1640×624 (bezpečná zóna uprostřed) ---
    body = (f'<div style="position:absolute;left:250px;top:150px;width:640px">{brand()}'
            f'<h1 style="font-size:60px;margin-top:34px">{SLOGAN[lang]}</h1></div>'
            + phone(shot(lang, '08_boarding'), 960, 110, 200, -7) + phone(shot(lang, '02_plan'), 1130, 60, 220, 0)
            + phone(shot(lang, '10_vault'), 1320, 110, 200, 7))
    render(f'{lang}/facebook/cover_1640x624', 1640, 624, page(1640, 624, body))


def build_web():
    # obrázek do úvodu webu: 3 telefony, průhledné pozadí se nedá → tmavé jako web
    for lang in ['en', 'cs', 'de', 'es']:
        body = (phone(shot(lang, '08_boarding'), 60, 150, 400, -8) + phone(shot(lang, '02_plan'), 400, 60, 440, 0)
                + phone(shot(lang, '10_vault'), 780, 150, 400, 8))
        render(f'{lang}/web/hero_1240x1100', 1240, 1100, page(1240, 1100, body))


if __name__ == '__main__':
    langs = sys.argv[1:] or ['cs', 'en', 'de', 'es']
    for l in langs:
        build(l)
    build_web()
