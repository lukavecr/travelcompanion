import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_settings.dart';
import 'core/db_crypto.dart';
import 'data/database.dart';
import 'demo/demo_mode.dart';
import 'firebase_options.dart'; // vygeneruje `flutterfire configure`
import 'core/file_crypto.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // písmo v PDF exportu (Noto Sans) – licence do „Licence knihoven“
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(['Noto Sans'],
        'Copyright 2022 The Noto Project Authors (github.com/notofonts/latin-greek-cyrillic). '
        'Licensed under the SIL Open Font License, Version 1.1 (https://openfontlicense.org).');
  });
  await AppSettings.instance.load();
  // stávající přihlášení uživatelé úvodního průvodce už nepotřebují
  if (!AppSettings.instance.onboardingDone && FirebaseAuth.instance.currentUser != null) {
    await AppSettings.instance.setOnboardingDone(true);
  }
  if (kDemo) {
    // prezentační režim: vymyšlená data jen v paměti, skutečná databáze se neotevře
    final demo = await openDemoDatabase();
    runApp(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(demo)],
      child: const TravelApp(),
    ));
    return;
  }
  // fotky dokladů ze starších verzí zašifrovat, dočasné exporty a kopie fotek smazat
  FileCrypto.encryptExistingFiles();
  FileCrypto.cleanTemp();
  final key = await databaseKey();
  await encryptLegacyDatabase(key);
  runApp(ProviderScope(
    overrides: [databaseKeyProvider.overrideWithValue(key)],
    child: const TravelApp(),
  ));
}
