# Comes Viae na iPhonu – návod

Aplikaci pro iPhone dovoluje Apple sestavit jen na Macu. Použijeme **Mac v cloudu zdarma** (GitHub Actions)
a do iPhonu ji z tohoto PC nahraje program **Sideloadly** s tvým běžným Apple ID (bez placení).

## Jednorázově (cca 30 minut)

### 1. Účet na GitHubu
1. Otevři <https://github.com/signup> a založ účet (e-mail, heslo, uživatelské jméno). Karta není potřeba.
2. Potvrď e-mail.
3. Vpravo nahoře **+ → New repository**:
   - Repository name: `travelcompanion`
   - zvol **Private**
   - nic dalšího nezaškrtávej (žádné README)
   - **Create repository**
4. Napiš Claudovi svoje uživatelské jméno na GitHubu. Claude kód nahraje
   (otevře se okno prohlížeče s přihlášením na GitHub – potvrď ho).

### 2. Sideloadly na PC
1. Nainstaluj **iTunes** a **iCloud** z webu Apple (ne z Microsoft Store):
   <https://www.apple.com/itunes/> – Sideloadly je potřebuje kvůli ovladačům iPhonu.
2. Stáhni a nainstaluj Sideloadly z <https://sideloadly.io>.

### 3. iPhone
1. Připoj iPhone kabelem k PC, na iPhonu potvrď **Důvěřovat tomuto počítači**.
2. (Po první instalaci) **Nastavení → Soukromí a zabezpečení → Režim pro vývojáře → zapnout** (iPhone se restartuje).

## Sestavení a instalace (při každé nové verzi)

1. GitHub → repozitář → **Actions → iPhone (IPA) → Run workflow → Run workflow**.
2. Počkej cca 20–30 minut, až je u běhu zelená fajfka.
3. Klikni na běh → dole **Artifacts → ComesViae-iPhone** → stáhne se ZIP → rozbal → `ComesViae.ipa`.
4. Spusť Sideloadly, iPhone připojený kabelem:
   - přetáhni `ComesViae.ipa` do okna
   - **Apple account**: tvoje Apple ID
   - **Start** → zadej heslo Apple ID (případně kód z dvoufázového ověření)
5. Na iPhonu: **Nastavení → Obecné → Správa VPN a zařízení → tvoje Apple ID → Důvěřovat**.
6. Otevři Comes Viae a přihlas se stejným účtem jako na Androidu – data se stáhnou ze zálohy.
   Vault na iPhonu otevři **heslem Vaultu** (obnova), pak už Face ID.

## Omezení bezplatné cesty
- **Platnost 7 dní** – pak aplikace přestane jít otevřít. Stačí ji v Sideloadly nahrát znovu (data zůstanou).
  Sideloadly umí i automatické obnovení, když je PC zapnuté a iPhone na stejné Wi-Fi.
- Najednou max. 3 takto nahrané aplikace.
- **Sdílení z Google Map do aplikace** na iPhonu nejde (Apple ho dovolí jen s placeným účtem).
  Náhrada: v Google Mapách **Sdílet → Kopírovat odkaz**, pak v aplikaci **Mapa → ikona vložení (📋)**.
- Sestavení na Macu v cloudu: v soukromém repozitáři zdarma zhruba 8–10× za měsíc.
