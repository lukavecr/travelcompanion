"""Ikona aplikace Comes Viae (kompas z webu) pro Android (klasická + adaptivní + monochromatická) a iOS.

Spuštění: python tool/gen_app_icon.py  (SVG → PNG přes Chrome headless, zmenšení přes Pillow)
"""
import json
import pathlib
import subprocess
import tempfile

from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[1]
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
BG = '#0f2a23'
FG = '#2dd4a7'

# kompas v souřadnicích 0–64 (jako website/favicon.svg)
COMPASS = '''<circle cx="32" cy="32" r="19" fill="none" stroke="{c}" stroke-width="4"/>
<path d="M32 15v6M32 43v6M15 32h6M43 32h6" stroke="{c}" stroke-width="3" stroke-linecap="round"/>
<path d="M38.5 25.5 35 35l-9.5 3.5L29 29z" fill="{c}"/>'''


def svg_full(bg=True, scale=1.1):
    """Celá ikona 64×64: pozadí + kompas zvětšený kolem středu."""
    t = 32 - 32 * scale
    rect = f'<rect width="64" height="64" fill="{BG}"/>' if bg else ''
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">{rect}'
            f'<g transform="translate({t} {t}) scale({scale})">{COMPASS.format(c=FG)}</g></svg>')


def svg_foreground(color=FG):
    """Popředí adaptivní ikony 108×108 dp: kompas uvnitř bezpečné zóny (průměr 66 dp)."""
    s = 1.5
    t = 54 - 32 * s
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">'
            f'<g transform="translate({t} {t}) scale({s})">{COMPASS.format(c=color)}</g></svg>')


def render(svg, size, out):
    with tempfile.TemporaryDirectory() as d:
        html = pathlib.Path(d) / 'i.html'
        html.write_text(f'<html><body style="margin:0;background:transparent">'
                        f'{svg.replace("<svg ", f"<svg width=\"{size}\" height=\"{size}\" ")}</body></html>', encoding='utf-8')
        subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
                        '--default-background-color=00000000', f'--window-size={size},{size}', f'--screenshot={out}',
                        html.as_uri()], check=True, capture_output=True)
    return Image.open(out).convert('RGBA')


def main():
    tmp = pathlib.Path(tempfile.gettempdir())
    full = render(svg_full(), 1024, tmp / 'cv_full.png')
    fg = render(svg_foreground(), 1024, tmp / 'cv_fg.png')
    mono = render(svg_foreground('#ffffff'), 1024, tmp / 'cv_mono.png')

    res = ROOT / 'android/app/src/main/res'
    for name, legacy in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
        d = res / f'mipmap-{name}'
        # klasická ikona (Android < 8): kruh
        mask = Image.new('L', (1024, 1024), 0)
        from PIL import ImageDraw
        ImageDraw.Draw(mask).ellipse([16, 16, 1008, 1008], fill=255)
        round_icon = Image.new('RGBA', (1024, 1024))
        round_icon.paste(full, mask=mask)
        round_icon.resize((legacy, legacy), Image.LANCZOS).save(d / 'ic_launcher.png')
        a = legacy * 108 // 48
        fg.resize((a, a), Image.LANCZOS).save(d / 'ic_launcher_foreground.png')
        mono.resize((a, a), Image.LANCZOS).save(d / 'ic_launcher_monochrome.png')
    anydpi = res / 'mipmap-anydpi-v26'
    anydpi.mkdir(exist_ok=True)
    (anydpi / 'ic_launcher.xml').write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
        '</adaptive-icon>\n', encoding='utf-8')
    (res / 'values/ic_launcher_background.xml').write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        f'    <color name="ic_launcher_background">{BG}</color>\n</resources>\n', encoding='utf-8')

    # iOS: čtverec bez průhlednosti (zaoblení dělá systém)
    ios = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    rgb = Image.new('RGB', (1024, 1024), BG)
    rgb.paste(full, mask=full)
    for img in json.loads((ios / 'Contents.json').read_text(encoding='utf-8'))['images']:
        px = round(float(img['size'].split('x')[0]) * int(img['scale'][0]))
        rgb.resize((px, px), Image.LANCZOS).save(ios / img['filename'])

    # pro web / Google Play (512 × 512) a logo v aplikaci
    brand = ROOT / 'branding'
    rgb.resize((512, 512), Image.LANCZOS).save(brand / 'app-icon-512.png')
    print('hotovo')


if __name__ == '__main__':
    main()
