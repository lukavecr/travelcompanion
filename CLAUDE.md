# Travel Companion AI – kontext pro Claude Code

Android aplikace (Flutter) pro dlouhodobé cestovatele: cesty, plán po dnech, místa, doklady
(QR / palubní lístky), výdaje s přepočtem měn, upozornění, záloha do Firebase.
Později i iOS. Aplikace je osobní nástroj majitele projektu (Roman) pro cestu kolem světa,
proto je důležitá spolehlivost offline a záloha dat.

## Jak s uživatelem pracovat
- Roman **není programátor**. Spouštěj příkazy sám (flutter, dart, git, adb), nevyžaduj ruční úpravy souborů.
- Piš česky, jednoduše, krátce. Po každém hotovém kroku řekni, **co má na telefonu otestovat**.
- Uživatel má rád, když se **doptáš dopředu**, místo aby ses domýšlel. Má rád vizuální výstupy.
- Prostředí: Windows 11, PowerShell, projekt `C:\dev\travelcompanion`, Android emulátor
  (`emulator-5554`, Pixel 8) a skutečný telefon Xiaomi (arm64-v8a).
- Před většími změnami `git commit` (projekt nemusí být v gitu – když není, udělej `git init` a první commit).
- Nikdy nevypisuj do odpovědí tajné klíče. (`google-services.json` / `firebase_options.dart` jsou jen identifikátory, ale necommituj je na veřejný repozitář.)

## Pevná omezení (uživatel NEMÁ a NECHCE zadávat platební kartu)
- Žádný Google Maps SDK, žádný Firebase Storage, žádný Blaze plán / Cloud Functions, žádné placené AI API.
- Proto: čtení dokladů **na zařízení** (Google ML Kit – QR/čárové kódy + OCR latinka i japonština),
  mapy budou **OpenStreetMap** (`flutter_map`), kurzy z **frankfurter.dev** (ECB),
  geokódování z **Nominatim** (User-Agent nastavený, max. 1 dotaz/s).
- Obrázky se zálohují **zmenšené do Firestore** (base64, ≤ 650 kB, kolekce `users/{uid}/files/{id}`), ne do Storage.
- Firebase projekt: `travel-companion-ai-e300c`, Auth e-mail/heslo, Firestore (pravidla: jen `users/{uid}/**` pro přihlášeného vlastníka).
- Application ID: `com.lukrom.travelcompanion`.

## Verze a nástrahy (zjištěno při práci)
- Flutter 3.47.x stable, Riverpod **3.x** (`WidgetRef.listen` nemá `fireImmediately` → použij `ref.listenManual` v `initState`),
  go_router 18, Drift 2.35 (`drift_flutter`), cloud_firestore 7, flutter_local_notifications 22 (pojmenované parametry),
  `build_runner`: spouštěj `dart run build_runner build` (přepínač `--delete-conflicting-outputs` už neexistuje).
- Release build: R8 je **vypnutý** (`isMinifyEnabled=false`), jinak padá na chybějících třídách ML Kit.
  Do telefonu patří `app-arm64-v8a-release.apk` (`flutter build apk --release --split-per-abi`), podepisuje se debug klíčem
  (`%USERPROFILE%\.android\debug.keystore`; kdo ho ztratí, musí aplikaci odinstalovat).
- `android/app/build.gradle.kts`: core library desugaring zapnuté, `minSdk = max(flutter.minSdkVersion, 24)`,
  závislost `com.google.mlkit:text-recognition-japanese:16.0.0`.
- `AndroidManifest.xml`: `launchMode=singleTask`, intent-filter `SEND text/*` (sdílení z Google Map),
  oprávnění `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, přijímače plánovaných oznámení.
- Mapy: CARTO basemaps už chtějí API klíč, wikimedia dlaždice jsou jen pro Wikimedii, tile.openstreetmap.org zakazuje hromadné stahování
  (offline oblasti tedy ne odtud). OpenFreeMap je zdarma bez klíče a bez limitu.
- Xiaomi/MIUI zabíjí upozornění, dokud uživatel nevypne úsporu baterie pro aplikaci.
- Česká typografie ve stringech: „uvozovky“, ne ASCII. Neinstaluj balíček `intl`, formát dat/čísel řeší `lib/core/format.dart`.

## Architektura
`lib/`
- `core/` – `router.dart` (go_router, `StatefulShellRoute` se 5 záložkami: Cesty, Mapa, Doklady, Peníze, Vault(placeholder)),
  `map_tiles.dart` (podklad mapy: vektorové dlaždice **OpenFreeMap** přes `vector_map_tiles` 9 beta, styl liberty/dark,
  popisky přepsané na `name:<jazyk>` → `name:latin` → `name`, konstanta `mapLabelLanguage = 'en'`; při chybě záloha na raster OSM),
  `theme.dart` (tmavý režim výchozí), `format.dart` (data, čas, `fmtMoney`, `parseAmount`), `dialogs.dart`, `full_image_screen.dart`,
  `country_info.dart` (země↔měna, tipování země), `geocode.dart` (Nominatim reverse + `searchPlaces`, společné omezení 1 dotaz/s).
- `data/database.dart` – Drift (SQLite) = **zdroj pravdy v telefonu**. `schemaVersion = 5`, migrace v `onUpgrade`.
- `features/map` (záložka Mapa: místa všech cest, filtr podle cesty, „Doplnit“ polohu), `places/locate_place_screen.dart`
  (hledání polohy podle názvu přes Nominatim, náhled na mapě, uloží lat/lng + zemi).
- `features/trips` (cesty + plán dne + ubytování od–do + čas + upozornění), `places`, `share_intake` (Android Share Intent z Google Map),
  `documents` (sken fotky → kódy + OCR → formulář → doklad + položka plánu), `money` (výdaje, kurzy, statistiky, účtenky),
  `reminders` (flutter_local_notifications), `sync` (Firestore záloha), `auth`, `shell`.
- Stav: Riverpod providery (`StreamProvider.autoDispose(.family)` nad Drift `watch()`).

### Tabulky (všechny mají `id` uuid, `updatedAt`, `deletedAt` = soft delete, `syncState` = `pending|synced`)
- `Trips` (name, startDate, endDate, notes, budget, mainCurrency='CZK', countries = JSON seznam zemí)
- `Places` (tripId, name, lat, lng – **0,0 = neznámé**, type, mapUrl, note, country)
- `CalendarEvents` (tripId, date, sortOrder, title, placeId?, documentId?, expenseId?, endDate = ubytování od–do,
  startMinutes = čas, remindMinutes = upozornění předem)
- `Documents` (tripId, type, localPath, remoteUrl, ocrStatus, extractedJson, rawText, title, country)
- `Tickets` (documentId, carrier, number, bookingRef, departAt, arriveAt, fromPlace, toPlace, qrData, barcodeData,
  barcodeFormat, passenger, seat, gate, price, currency)
- `Expenses` (tripId, amount, currency, amountMain, fxRate, category, spentAt, country, receiptDocumentId?, source, note, receiptPath)
- `Photos`, `VaultItems` (zatím nepoužité)

**Pravidlo:** každý zápis do tabulky musí nastavit `updatedAt = now` a `syncState = 'pending'`, mazání je jen soft delete.
Změna schématu = zvýšit `schemaVersion` + migrace (`m.addColumn`) + `dart run build_runner build`.

### Synchronizace (`features/sync/sync_service.dart`)
Last-write-wins podle `updatedAt` (ms). Push: řádky `pending` → Firestore `users/{uid}/{tabulka}/{id}` (dávky po 100), pak `synced`
(jen když se `updatedAt` mezitím nezměnil). Pull: dotaz `updatedAt > poslední` po tabulkách ve FK pořadí
(trips, places, documents, expenses, calendarEvents, tickets). Cesty k souborům se nesynchronizují (`sync:file`), obrázky jdou přes kolekci `files`.
Spouští se po přihlášení, při návratu do aplikace, 4 s po lokální změně a ručně (obrazovka „Záloha a účet“).
Vault a Photos se zatím nesynchronizují.

### Čtení dokladů (`features/documents`)
`scan_service.dart` (ML Kit barcode + OCR latinka/japonština), `bcbp.dart` (IATA palubní lístky, striktní i tolerantní parser),
`field_extractor.dart` (párování popisků a hodnot podle polohy řádků OCR – booking, jméno, datum, čas, sedadlo, gate),
`guess.dart` (data, časy, číslo rezervace), `new_document_screen.dart` (nový i úprava dokladu), `document_detail_screen.dart`
(kód jako obraz přes celou obrazovku / originál).
Účtenky: `money/receipt_reader.dart` (částka, měna, kategorie, název obchodu, země).

## Hotovo (vyzkoušeno uživatelem)
Fáze 0 (přihlášení, shell, DB), cesty a plán dne (drag & drop v rámci dne, čas, ubytování od–do, upozornění),
místa + sdílení z Google Map, doklady (QR/BCBP, zobrazení kódu), výdaje + statistiky + země cesty, záloha/obnova z Firebase,
samostatný APK na Xiaomi.

## Právě dodáno, ale ještě NEOTESTOVÁNO a možná se nepřeloží (kód psán bez kompilátoru)
„Fáze 5a“ – zdroje ve fázi 5a jsou v projektu (případně v ZIPu `travelcompanion-phase5a-uprava-dokladu.zip` ve Stažených souborech), viz `docs/BACKLOG.md` bod 0.
