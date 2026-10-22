# Průzkum trhu a návrhy vylepšení (23. 10. 2026)

## 1. Konkurence v kostce

| Aplikace | V čem je silná | Cena Pro | Slabina / mezera |
|---|---|---|---|
| **TripIt** | Itinerář z přeposlaných e-mailů (rezervace se samy roztřídí), sdílení, kalendář | ~49 USD/rok (letové alerty, hledání náhradního letu) | Free jen 3 doklady na cestu; žádné výdaje, žádný trezor |
| **Wanderlog** | Mapa se zastávkami, společné plánování ve skupině, import e-mailů | ~40 USD/rok (offline, optimalizace trasy) | Bez rozpočtu a packing listu, AI omezené |
| **Polarsteps** | Automatické sledování trasy (i offline), deník s fotkami, tištěná kniha, video | předplatné „Plus“ (2026) | Slabé na doklady a výdaje |
| **Stippl** | „Vše v jednom“: AI itinerář, rozpočet, balení, výdaje | předplatné | Slabší mapa |
| **TravelSpend** | Výdaje offline, víc měn, denní rozpočet, grafy | ~3 USD/měs. | Jen peníze |
| **Splitwise** | Dělení útrat ve skupině, kdo komu dluží | ~4 USD/měs. | Jen dělení útrat |

**Opakující se stížnosti uživatelů** (recenze, přehledy): offline mapy za paywallem nebo nefunkční bez signálu,
ztráta dat bez zálohy, chybějící synchronizace mezi zařízeními, nutnost registrace kvůli maličkosti.

## 2. Čím už teď vyčníváme
- **Vault + SOS** (šifrovaný pas/víza/pojištění, upozornění na konec platnosti, SMS s polohou, karta pro záchranáře) – to žádný z hlavních konkurentů nemá.
- **Čtení dokladů přímo v telefonu** (QR / palubní lístky / japonské lístky) bez posílání fotek do cloudu.
- **Soukromí**: šifrovaná databáze, zámek aplikace, bez reklam a sledování.
- **Výdaje po zemích** s kurzy ECB + export do Excelu – konkurenti to mají jen v samostatných aplikacích.
- **4 jazyky** od začátku.

Slogan, který z toho plyne: *„Celá cesta v jedné kapse – i bez signálu, a tvoje doklady vidíš jen ty.“*

## 3. Doporučení (seřazeno: dopad ÷ práce, vše bez placených služeb)

### A. Než půjdeme do Google Play (rychlé, velký efekt)
1. **Tísňová čísla podle země v SOS** – statická tabulka (112, 911, 191 Thajsko, 113/114/115 Vietnam…), jedním klepnutím volat. Malá práce, velká důvěra.
2. **Úvodní průvodce + ukázková cesta** – 3 obrazovky „co aplikace umí“ a demo cesta, ať nový uživatel hned vidí plán, doklad a výdaje. Zásadní pro hodnocení v obchodě.
3. **Šifrovat i hlavní zálohu** (stejně jako Vault) – sedí to na náš slib soukromí; teď ho v zásadách musíme přiznat jako „zatím ne“.
4. **Upozornění „check-in“ a „odjezd“** – automaticky 24 h před letem z dokladu a ráno v den odjezdu z ubytování.
5. **Export plánu do kalendáře (ICS) a do PDF** – sdílení plánu s rodinou bez účtu. Zdarma, jednoduché.

### B. Velké funkce s potenciálem pro Pro
6. **Offline mapa země** – stáhnout vybranou zemi (PMTiles z OpenStreetMap, vector_map_tiles_pmtiles). Nejčastější stížnost konkurence → **základ zdarma (1 země), Pro neomezeně**. Soubor je potřeba hostovat (Firebase Hosting má limit; ověřit velikosti zemí).
7. **Import rezervací z e-mailu bez serveru** – v Gmailu „Sdílet“ → text e-mailu do aplikace → rozpoznání letu/hotelu/rezervace v telefonu (stejné parsery jako u fotek). Konkurence (TripIt) to dělá přes server; my offline a soukromě.
8. **Společná cesta a dělení útrat** – pozvat partnera/kamarády, společný plán a výdaje „kdo komu dluží“ (Splitwise uvnitř). Silný důvod k Pro a k šíření aplikace. Vyžaduje sdílené dokumenty ve Firestore a nová pravidla.
9. **Seznam věcí na balení** se šablonami (pláž, hory, dlouhá cesta, s dětmi) + připomínka „pas, nabíječka“ den před odjezdem.
10. **Deník cesty** – fotky a poznámky ke dni, volitelně automatická trasa z GPS (jako Polarsteps). Velká práce, ale skvělé pro Instagram a „lepší konec cesty“.
11. **Widget na plochu „Dnes“** – další položka plánu a rychlé otevření palubního lístku (QR) bez hledání v aplikaci.

### C. Doplňky
12. **Počasí ve dnech cesty** – pozor: Open-Meteo je zdarma jen nekomerčně (komerčně ~29 USD/měs.). Alternativa MET Norway (zdarma s uvedením zdroje) – nutno ověřit podmínky.
13. **Vstupní/vízové požadavky podle pasu** – otevřené datové sady jsou z neoficiálních zdrojů (licence nejasná) → raději odkaz na oficiální stránky MZV/IATA, ne vlastní databázi.
14. **Ambasády a konzuláty ČR** v SOS (statický seznam z MZV).
15. **Převodník měn offline** (poslední stažené kurzy).
16. **Tablet a iPad rozvržení**, větší písmo, podpora čteček obrazovky.

### D. Obchod a růst
- **Vlastní název a ikona** (Travel Companion je obsazený/obecný) – návrhy: „Passo“, „Waypass“, „TripVault“, „Kapsa“ (ověřit ochranné známky).
- **Screenshoty v 4 jazycích**, krátké video (Vault + SOS + sken lístku).
- **Recenze**: po 3. úspěšně uloženém dokladu jemně požádat o hodnocení (Google In-App Review API, zdarma).
- **Test 12 lidí / 14 dní**: rodina + Instagram LR Tech CZ.
- Cena Pro: 299 Kč / 12 € / 12 $ ročně + 7 dní zdarma; zvážit „Founder“ slevu pro první testery (promo kódy Google Play).

## 4. Návrh pořadí práce
1. (týden 1) A1 tísňová čísla, A2 úvodní průvodce + demo, A4 check-in upozornění, A5 ICS/PDF.
2. (týden 2) A3 šifrovaná záloha, C14 ambasády, obchodní podklady (název, ikona, screenshoty).
3. (po spuštění) B6 offline mapa, B7 import z e-mailu, B9 balení.
4. (verze 2) B8 společné cesty + dělení útrat, B10 deník, B11 widget, iPhone v App Store.

## Zdroje
- [Stippl – Best Travel Planning Apps 2026](https://app.stippl.io/blog/best-travel-planning-apps-2026)
- [Polarsteps – best travel planning apps](https://www.polarsteps.com/stories/best-travel-planning-apps)
- [TechPP – AI travel planners (2026)](https://www.techpp.com/2026/09/22/best-ai-travel-planners-that-sync-with-your-confirmation-emails/)
- [Pilot – recenze TripIt](https://www.pilotplans.com/blog/review-of-tripit), [Going – TripIt review](https://www.going.com/guides/tripit-review)
- [Endless Travel Plans – Wanderlog review](https://www.endlesstravelplans.com/guides/planning-tools/wanderlog-review)
- [Polarsteps v App Store](https://apps.apple.com/us/app/polarsteps/id947925763)
- [Too Many Adapters – rozpočtové aplikace](https://toomanyadapters.com/best-budgeting-expense-tracking-apps-travel/)
- [Android Central – Splitwise 2026](https://androidcentral.com/apps-software/the-app-splitwise-is-the-best-hack-to-split-group-trip-expenses-in-2026)
- [marlvel.ai – přehledy stížností (MAPS.ME a další)](https://mwm.ai/apps/apps/mapsme-offline-maps-gps-nav/510623322)
- [Open-Meteo – podmínky](https://open-meteo.com/en/terms), [ceník](https://open-meteo.com/en/pricing)
- [Passport Index dataset (GitHub)](https://github.com/ilyankou/passport-index-dataset)
- [flutter_map – offline mapy](https://docs.fleaflet.dev/v7/tile-servers/offline-mapping), [Protomaps – začínáme](https://docs.protomaps.com/guide/getting-started)
