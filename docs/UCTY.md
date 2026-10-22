# Účty a e-mail projektu

E-mail pro aplikaci a další projekty: **lrtechcz@gmail.com** (dál jen „nový účet“).
Soukromý e-mail má zůstat jen tam, kde to jinak nejde (viz konec).

## Hotovo v projektu (Claude)
- [x] git v tomto projektu podepisuje commity novým e-mailem (`git config --local user.email`). Starší commity zůstávají se soukromým e-mailem; přepisovat historii nebudeme.
- [x] web (`website/`): kontakt a žádost o smazání účtu → nový e-mail
- [x] aplikace: kontakt v User-Agent pro Nominatim → nový e-mail
- [x] aplikace: majitel = Pro zdarma pro oba e-maily (soukromý odebereme, až se přihlásíte novým)
- [x] podpisový klíč pro Google Play neobsahuje e-mail (vystaven na „Travel Companion, lukrom“) – beze změny

## Uděláte vy (Claude účty zakládat ani přepínat nemůže)

### 1. Firebase / Google Cloud – NEJDŘÍV
1. Přihlásit se soukromým účtem na console.firebase.google.com → projekt *travel-companion-ai-e300c*.
2. ⚙ Nastavení projektu → **Uživatelé a oprávnění** → Přidat člena → lrtechcz@gmail.com → role **Vlastník**.
3. V novém Gmailu přijmout pozvánku.
4. Nastavení projektu → Obecné → **E-mail podpory** → lrtechcz@gmail.com (ukazuje se v e-mailech pro obnovu hesla).
5. Authentication → Šablony → u e-mailů „Odpovědět na“ → lrtechcz@gmail.com.
6. Až Claude ověří, že nový účet projekt vidí: odebrat soukromý účet z členů.

Pak Claude na PC: `firebase logout` + `firebase login` novým účtem (otevře se prohlížeč).

### 2. GitHub (repozitář github.com/lukavecr/travelcompanion)
1. Založit nový GitHub účet s novým e-mailem (zdarma), třeba `lrtechcz`.
2. Ve starém účtu: repozitář → Settings → General → **Transfer ownership** → nový účet. Repozitář zůstane **soukromý**.
3. Claude pak přepne adresu repozitáře v počítači a opraví dokumentaci. Akce pro iPhone poběží dál (zdarma i v soukromém repozitáři).

### 3. Google Play Console
- Ještě nezaložený → založit rovnou **novým účtem**.
- Už založený soukromým účtem → Uživatelé a oprávnění → pozvat nový účet jako správce;
  Nastavení → Podrobnosti o vývojáři → **kontaktní e-mail** = nový. Vlastníka účtu Google změnit nedovolí
  (šlo by jen přesunout aplikaci na jiný vývojářský účet, ten stojí znovu 25 USD).

### 4. Instagram a Facebook
- Instagram: založit **novým e-mailem**.
- Facebook stránku musí podle pravidel Mety spravovat skutečný osobní profil. Bude tedy pod vaším osobním
  Facebookem, ale kontaktní e-mail stránky bude nový. Druhý „falešný“ profil Meta maže.

### 5. Apple (později)
- Nové bezplatné Apple ID na nový e-mail pro Sideloadly a později App Store.

### 6. Doména (pokud ji koupíte)
- Registrovat na nový e-mail.

## Rozhodnout
- **Přihlášení v aplikaci**: vaše cestovní data jsou teď pod účtem se soukromým e-mailem. Buď zůstane (je to účet
  uživatele, ne vývojáře), nebo se v aplikaci přidá „Změnit e-mail“ a data se přesunou s ním.
