"""Pomůcky pro práci s fotkami z cest (C:\\dev\\propagace): náhledy a zmenšené kopie pro koláže."""
import os

from PIL import Image, ImageDraw, ImageFont, ImageOps

Image.MAX_IMAGE_PIXELS = None  # vlastní fotky (panoramata / 200 Mpx), ne cizí soubory

SRC = r'C:\dev\propagace'


def files():
    return sorted(f for f in os.listdir(SRC) if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp')))


def load(name, size):
    """Fotka zmenšená tak, aby delší strana byla aspoň `size` (rychle přes JPEG draft), správně otočená."""
    im = Image.open(os.path.join(SRC, name))
    im.draft('RGB', (size, size))
    return ImageOps.exif_transpose(im).convert('RGB')


def sheets(out, per=24, t=300):
    os.makedirs(out, exist_ok=True)
    font = ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf', 28)
    fs = files()
    for s in range(0, len(fs), per):
        sheet = Image.new('RGB', (6 * t, 4 * t), 'white')
        d = ImageDraw.Draw(sheet)
        for i, f in enumerate(fs[s:s + per]):
            im = ImageOps.fit(load(f, t * 2), (t, t))
            x, y = (i % 6) * t, (i // 6) * t
            sheet.paste(im, (x, y))
            d.rectangle([x, y, x + 64, y + 36], fill='black')
            d.text((x + 6, y + 3), str(s + i + 1), fill='yellow', font=font)
        sheet.save(os.path.join(out, f'sheet{s // per + 1}.jpg'), quality=80)
    return fs


if __name__ == '__main__':
    import sys
    fs = sheets(sys.argv[1])
    print(len(fs))
