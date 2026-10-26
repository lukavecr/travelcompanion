"""Krátká svislá propagační videa (1080×1920, 15–30 s) z prezentačního režimu v emulátoru.

1) nahraje obrazovku emulátoru (adb screenrecord) při naskriptovaných klepnutích,
2) složí video: tmavé pozadí, telefon s nahrávkou, titulky (PNG z Chrome) podle času, logo na konci.

Spuštění: python tool/promo/videos.py <jazyk> [video…]   (emulátor s prezentační verzí v daném jazyce)
"""
import os
import pathlib
import subprocess
import sys
import time

import imageio_ffmpeg

sys.path.insert(0, os.path.dirname(__file__))
import build_promo as bp  # noqa: E402

ROOT = bp.ROOT
ADB = os.path.expandvars(r'%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe')
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
OUT = ROOT / 'branding' / 'promo'
TMP = OUT / '_video'

# klepnutí v souřadnicích obrazovky 1080×2400; ('wait', s) = pauza
TABS = {'trips': (108, 2150), 'map': (324, 2150), 'docs': (540, 2150), 'money': (756, 2150), 'vault': (972, 2150)}

SCRIPTS = {
    'vault_sos': [('tap', TABS['vault']), ('wait', 3), ('tap', (540, 520)), ('wait', 3), ('back',), ('wait', 1.5),
                  ('tap', (948, 205)), ('wait', 5), ('tap', (540, 1612)), ('wait', 4)],
    'boarding': [('tap', TABS['docs']), ('wait', 2.5), ('tap', (480, 613)), ('wait', 3), ('tap', (540, 520)), ('wait', 4),
                 ('back',), ('wait', 1.5), ('swipe', (540, 1700, 540, 900)), ('wait', 3)],
    'plan_map': [('tap', TABS['trips']), ('wait', 2), ('tap', (480, 405)), ('wait', 3), ('swipe', (540, 1700, 540, 700)),
                 ('wait', 2), ('back',), ('wait', 1), ('tap', TABS['map']), ('wait', 4), ('tap', (764, 204)), ('wait', 2),
                 ('tap', (540, 832)), ('wait', 5)],
    'money': [('tap', TABS['money']), ('wait', 3), ('swipe', (540, 1600, 540, 800)), ('wait', 3),
              ('swipe', (540, 800, 540, 1600)), ('wait', 2), ('tap', (680, 805)), ('wait', 4)],
}

# titulky: (od, do, text) – časy v sekundách nahrávky
CAPTIONS = {
    'vault_sos': {
        'cs': [(0, 7, 'Pas, víza a pojištění<br><span class="accent">v šifrovaném trezoru</span>'),
               (7, 13, 'SOS: poloha blízkým<br><span class="accent">jedním klepnutím</span>'),
               (13, 22, 'Karta pro záchranáře<br><span class="accent">v angličtině</span>')],
        'en': [(0, 7, 'Passport, visas, insurance<br><span class="accent">in an encrypted vault</span>'),
               (7, 13, 'SOS: share your location<br><span class="accent">in one tap</span>'),
               (13, 22, 'A card for rescuers<br><span class="accent">in English</span>')],
    },
    'boarding': {
        'cs': [(0, 7, 'Palubenka a lístky<br><span class="accent">vždy po ruce</span>'),
               (7, 13, 'Kód přes celou obrazovku<br><span class="accent">i bez signálu</span>'),
               (13, 20, 'Údaje se přečtou<br><span class="accent">přímo v telefonu</span>')],
        'en': [(0, 7, 'Boarding passes and tickets<br><span class="accent">always at hand</span>'),
               (7, 13, 'Full-screen code<br><span class="accent">even without signal</span>'),
               (13, 20, 'Details are read<br><span class="accent">right on your phone</span>')],
    },
    'plan_map': {
        'cs': [(0, 8, 'Plán po dnech<br><span class="accent">s ubytováním a časy</span>'),
               (8, 15, 'Místa na mapě<br><span class="accent">i offline</span>'),
               (15, 25, 'Záznam trasy:<br><span class="accent">kudy jsi šel</span>')],
        'en': [(0, 8, 'Day-by-day plan<br><span class="accent">with stays and times</span>'),
               (8, 15, 'Places on the map<br><span class="accent">even offline</span>'),
               (15, 25, 'Route tracking:<br><span class="accent">where you walked</span>')],
    },
    'money': {
        'cs': [(0, 8, 'Výdaje v jakékoli měně<br><span class="accent">kurzy ECB</span>'),
               (8, 18, 'Přehled podle kategorií,<br><span class="accent">dnů a zemí</span>')],
        'en': [(0, 8, 'Spending in any currency<br><span class="accent">ECB rates</span>'),
               (8, 18, 'Breakdown by category,<br><span class="accent">day and country</span>')],
    },
}

END = {'cs': 'Brzy na Google Play', 'en': 'Coming soon to Google Play'}


def adb(*a, timeout=30):
    return subprocess.run([ADB, *a], capture_output=True, timeout=timeout)


def record(name, steps, seconds):
    TMP.mkdir(parents=True, exist_ok=True)
    adb('shell', 'am', 'force-stop', 'cz.lrtech.comesviae')
    adb('shell', 'am', 'start', '-n', 'cz.lrtech.comesviae/com.lukrom.travelcompanion.MainActivity')
    time.sleep(9)
    rec = subprocess.Popen([ADB, 'shell', 'screenrecord', '--time-limit', str(seconds), '--bit-rate', '8000000',
                            f'/sdcard/{name}.mp4'])
    time.sleep(1.2)
    for s in steps:
        if s[0] == 'tap':
            adb('shell', 'input', 'tap', str(s[1][0]), str(s[1][1]))
        elif s[0] == 'swipe':
            x1, y1, x2, y2 = s[1]
            adb('shell', 'input', 'swipe', str(x1), str(y1), str(x2), str(y2), '700')
        elif s[0] == 'back':
            adb('shell', 'input', 'keyevent', '4')
        elif s[0] == 'wait':
            time.sleep(s[1])
    rec.wait(timeout=seconds + 20)
    time.sleep(2)
    raw = TMP / f'{name}_raw.mp4'
    adb('pull', f'/sdcard/{name}.mp4', str(raw), timeout=120)
    return raw


def caption_png(lang, name, i, text):
    body = (f'<div style="position:absolute;left:80px;right:80px;top:120px">'
            f'<h1 style="font-size:86px">{text}</h1></div>')
    css_bg = '<style>body{background:transparent!important}h1{text-shadow:0 4px 24px rgba(0,0,0,.6)}</style>'
    path = f'_video/{lang}_{name}_cap{i}'
    bp.render(path, 1080, 520, bp.page(1080, 520, body).replace('</head>', css_bg + '</head>'), transparent=True)
    return OUT / f'{path}.png'


def end_png(lang):
    body = (f'<div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:50px">'
            f'<div class="brand" style="transform:scale(2)">{bp.MARK}<span>Comes Viae</span></div>'
            f'<h1 style="font-size:64px;text-align:center;padding:0 80px">{bp.SLOGAN[lang]}</h1>'
            f'<span class="pill" style="font-size:40px;padding:20px 40px">{END[lang]}</span></div>'
            + bp.lr(400, 140, 56, 32))
    path = f'_video/{lang}_end'
    bp.render(path, 1080, 1920, bp.page(1080, 1920, body))
    bg = f'_video/bg'
    bp.render(bg, 1080, 1920, bp.page(1080, 1920, phone_frame()))
    return OUT / f'{path}.png', OUT / f'{bg}.png'


# telefon ve videu: nahrávka bez stavového řádku nahoře (108 px) a bez navigační lišty dole (126 px)
PHONE_W, PHONE_Y = 680, 520
PHONE_H = round(PHONE_W * (2400 - 108 - 126) / 1080)
SCREEN_R = 64


def phone_frame():
    """Tělo telefonu (rámeček, tlačítka, kamera) pod videem obrazovky – kreslí se do pozadí."""
    bez = 20
    x, y, w, h = (1080 - PHONE_W) // 2 - bez, PHONE_Y - bez, PHONE_W + 2 * bez, PHONE_H + 2 * bez
    return (f'<div style="position:absolute;left:{x - 7}px;top:{y + 260}px;width:10px;height:110px;border-radius:5px;background:#1b2421"></div>'
            f'<div style="position:absolute;left:{x - 7}px;top:{y + 400}px;width:10px;height:110px;border-radius:5px;background:#1b2421"></div>'
            f'<div style="position:absolute;left:{x + w - 3}px;top:{y + 320}px;width:10px;height:150px;border-radius:5px;background:#1b2421"></div>'
            f'<div style="position:absolute;left:{x}px;top:{y}px;width:{w}px;height:{h}px;border-radius:{SCREEN_R + bez}px;'
            f'background:linear-gradient(145deg,#2b3632,#0b0f0e 40%,#151c1a);box-shadow:inset 0 0 0 2px rgba(255,255,255,.12),'
            f'0 40px 90px rgba(0,0,0,.6)"></div>')


def compose(lang, name, raw, seconds, bg=None, out=None):
    caps = CAPTIONS[name][lang]
    pngs = [caption_png(lang, name, i, t) for i, (_, _, t) in enumerate(caps)]
    end, default_bg = end_png(lang)
    bg = bg or default_bg
    out = out or OUT / lang / 'video' / f'{name}_1080x1920.mp4'
    out.parent.mkdir(parents=True, exist_ok=True)
    # telefon: nahrávka 1080×2400 bez stavového řádku → výška 1360, zaoblené rohy maskou
    inputs = ['-loop', '1', '-i', str(bg), '-i', str(raw)]
    for p in pngs:
        inputs += ['-loop', '1', '-i', str(p)]
    inputs += ['-loop', '1', '-i', str(end)]
    r_ = SCREEN_R
    f = [f'[1:v]crop=1080:{2400 - 108 - 126}:0:108,scale={PHONE_W}:{PHONE_H},format=yuva420p,'
         f"geq=lum='lum(X,Y)':a='if(gt(abs(W/2-X),W/2-{r_})*gt(abs(H/2-Y),H/2-{r_}),"
         f"if(lte(hypot(W/2-{r_}-abs(W/2-X),H/2-{r_}-abs(H/2-Y)),{r_}),255,0),255)':cb='cb(X,Y)':cr='cr(X,Y)'[ph]",
         f'[0:v][ph]overlay=(W-w)/2:{PHONE_Y}[v0]']
    last = 'v0'
    for i, (a, b, _) in enumerate(caps):
        f.append(f"[{last}][{i + 2}:v]overlay=0:0:enable='between(t,{a},{b})'[v{i + 1}]")
        last = f'v{i + 1}'
    e = len(pngs) + 2
    f.append(f"[{e}:v]format=rgba,fade=in:st={seconds}:d=0.6:alpha=1[end]")
    f.append(f"[{last}][end]overlay=0:0:enable='gte(t,{seconds})',format=yuv420p[out]")
    cmd = [FFMPEG, '-y', *inputs, '-filter_complex', ';'.join(f), '-map', '[out]', '-t', str(seconds + 3),
           '-r', '30', '-c:v', 'libx264', '-crf', '20', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', str(out)]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        print(r.stderr[-2000:])
        raise SystemExit(1)
    print('  ', out.relative_to(ROOT))


if __name__ == '__main__':
    lang = sys.argv[1]
    names = sys.argv[2:] or list(SCRIPTS)
    for n in names:
        secs = int(max(b for _, b, _ in CAPTIONS[n][lang]))
        raw = record(f'{lang}_{n}', SCRIPTS[n], secs)
        compose(lang, n, raw, secs)
