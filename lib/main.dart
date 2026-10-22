import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_settings.dart';
import 'core/db_crypto.dart';
import 'data/database.dart';
import 'firebase_options.dart'; // vygeneruje `flutterfire configure`

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppSettings.instance.load();
  final key = await databaseKey();
  await encryptLegacyDatabase(key);
  runApp(ProviderScope(
    overrides: [databaseKeyProvider.overrideWithValue(key)],
    child: const TravelApp(),
  ));
}
