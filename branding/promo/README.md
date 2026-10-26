# Propagační materiály Comes Viae

Vše je vygenerované z **prezentačního režimu** aplikace (vymyšlená data, žádné skutečné údaje).
Složky podle jazyka: `cs`, `en`, `de`, `es`.

| Složka | Co tam je | Rozměr |
|---|---|---|
| `play/screenshot_*` | Screenshoty pro Google Play s nadpisem (8 ks) | 1080 × 1920 |
| `play/feature_graphic_1024x500` | Hlavní obrázek v Google Play | 1024 × 500 |
| `instagram/post_*` | Karusel: úvod + 6 funkcí | 1080 × 1350 |
| `instagram/story_*` | Stories / Reels obal (i pro Facebook stories) | 1080 × 1920 |
| `facebook/post_og_1200x630` | Příspěvek na Facebook a náhled odkazu webu | 1200 × 630 |
| `facebook/cover_1640x624` | Titulní fotka stránky (text je v bezpečné zóně uprostřed) | 1640 × 624 |
| `web/hero_1240x1100` | Obrázek do úvodu webu | 1240 × 1100 |
| `video/*.mp4` | Krátká svislá videa s titulky | 1080 × 1920 |

## Jak vygenerovat znovu
1. Prezentační verze do emulátoru: `flutter build apk --release --split-per-abi --target-platform android-x64 --dart-define=TC_DEMO=true --dart-define=TC_LANG=cs`
   (data: `lib/demo/demo_mode.dart`; nic se nezapisuje do účtu přihlášeného v emulátoru).
2. Screenshoty: `branding/screenshots/raw/<jazyk>_<obrazovka>.png`.
3. Obrázky: `python tool/promo/build_promo.py [cs en de es]` (texty v `tool/promo/promo_texts.py`, vykresluje Chrome).
4. Videa: `python tool/promo/videos.py <jazyk>` (nahrávka emulátoru + titulky, ffmpeg z balíčku `imageio-ffmpeg`).

Po skončení vrátit do emulátoru běžnou verzi: `flutter build apk --release --split-per-abi --target-platform android-x64` a `adb install -r`.
