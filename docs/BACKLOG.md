# Backlog (pořadí = priorita)

## 0. Převzetí a ověření stavu (UDĚLEJ NEJDŘÍV)
1. `git status` / `git init` + commit současného stavu projektu.
2. Zjisti, zda projekt už obsahuje fázi 5a (např. `lib/features/documents/receipt_reader.dart`, `schemaVersion = 5` v `lib/data/database.dart`). Pokud ne, najdi `travelcompanion-phase5a-uprava-dokladu.zip` ve Stažených souborech (Downloads), rozbal do dočasné složky a přepiš jím projekt, ale **zachovej** `lib/firebase_options.dart`, `android/app/google-services.json`, `pubspec.yaml` a vygenerované `*.g.dart`.
3. Zkontroluj `pubspec.yaml`: musí obsahovat flutter_riverpod, go_router, drift, drift_flutter, firebase_core, firebase_auth, cloud_firestore, uuid, share_handler, http, url_launcher, flutter_local_notifications, timezone, image_picker, google_mlkit_barcode_scanning, google_mlkit_text_recognition, barcode_widget, path_provider, path, flutter_image_compress, shared_preferences (+ dev: build_runner, drift_dev). Chybějící přidej `flutter pub add`.
4. `dart run build_runner build` (schéma Drift je ve verzi 5), `flutter analyze` → **oprav všechny chyby** (kód fáze 5a nebyl nikdy kompilován).
5. Sestav a spusť na emulátoru (`flutter run -d emulator-5554`), pak `flutter build apk --release --split-per-abi`.
6. Napiš uživateli stručně, co je opraveno a co má vyzkoušet na telefonu (doklad → úprava, záložka Peníze, sdílení trasy z Map).

## 1. Zpětná vazba uživatele k fázi 4/5 (stav: implementováno ve fázi 5a, čeká na ověření)
- Doklady: doplnit **sedadlo, gate / nástupiště, jméno** a **úpravu dokladu** (dřív jen mazání). ✔ (5a)
- Japonský lístek na vlak a vstupenka (Tódai-dži) se nerozpoznaly → přidáno japonské OCR, japonská data/časy. ⚠ ověřit na reálných fotkách – **vyžádej od uživatele „Rozpoznaný text“** z formuláře a laď pravidla.
- Vstupenka na chrám: poznat zemi (Japonsko) a později umístit na mapu. ✔ země (písmo kana, měna 円, klíčová slova). Mapa/souřadnice = bod 3.
- Účtenka Universal Studios: špatná částka (41800 CZK místo 1800 JPY) → měna z písma/円, kategorie „atrakce“, název obchodu. ⚠ ověřit; OCR občas čte „¥“ jako „4“.
- Rezervace výletu v Thajsku: údaje přiřazeny špatně → párování popisek↔hodnota podle polohy (`field_extractor.dart`). ⚠ ověřit na vzorku, případně doplnit další popisky (pick-up, hotel, tour name, adults…).
- Záložka Peníze: **potvrzeno uživatelem** – jen jeden řádek „Vše + cesty“, žádný řádek zemí ani další volby. ✔
- Sdílení míst z Google Map: doplnit **zemi** (Nominatim reverse). ✔ (5a)
- Sdílená **trasa veřejnou dopravou** z Google Map: z odkazu jde získat jen odkud/kam, **ne** časy spojů ani přestupy
  (to by vyžadovalo placené Directions API). ✔ (5a) uloží se jako místo typu „doprava“ s odkazem do Map. Časy si uživatel dopíše z jízdenky.

## 2. Další funkce (dohodnuté kroky)
1. **Mapa** ✔ (OpenFreeMap, anglické popisky). Zbývá: offline oblast (např. PMTiles výřez země přes `vector_map_tiles_pmtiles`), jazyk popisků z nastavení.
2. **Poloha míst** ✔ (sdílení z Map s dohledáním, Plus Code, ruční bod v mapě, moje poloha). Zbývá: u dokladů (vstupenka, hotel)
   vytvořit/propojit `Place`; přibližný výsledek (obec/provincie) zobrazit s menším přiblížením.
3. ~~Nahrávání PDF~~ – uživatel nechce, stačí fotky a screenshoty.
3b. **Bezpečnost** ✔ šifrovaná DB, zámek aplikace (biometrie/PIN), smazání potvrzené ověřením.
   Zbývá: šifrovat i fotky dokladů a zálohu ve Firestore (stejný přístup jako Vault), skrýt náhled v přehledu aplikací (FLAG_SECURE).
4. ✔ **Travel Vault** (hotovo: šifrovaně, heslo Vaultu pro obnovu, mazání po položkách, SOS = SMS s polohou + karta
   pro záchranáře). Notifikace před koncem platnosti ✔. Zbývá: změna hesla Vaultu,
   ambasády. Původní zadání: (pas, víza, očkování, pojištění, nouzové kontakty, ambasády): šifrovaně (AES‑GCM, klíč v Android Keystore, odemknutí biometrií), funguje offline,
   zálohování jen zašifrovaných dat, **nikdy** ne do AI. Tlačítko SOS s kontakty.
   Mazání ve Vaultu **po jednotlivých položkách** (uživatel nechce hromadně smazat např. pas nebo řidičák; pojištění smazat může).
   „Smazat všechna data“ v Nastavení Vault nemaže.
5. Hlavní měna cesty volitelná (teď pevně CZK), přepočet při změně.
6. Nastavení ✔ (sekce Účet / Personalizace / Data / O aplikaci, motiv, měna, týden, formáty, export…). Zbývá: překlad aplikace do EN/DE/ES.
   Původně: Nastavení ✔ základ (Záloha a účet, Smazat všechna data). Zbývá: výchozí země/měna, jazyk aplikace i popisků mapy,
   odhlášení bez míchání dat mezi účty (lokální DB není per-uživatel).
7. Řazení položek dne přetažením i mezi dny.
8. Podpora iOS (ML Kit, Firebase `GoogleService-Info.plist`, oznámení) – až bude Mac.
9. Testy (Drift v paměti, parsery BCBP/field_extractor/guess), CI (`.github/workflows/ci.yml` je hotový základ).
10. Release podpis vlastním klíčem, až půjde do obchodu.

## Pracovní postup pro každý krok
Malý krok → `flutter analyze` → build → `git commit` → stručně uživateli: co je nové a **co přesně má otestovat na telefonu**.
