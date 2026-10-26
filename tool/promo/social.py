"""Příspěvky na sociální sítě s fotkami z cest (angličtina): Instagram, stories, Facebook, videa.

Fotky: branding/promo/_photos/*.jpg (výběr z C:\\dev\\propagace přes photos.py),
screenshoty aplikace: branding/screenshots/raw/en_*.png (prezentační režim).
Výstup: branding/promo/social/… Spuštění: python tool/promo/social.py [images|videos]
"""
import os
import pathlib
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import build_promo as bp  # noqa: E402

ROOT = bp.ROOT
PH = ROOT / 'branding' / 'promo' / '_photos'
OUT = 'social'


def photo(name):
    return (PH / f'{name}.jpg').as_uri()


def bg(name, pos='center', shade_top=.75, shade_bottom=.0):
    """Fotka přes celou plochu se ztmavením nahoře (kvůli textu) a případně dole."""
    return (f'<div style="position:absolute;inset:0;background:url({photo(name)}) {pos}/cover"></div>'
            f'<div style="position:absolute;inset:0;background:linear-gradient(180deg,rgba(8,14,12,{shade_top}) 0%,'
            f'rgba(8,14,12,{shade_top * .45}) 32%,rgba(8,14,12,0) 55%,rgba(8,14,12,{shade_bottom}) 100%)"></div>')


def tag(text):
    return (f'<span style="display:inline-flex;align-items:center;gap:8px;padding:8px 18px;border-radius:999px;'
            f'background:rgba(11,20,18,.55);backdrop-filter:blur(6px);color:#e4f1ed;font-weight:700;font-size:24px">📍 {text}</span>')


SHOT = lambda key: bp.shot('en', key)  # noqa: E731

# (fotka, místo, screenshot, nadpis, podnadpis)
FEATURES = [
    ('sensoji', 'Tokyo, Japan', '02_plan', 'Every day planned.<br><span class="accent">Even offline.</span>',
     'Stays, times and reminders in one day-by-day plan.'),
    ('maya_bay', 'Maya Bay, Thailand', '08_boarding', 'Boarding pass ready.<br><span class="accent">No signal needed.</span>',
     'Snap a ticket – the code and details are read on your phone.'),
    ('white_temple', 'Chiang Rai, Thailand', '10_vault', 'Your passport.<br><span class="accent">For your eyes only.</span>',
     'Passport, visas and insurance in an encrypted vault.'),
    ('erawan', 'Erawan Falls, Thailand', '05_track', 'Every trail,<br><span class="accent">mapped.</span>',
     'Record where you walked – distance, time and the route.'),
    ('bangkok', 'Bangkok, Thailand', '09_money', 'Every baht,<br><span class="accent">counted.</span>',
     'Expenses in any currency with live ECB rates.'),
    ('nikko_bridge', 'Nikko, Japan', '03_map', 'Maps that work<br><span class="accent">off the grid.</span>',
     'Download an area and navigate without internet.'),
    ('fuji_lake', 'Kawaguchiko, Japan', '12_ai', 'Plan it with ChatGPT.<br><span class="accent">Import in one tap.</span>',
     'The AI fills in a template, the app builds the trip.'),
]

SLOGAN = 'Your whole trip in one pocket.'
CTA = 'Coming soon to Google Play'


def render(name, w, h, body):
    bp.render(f'{OUT}/{name}', w, h, bp.page(w, h, body))


def images():
    # 1) úvod karuselu: koláž 2 × 2 + nadpis
    tiles = ['fuji_pagoda', 'maya_cliffs', 'white_temple', 'nikko_bridge']
    grid = ''.join(
        f'<div style="position:absolute;left:{40 + (i % 2) * 510}px;top:{40 + (i // 2) * 470}px;width:490px;height:450px;'
        f'border-radius:28px;background:url({photo(t)}) center/cover"></div>' for i, t in enumerate(tiles))
    body = (grid + '<div style="position:absolute;left:0;right:0;bottom:0;height:520px;'
            'background:linear-gradient(180deg,rgba(11,20,18,0),#0b1412 38%)"></div>'
            f'<div style="position:absolute;left:70px;right:70px;bottom:80px">{bp.brand()}'
            '<h1 style="font-size:88px;margin-top:28px">Around the world.<br><span class="accent">One pocket.</span></h1>'
            '<p class="sub" style="font-size:34px;margin-top:20px">India · Thailand · Japan – planned, ticketed and tracked with one app.</p></div>')
    render('instagram/post_01_around_the_world_1080x1350', 1080, 1350, body)

    # 2…8) funkce: fotka z cest + telefon
    for i, (ph, place, key, title, sub) in enumerate(FEATURES, 2):
        body = (bg(ph, shade_bottom=.7) + f'<div style="position:absolute;left:70px;top:70px;right:70px">{tag(place)}'
                f'<h1 style="font-size:80px;margin-top:30px;text-shadow:0 4px 30px rgba(0,0,0,.5)">{title}</h1>'
                f'<p class="sub" style="font-size:32px;margin-top:18px;color:#e4f1ed;text-shadow:0 2px 16px rgba(0,0,0,.6)">{sub}</p></div>'
                + bp.phone(SHOT(key), 560, 640, 440, 4)
                + f'<div style="position:absolute;left:70px;bottom:60px">{bp.brand()}</div>')
        render(f'instagram/post_{i:02d}_{key[3:]}_1080x1350', 1080, 1350, body)

    # 9) mozaika míst
    tiles = ['india_palace', 'unity', 'white_temple', 'emerald_pool', 'maya_bay', 'blue_temple', 'kegon', 'fuji_lake', 'osaka_castle']
    grid = ''.join(
        f'<div style="position:absolute;left:{40 + (i % 3) * 340}px;top:{280 + (i // 3) * 315}px;width:320px;height:300px;'
        f'border-radius:22px;background:url({photo(t)}) center/cover"></div>' for i, t in enumerate(tiles))
    body = (f'<div style="position:absolute;left:60px;top:50px;right:60px">{bp.brand()}'
            '<h1 style="font-size:56px;margin-top:22px;line-height:1.1">Built on the road,<br><span class="accent">not in an office.</span></h1></div>'
            + grid + '<p class="sub" style="position:absolute;left:60px;right:60px;bottom:60px;font-size:30px">'
            'Every feature was tested on a real trip around the world.</p>')
    render('instagram/post_09_built_on_the_road_1080x1350', 1080, 1350, body)

    # stories 1080 × 1920
    for i, (ph, place, key, title, sub) in enumerate([
        ('krabi_rock', 'Krabi, Thailand', '10_vault', 'Lose your bag,<br><span class="accent">not your passport.</span>',
         'An encrypted copy of your documents – and SOS in one tap.'),
        ('kegon', 'Nikko, Japan', '03_map', 'No signal?<br><span class="accent">No problem.</span>',
         'Offline maps, boarding passes and your plan – all on the phone.'),
        ('emerald_pool', 'Krabi, Thailand', '05_track', 'Wander further.<br><span class="accent">Find your way back.</span>',
         'Record every walk and share it as a picture.'),
    ], 1):
        body = (bg(ph, shade_top=.8) + f'<div style="position:absolute;left:80px;top:140px;right:80px">{tag(place)}'
                f'<h1 style="font-size:96px;margin-top:36px;text-shadow:0 4px 30px rgba(0,0,0,.5)">{title}</h1>'
                f'<p class="sub" style="font-size:38px;margin-top:22px;color:#e4f1ed;text-shadow:0 2px 16px rgba(0,0,0,.6)">{sub}</p>'
                f'<span class="pill" style="font-size:30px;padding:14px 30px;margin-top:30px;background:rgba(11,20,18,.8)">{CTA}</span></div>'
                + bp.phone(SHOT(key), 250, 960, 580))
        render(f'stories/story_{i:02d}_{ph}_1080x1920', 1080, 1920, body)

    # Facebook: příspěvek / náhled odkazu a titulní fotka
    body = (f'<div style="position:absolute;right:0;top:0;bottom:0;width:640px;background:url({photo("maya_bay")}) center/cover"></div>'
            '<div style="position:absolute;right:0;top:0;bottom:0;width:640px;background:linear-gradient(90deg,#0b1412,rgba(11,20,18,0) 45%)"></div>'
            f'<div style="position:absolute;left:60px;top:70px;width:560px">{bp.brand()}'
            f'<h1 style="font-size:60px;margin-top:34px">{SLOGAN}</h1>'
            '<p class="sub" style="font-size:26px;margin-top:20px">Plans, boarding passes, expenses and an encrypted passport vault – even without signal.</p></div>'
            + bp.phone(SHOT('02_plan'), 820, 60, 250, 5))
    render('facebook/post_1200x630', 1200, 630, body)
    body = ('<div style="position:absolute;inset:0;background:#0b1412"></div>'
            f'<div style="position:absolute;left:0;top:0;bottom:0;width:1060px;background:url({photo("fuji_lake")}) center 55%/cover"></div>'
            '<div style="position:absolute;left:560px;top:0;bottom:0;width:520px;background:linear-gradient(90deg,rgba(11,20,18,0),#0b1412)"></div>'
            f'<div style="position:absolute;left:1080px;top:190px;width:500px">{bp.brand()}'
            f'<h1 style="font-size:58px;margin-top:26px">{SLOGAN}</h1></div>')
    render('facebook/cover_1640x624', 1640, 624, body)


# ---------- videa ----------

def videos():
    import videos as v
    tmp = v.TMP
    tmp.mkdir(parents=True, exist_ok=True)
    out_dir = bp.OUT / OUT / 'video'
    out_dir.mkdir(parents=True, exist_ok=True)

    # A) „Around the world“ – prolínání fotek se zoomem, titulky míst, závěr s logem
    seq = [('india_palace', 'Vadodara, India'), ('unity', 'Gujarat, India'), ('white_temple', 'Chiang Rai, Thailand'),
           ('maya_bay', 'Maya Bay, Thailand'), ('erawan', 'Erawan Falls, Thailand'), ('nikko_bridge', 'Nikko, Japan'),
           ('fuji_pagoda', 'Fujiyoshida, Japan'), ('tokyo_night', 'Tokyo, Japan')]
    seg, fade = 2.4, 0.5
    inputs, filters = [], []
    for i, (ph, place) in enumerate(seq):
        # políčko 9:16 s popiskem místa
        body = (bg(ph, shade_top=.0, shade_bottom=.75)
                + f'<div style="position:absolute;left:70px;bottom:170px">{tag(place)}</div>')
        bp.render(f'_video/aw_{i}', 1080, 1920, bp.page(1080, 1920, body))
        inputs += ['-framerate', '30', '-loop', '1', '-t', str(seg), '-i', str(bp.OUT / '_video' / f'aw_{i}.png')]
        z = '1+0.06*on/72' if i % 2 == 0 else '1.06-0.06*on/72'
        filters.append(f"[{i}:v]scale=1188:2112,zoompan=z='{z}':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,"
                       f"trim=duration={seg},setpts=PTS-STARTPTS,fps=30,format=yuv420p,settb=AVTB[p{i}]")
    # titulek přes celé video (nahoře) a závěr
    cap = ('<div style="position:absolute;left:80px;right:80px;top:150px">'
           '<h1 style="font-size:92px;text-shadow:0 4px 30px rgba(0,0,0,.6)">One trip.<br><span class="accent">Three countries.</span><br>One app.</h1></div>')
    bp.render('_video/aw_cap', 1080, 900, bp.page(1080, 900, cap).replace('</head>', '<style>body{background:transparent!important}</style></head>'), transparent=True)
    end_png, _ = v.end_png('en')
    n = len(seq)
    last = 'p0'
    offset = seg - fade
    for i in range(1, n):
        filters.append(f'[{last}][p{i}]xfade=transition=fade:duration={fade}:offset={offset:.2f}[x{i}]')
        last = f'x{i}'
        offset += seg - fade
    total = offset + fade
    inputs += ['-loop', '1', '-i', str(bp.OUT / '_video' / 'aw_cap.png'), '-loop', '1', '-i', str(end_png)]
    filters.append(f"[{last}][{n}:v]overlay=0:0:enable='lt(t,{seg * 2})'[c]")
    filters.append(f"[{n + 1}:v]format=rgba,fade=in:st={total - .2}:d=0.6:alpha=1[e]")
    filters.append(f"[c][e]overlay=0:0:enable='gte(t,{total - .2})',format=yuv420p[out]")
    out = out_dir / 'around_the_world_1080x1920.mp4'
    cmd = [v.FFMPEG, '-y', *inputs, '-filter_complex', ';'.join(filters), '-map', '[out]', '-t', f'{total + 2.8:.2f}',
           '-r', '30', '-c:v', 'libx264', '-crf', '20', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', str(out)]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        print(r.stderr[-3000:])
        raise SystemExit(1)
    print('  ', out.relative_to(ROOT))

    # B) ukázky aplikace (nahrávky z emulátoru) na pozadí fotek z cest
    for name, ph in [('vault_sos', 'krabi_rock'), ('boarding', 'maya_bay'), ('plan_map', 'nikko_stairs'), ('money', 'bangkok')]:
        raw = tmp / f'en_{name}_raw.mp4'
        if not raw.exists():
            print('   chybí nahrávka', raw.name)
            continue
        body = (f'<div style="position:absolute;inset:-40px;background:url({photo(ph)}) center/cover;filter:blur(3px) brightness(.55)"></div>'
                '<div style="position:absolute;inset:0;background:linear-gradient(180deg,rgba(11,20,18,.75),rgba(11,20,18,.15) 40%,rgba(11,20,18,.6))"></div>' + v.phone_frame())
        bp.render(f'_video/bg_{name}', 1080, 1920, bp.page(1080, 1920, body))
        secs = int(max(b for _, b, _ in v.CAPTIONS[name]['en']))
        v.compose('en', name, raw, secs, bg=bp.OUT / '_video' / f'bg_{name}.png', out=out_dir / f'app_{name}_1080x1920.mp4')


if __name__ == '__main__':
    what = sys.argv[1:] or ['images', 'videos']
    if 'images' in what:
        images()
    if 'videos' in what:
        videos()
