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
- Nikdy nevypisuj do odpovědí tajné klíče. (`google-services.json` / `firebase_options.dart` jsou jen identifikátory; `firebase_options.dart`
  je commitnutý v soukromém repozitáři – repozitář proto nikdy nezveřejňuj.)

## Kontakt a účty
- Pro aplikaci a všechno kolem ní používá uživatel **lrtechcz@gmail.com** (web, Nominatim User-Agent, git autor, Google Play,
  Firebase, GitHub). Soukromý e-mail už nikam nepřidávat. Owner Pro: `_ownerHashes` v `pro_service.dart` (starý hash odebrat,
  až se přihlášení v aplikaci přepne na nový e-mail – Záloha a účet → Změnit e-mail účtu).

## Pevná omezení (uživatel NEMÁ a NECHCE zadávat platební kartu)
- Žádný Google Maps SDK, žádný Firebase Storage, žádný Blaze plán / Cloud Functions, žádné placené AI API.
- Proto: čtení dokladů **na zařízení** (Google ML Kit – QR/čárové kódy + OCR latinka i japonština),
  mapy budou **OpenStreetMap** (`flutter_map`), kurzy z **frankfurter.dev** (ECB),
  geokódování z **Nominatim** (User-Agent nastavený, max. 1 dotaz/s).
- Obrázky se zálohují **zmenšené do Firestore** (base64, ≤ 650 kB, kolekce `users/{uid}/files/{id}`), ne do Storage.
- Firebase projekt: `travel-companion-ai-e300c`, Auth e-mail/heslo, Firestore (pravidla: jen `users/{uid}/**` pro přihlášeného vlastníka).
- Application ID: `com.lukrom.travelcompanion`.
- E-mail projektu: **lrtechcz@gmail.com** (web, kontakty, účty služeb). Soukromý e-mail uživatele nikam nové nedávat.
  Přechod účtů (Firebase, GitHub, Play, sítě) viz `docs/UCTY.md`.

## Verze a nástrahy (zjištěno při práci)
- Flutter 3.47.x stable, Riverpod **3.x** (`WidgetRef.listen` nemá `fireImmediately` → použij `ref.listenManual` v `initState`),
  go_router 18, Drift 2.35 (`drift_flutter`), cloud_firestore 7, flutter_local_notifications 22 (pojmenované parametry),
  `build_runner`: spouštěj `dart run build_runner build` (přepínač `--delete-conflicting-outputs` už neexistuje).
- **Google Play**: `flutter build appbundle --release -Pplay=true` → AAB podepsaný upload klíčem
  `android/app/upload-keystore.jks` + `android/key.properties` (heslo jen tam; obojí v gitignore – uživatel musí zálohovat).
  Bez `-Pplay` se release APK podepisuje dál debug klíčem (kvůli instalaci přes stávající verzi na Xiaomi).
  Rozhodnutí uživatele: zatím jen Google Play (Apple později), Pro = **roční předplatné**, bez reklam (navrženo).
  **Free/Pro** (`features/pro`): `ProService` (in_app_purchase, předplatné `pro_yearly`, stav z obnovení nákupů, offline
  7 dní z cache), majitel = Pro bez nákupu (SHA-256 e-mailu v `_ownerHashes`). Limity Free: 1 aktivní cesta (bez konce
  nebo konec ≥ dnes), 10 dokladů, 30 výdajů (`ensureCanAdd` → paywall), záloha/sync jen Pro (`syncNow` se ve Free nespustí).
  Vault a SOS zdarma. Návod pro Play Console: `docs/GOOGLE_PLAY.md`.
  V Nastavení je „Smazat účet“ (`deleteAccount`: heslo → reauth, smaže vše vč. Vaultu v cloudu i telefonu, pak účet).
- Release build: R8 je **vypnutý** (`isMinifyEnabled=false`), jinak padá na chybějících třídách ML Kit.
  Do telefonu patří `app-arm64-v8a-release.apk` (`flutter build apk --release --split-per-abi`), podepisuje se debug klíčem
  (`%USERPROFILE%\.android\debug.keystore`; kdo ho ztratí, musí aplikaci odinstalovat).
- `android/app/build.gradle.kts`: core library desugaring zapnuté, `minSdk = max(flutter.minSdkVersion, 24)`,
  závislost `com.google.mlkit:text-recognition-japanese:16.0.0`.
- `AndroidManifest.xml`: `launchMode=singleTask`, intent-filter `SEND text/*` (sdílení z Google Map),
  oprávnění `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, přijímače plánovaných oznámení.
- Sdílení z Google Map: aplikace Map posílá **jen odkaz** `maps.app.goo.gl/…` (bez názvu). Přesměruje na `/maps/place/<Název, adresa>/data=…`,
  většinou **bez souřadnic** (`!3d…!4d…` jen někdy; `@lat,lng` je střed výřezu, ne místo). Google stránka souřadnice neprozradí
  (v EU navíc přesměruje na consent.google.com – posíláme cookie `SOCS=CAI` = odmítnuto). Poloha se proto dohledá přes Nominatim.
  Kontrola z PC: `dart run tool/share_probe.dart "<sdílený text>"`.
- Mapy: CARTO basemaps už chtějí API klíč, wikimedia dlaždice jsou jen pro Wikimedii, tile.openstreetmap.org zakazuje hromadné stahování
  (offline oblasti tedy ne odtud). OpenFreeMap je zdarma bez klíče a bez limitu.
- **Šifrování DB**: `pubspec.yaml` → `hooks: user_defines: sqlite3: source: sqlite3mc` (SQLite3MultipleCiphers). Klíč (32 B hex) v Android
  Keystore přes `flutter_secure_storage` (`core/db_crypto.dart`), načte se v `main()` → `databaseKeyProvider`; drift_flutter `setup` volá
  `PRAGMA key`. Starou nešifrovanou DB `encryptLegacyDatabase` jednorázově převede (`PRAGMA rekey`, mimo WAL, se zálohou).
  Odinstalace aplikace = ztráta klíče → data jen ze zálohy Firestore. Kontrola z PC: `dart run tool/crypto_probe.dart`.
- Testy: `flutter test` (`test/vault_types_test.dart` – texty upozornění, Plus Code; `test/free_limits_test.dart` – limity Free).
- **Zámek aplikace** (`features/lock/app_lock.dart`, `local_auth` 3): při spuštění a po >60 s v pozadí; biometrie nebo PIN telefonu.
  `MainActivity` musí být `FlutterFragmentActivity`. Emulátor nemá zámek obrazovky → ukáže „Pokračovat bez zámku“
  (zámek emulátoru nenastavovat bez souhlasu uživatele). Smazání všech dat se potvrzuje stejným ověřením.
- Záloha ve Firestore zatím **není** šifrovaná na straně aplikace (jen u Googlu); fotky dokladů leží v soukromé složce aplikace
  (šifrováno Androidem, ne aplikací). Vault bude šifrovat end-to-end.
- **Avast** na PC kontroluje HTTPS vlastním certifikátem → Java/Gradle tomu nevěří (PKIX chyba při stahování knihoven).
  Řešení: `~/.gradle/gradle.properties` → `systemProp.javax.net.ssl.trustStore=C:/Users/lukav/.gradle/truststore-avast.p12`
  (kopie `jbr/lib/security/cacerts` + `C:\ProgramData\Avast Software\Avast\wscert.pem`, heslo `changeit`).
  Build se stahováním knihoven spouštěj mimo sandbox nástroje.
- **iPhone** (`docs/IPHONE.md`): sestavení jen na Macu → GitHub Actions `.github/workflows/ios.yml` (ruční spuštění,
  `flutter build ios --no-codesign` → `TravelCompanion.ipa`), instalace Sideloadly s bezplatným Apple ID (platí 7 dní).
  `lib/firebase_options.dart` je v **soukromém** repozitáři github.com/lukavecr/travelcompanion (rozhodnutí uživatele –
  bez secretu); repozitář nesmí být veřejný. `google-services.json` zůstává mimo git. iOS app je ve Firebase už zaregistrovaná (iosBundleId v firebase_options).
  `ios/Podfile`: iOS 15.5 (ML Kit), `GoogleMLKit/TextRecognitionJapanese`. Info.plist: popisy oprávnění (kamera, fotky,
  poloha, Face ID). Sdílení z Map na iOS nejde (Share Extension + App Groups = placený účet) → tlačítko „Vložit odkaz“ na Mapě.
  SMS na iOS: `sms:/open?addresses=…&body=…`.
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
- `features/map` (záložka Mapa: místa všech cest, filtr podle cesty, „Doplnit“ polohu, moje poloha přes `geolocator`,
  dlouhé podržení = uložit bod), `places/locate_place_screen.dart` (hledání polohy: nejdřív uložený odkaz z Map, pak Plus Code /
  adresa / název přes Nominatim, náhled na mapě, klepnutí do mapy = ruční bod).
- `core/plus_code.dart` (vlastní dekodér Open Location Code – balíček `open_location_code` pro Dart 3 neexistuje),
  `core/place_locator.dart` (`locateByText`: Plus Code → adresa → zkrácené varianty → obec/okres).
- `features/vault` – **Travel Vault**: `vault_crypto.dart` (hlavní klíč 256 bit; v Keystore pro odemčení otiskem +
  zabalený heslem Vaultu PBKDF2-SHA256 310k ve Firestore `users/{uid}/vault_meta/key` pro obnovu; AES-256-GCM přes `cryptography`),
  `vault_types.dart` (pas, víza, pojištění, očkování, další doklady, nouzové kontakty, zdravotní údaje – pole a upozornění na platnost),
  `vault_repository.dart` (položky = šifrovaný JSON v `VaultItems.encryptedBlob`; fotky šifrované v `app_flutter/vault/*.bin`),
  `vault_sync.dart` (záloha do `users/{uid}/vault` a `vault_files` – jen šifrovaně; volá se ze `SyncService.syncNow`),
  `vault_screen.dart` (založení/obnova heslem, odemčení otiskem, seznam), `vault_item_screen.dart`, `sos_screen.dart`
  (SMS s polohou nouzovým kontaktům přes aplikaci Zprávy + karta pro záchranáře v angličtině).
  Notifikace konce platnosti: `ReminderService.syncVault` (z `vaultExpiryProvider`, bere nešifrované `type` + `expiresAt`,
  takže funguje i se zamčeným Vaultem), dny předem v `VaultType.remindDays`, v 9:00, text bez citlivých údajů.
  Vault se zamkne se zámkem aplikace. „Smazat všechna data“ Vault nemaže (klíče prefs `vault_*`), mazání jen po položkách.
  **Na emulátoru Vault nezakládat** – zapsal by se klíč s heslem do skutečného účtu uživatele.
- `features/settings` (Nastavení: ozubené kolo na záložce Cesty – Záloha a účet, Smazat všechna data).
- `money_screen.dart`: **jen jeden řádek** „Vše + cesty“ (uživatel výslovně nechce druhý řádek zemí ani další filtry);
  rozpad podle zemí je jen informační graf v Přehledu.
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
- `VaultItems` (type, encryptedBlob = AES-GCM JSON {fields, photos}, expiresAt), `Photos` (zatím nepoužité)

**Pravidlo:** každý zápis do tabulky musí nastavit `updatedAt = now` a `syncState = 'pending'`, mazání je jen soft delete.
Jediná výjimka: Nastavení → „Smazat všechna data“ (`SyncService.wipeAllData`) – nejdřív smaže Firestore, pak natvrdo telefon
(bez `VaultItems`); když cloud selže, telefon se nemaže. Na emulátoru **nespouštět** – je přihlášený ke skutečnému účtu uživatele.
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
