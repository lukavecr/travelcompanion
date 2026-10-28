# Google Play – návod pro zveřejnění

## Stav k 27. 10. 2026
- Účet LR Tech CZ (lrtechcz@gmail.com, ID 9019030464626882931) ověřený; aplikace **Comes Viae** `cz.lrtech.comesviae`
  (ID v konzoli 4976059396892412123), Zdarma.
- Interní testování: vydání 1 (1.0.0) zveřejněné, zatím bez testerů. AAB > 10 MB → nahrává uživatel ručně (přetažením).
- Záznam v obchodu (en-US): název, popisy, ikona, grafika, 8 screenshotů – uloženo (podklady neoznačené jako AI).
- Obsah aplikace hotovo: zásady soukromí, reklamy (ne), inzertní ID (ne), státní (ne), finanční (žádné),
  zdravotní (Aktivita a fitness – kroky; Pohotovost – SOS), hodnocení obsahu (PEGI 3 / ESRB E).
- 28. 10.: Obsah aplikace kompletní (přihlašovací údaje lrtechcz+review – Pro zdarma, cílová skupina 18+, bezpečnost údajů
  9 typů dat, služba v popředí: aktualizace polohy na pozadí + video https://www.youtube.com/watch?v=cI56gbbouhg,
  soubor branding/promo/play_foreground_service_tracking.mp4). Interní vydání 2 (1.0.0+2).
- Zbývá: odeslat změny ke kontrole (Přehled publikování), účet obchodníka → předplatné `pro_yearly`, uzavřený test (12 testerů / 14 dní).

## 1. Vývojářský účet (ty)
1. <https://play.google.com/console/signup> → **Osobní účet**, zaplatit 25 USD (jednorázově).
2. Ověřit totožnost (doklad) a telefon – trvá i několik dní.
3. **Platební profil** (kvůli výplatám z předplatného): Nastavení → Platební profil → bankovní účet.

## 2. Založení aplikace
1. **Vytvořit aplikaci**: název (pracovně „Comes Viae“ – před zveřejněním vymyslet vlastní),
   jazyk čeština, Aplikace, **Zdarma** (předplatné je uvnitř).
2. **Testování → Interní testování → Vytvořit verzi** → nahrát
   `C:\dev\travelcompanion\build\app\outputs\bundle\release\app-release.aab`.
   - Google nabídne **Podepisování aplikací Google Play** → přijmout (Google drží finální klíč, my jen nahrávací).
3. Testeři interního testování: tvůj e-mail → odkaz pro instalaci z Google Play.
   ⚠ Verze z Google Play je podepsaná jinak než APK, které máš teď → stávající aplikaci před instalací
   z Google Play **odinstaluj** (data máš v záloze, po přihlášení se stáhnou; Vault obnovíš heslem Vaultu).

## 3. Předplatné Pro
Předplatné jde založit až po nahrání první verze (krok 2).
1. **Zpeněžení → Produkty → Předplatná → Vytvořit předplatné**
   - ID produktu: **`pro_yearly`** (přesně takhle, je v kódu)
   - Název: Comes Viae Pro
2. **Přidat základní tarif**: ID `yearly`, **Automatické obnovení**, období **1 rok**, cena např. **299 Kč**
   (Google dopočítá ostatní země) → **Aktivovat**.
3. (Volitelně) **Nabídka**: 7 dní zdarma pro nové předplatitele.
4. **Nastavení → Testování licencí** → přidat svůj Google účet (a testerů): nákupy jsou pak zkušební,
   nic se neplatí a roční předplatné se obnovuje po pár minutách.

## 4. Uzavřené testování (povinné pro nový osobní účet)
- **Testování → Uzavřené testování** → seznam testerů (e-maily Google účtů) → aspoň **12 lidí**,
  kteří aplikaci nainstalují a nechají **14 dní v kuse** (Google kontroluje, že ji opravdu používají).
- Pak **Produkční verze → Požádat o přístup**.

## 5. Formuláře (Obsah aplikace)
- **Zásady ochrany soukromí** – URL (připravíme stránku na GitHub Pages).
- **Smazání účtu** – v aplikaci: Nastavení → Smazat účet; navíc webová stránka s postupem (připravíme).
- **Bezpečnost údajů**: e-mail (účet), poloha (přibližná i přesná – mapa, SOS), fotky (doklady),
  zdravotní údaje (Vault – šifrované, nesdílí se), finanční údaje (výdaje). Data se šifrují při přenosu,
  uživatel může požádat o smazání. Nic se neprodává ani nesdílí s třetími stranami pro reklamu.
- **Zdravotní aplikace** – prohlášení: aplikace není zdravotnická, jen ukládá údaje uživatele pro nouzi.
- Hodnocení obsahu (dotazník), cílová skupina 18+, reklamy: **ne**.

## Sestavení nové verze (Claude)
1. Zvýšit verzi v `pubspec.yaml` (`version: 1.0.1+2` – číslo za `+` musí vždy růst).
2. `flutter build appbundle --release -Pplay=true`
3. Nahrát AAB do testování / produkce.
