"""Plán příspěvků na Instagram a Facebook (Meta Business Suite): data, soubory, anglické texty.

python tool/promo/social_plan.py → branding/promo/social/plan.json + plan.html (náhled ke schválení)
"""
import html
import json
import pathlib
import subprocess

import imageio_ffmpeg

ROOT = pathlib.Path(__file__).resolve().parents[2]
SOC = ROOT / 'branding' / 'promo' / 'social'
TIME = '18:00'  # Praha
WEB = 'comesviae.web.app'
TAGS = '#travel #traveltips #backpacking #digitalnomad #travelapp #roundtheworld #solotravel'

POSTS = [
    ('2026-10-28', 'reel', 'video/around_the_world_1080x1920.mp4', 'stories/story_01_krabi_rock_1080x1920.png',
     'One trip. Three countries. One app. 🌏\n\nIndia, Thailand and Japan – every plan, ticket and receipt in one pocket. '
     'Comes Viae (Latin for “companion of the road”) was built on the road, for the road.\n\n'
     f'Coming soon to Google Play → {WEB}'),
    ('2026-10-30', 'post', 'instagram/post_01_around_the_world_1080x1350.png', None,
     'Around the world. One pocket. 🧭\n\nDay-by-day plans, boarding passes, an encrypted vault for your passport and '
     'expenses in any currency – and it all works offline.\n\n'
     f'Link in bio → {WEB}'),
    ('2026-11-02', 'post', 'instagram/post_02_plan_1080x1350.png', None,
     'Your trip, day by day. 🗓️\n\nFlights, stays, places and times in one timeline. Drag to reorder, get a reminder '
     'before check-in and see tomorrow right on your home screen widget.\n\n'
     f'{WEB}'),
    ('2026-11-04', 'reel', 'video/app_plan_map_1080x1920.mp4', None,
     'Plan it. Map it. Go. 🗺️\n\nEvery place of your trip on one map – share a spot straight from Google Maps and '
     'download map areas for when there is no signal.\n\n'
     f'{WEB}'),
    ('2026-11-06', 'post', 'instagram/post_03_boarding_1080x1350.png', None,
     'No signal at the gate? No problem. ✈️\n\nScan your boarding pass once – the QR code opens full screen, even in '
     'airplane mode. Trains, buses and hotel bookings too.\n\n'
     f'{WEB}'),
    ('2026-11-09', 'post', 'instagram/post_04_vault_1080x1350.png', 'stories/story_02_kegon_1080x1920.png',
     'Your passport, safe in your pocket. 🔐\n\nPassport, visas, insurance and vaccinations in an end-to-end encrypted '
     'vault (AES-256). Reminders before anything expires – and only you hold the key.\n\n'
     f'{WEB}'),
    ('2026-11-11', 'reel', 'video/app_vault_sos_1080x1920.mp4', None,
     'When things go wrong, one tap. 🆘\n\nSOS sends your location to your emergency contacts and shows a card for '
     'rescuers in English – plus the local emergency numbers wherever you are.\n\n'
     f'{WEB}'),
    ('2026-11-13', 'post', 'instagram/post_05_track_1080x1350.png', None,
     'Where did you actually walk today? 👣\n\nTrack your route with one tap – right from the widget – and share it as '
     'a picture with distance, time and pace.\n\n'
     f'{WEB}'),
    ('2026-11-16', 'post', 'instagram/post_06_money_1080x1350.png', None,
     'Baht, yen, rupees – one budget. 💸\n\nSnap a receipt, the app reads the total and converts it at the official ECB '
     'rate. Travelling with friends? Split the costs and see who owes whom.\n\n'
     f'{WEB}'),
    ('2026-11-18', 'reel', 'video/app_money_1080x1920.mp4', None,
     'Know where your travel money goes. 📊\n\nExpenses in any currency, by category and by country – no spreadsheets, '
     'no internet needed.\n\n'
     f'{WEB}'),
    ('2026-11-20', 'post', 'instagram/post_07_map_1080x1350.png', None,
     'Offline maps for the places that matter. 📍\n\nDownload an area before you go and find your hostel, temple or '
     'beach even with zero signal.\n\n'
     f'{WEB}'),
    ('2026-11-23', 'post', 'instagram/post_08_ai_1080x1350.png', 'stories/story_03_emerald_pool_1080x1920.png',
     'Let AI plan it. Let Comes Viae carry it. 🤖\n\nAsk ChatGPT, Claude or Gemini for an itinerary, import the file – '
     'and the whole trip with stays and places on the map appears in seconds.\n\n'
     f'{WEB}'),
    ('2026-11-25', 'reel', 'video/app_boarding_1080x1920.mp4', None,
     'From email to gate in seconds. 🎫\n\nShare or paste your booking email, scan the boarding pass – done. Check-in '
     'reminder included.\n\n'
     f'{WEB}'),
    ('2026-11-27', 'post', 'instagram/post_09_built_on_the_road_1080x1350.png', None,
     'Built on the road, not in an office. 🎒\n\nEvery feature of Comes Viae had to survive a real border crossing, a '
     'dead phone and a ticket in Japanese. Made by one traveller on a trip around the world.\n\n'
     f'Coming soon to Google Play → {WEB}'),
]


def thumb(rel):
    src = SOC / rel
    if src.suffix != '.mp4':
        return rel
    out = SOC / '_thumbs' / (src.stem + '.jpg')
    out.parent.mkdir(exist_ok=True)
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-loglevel', 'error', '-y', '-ss', '3', '-i', str(src),
                    '-frames:v', '1', '-vf', 'scale=360:-2', str(out)], check=True)
    return out.relative_to(SOC).as_posix()


def main():
    plan = [{'date': d, 'time': TIME, 'kind': k, 'file': f, 'story': s, 'caption': c + '\n\n' + TAGS}
            for d, k, f, s, c in POSTS]
    (SOC / 'plan.json').write_text(json.dumps(plan, ensure_ascii=False, indent=2), encoding='utf-8')
    days = ['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne']
    import datetime
    rows = ''
    for i, p in enumerate(plan, 1):
        dt = datetime.date.fromisoformat(p['date'])
        story = (f'<div class="story"><img src="{p["story"]}"><span>+ story</span></div>' if p['story'] else '')
        rows += (f'<div class="card"><div class="head"><b>{i}.</b> {days[dt.weekday()]} {dt.day}. {dt.month}. · {TIME} '
                 f'<span class="kind {p["kind"]}">{"Reel (video)" if p["kind"] == "reel" else "Příspěvek"}</span></div>'
                 f'<div class="body"><img class="main" src="{thumb(p["file"])}">{story}'
                 f'<p>{html.escape(p["caption"]).replace(chr(10), "<br>")}</p></div></div>')
    page = f'''<!doctype html><html lang="cs"><head><meta charset="utf-8"><title>Plán příspěvků Comes Viae</title><style>
body{{margin:0;padding:32px;background:#0b1412;color:#e4f1ed;font:15px/1.45 system-ui,sans-serif}}
h1{{margin:0 0 4px;font-size:28px}} .sub{{color:#93aea7;margin-bottom:24px}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(520px,1fr));gap:18px}}
.card{{background:#13201d;border-radius:16px;padding:16px;border:1px solid #1f322d}}
.head{{font-weight:600;margin-bottom:10px}} .kind{{float:right;font-size:12px;padding:2px 10px;border-radius:99px;background:#1f322d}}
.kind.reel{{background:#2dd4a7;color:#062019}}
.body{{display:flex;gap:14px;align-items:flex-start}} .main{{width:150px;border-radius:10px}}
.story{{position:relative}} .story img{{width:70px;border-radius:8px;opacity:.85}}
.story span{{position:absolute;bottom:4px;left:4px;font-size:11px;background:#000a;padding:1px 5px;border-radius:5px}}
p{{margin:0;font-size:13px;color:#c9dbd6}}
</style></head><body><h1>Plán příspěvků · Instagram + Facebook</h1>
<div class="sub">14 příspěvků, Po/St/Pá v {TIME} (Praha), 28. 10. – 27. 11. 2026 · 3 stories navíc · texty anglicky</div>
<div class="grid">{rows}</div></body></html>'''
    (SOC / 'plan.html').write_text(page, encoding='utf-8')
    print(SOC / 'plan.html')


if __name__ == '__main__':
    main()
