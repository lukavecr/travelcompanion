import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db_crypto.dart';

part 'database.g.dart';

/// Společné sloupce pro offline synchronizaci.
mixin SyncColumns on Table {
  TextColumn get id => text()(); // uuid
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Trips extends Table with SyncColumns {
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get budget => real().nullable()();
  TextColumn get mainCurrency => text().withDefault(const Constant('CZK'))();
  TextColumn get countries => text().withDefault(const Constant('[]'))(); // JSON
  // společná cesta: null = jen moje, 'owner' = sdílím ji já, 'member' = jsem pozvaný
  TextColumn get shareRole => text().nullable()();
}

class Places extends Table with SyncColumns {
  TextColumn get tripId => text().references(Trips, #id)();
  TextColumn get name => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get type => text().withDefault(const Constant('custom'))();
  TextColumn get mapUrl => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get note => text().nullable()();
}

class Documents extends Table with SyncColumns {
  TextColumn get tripId => text().references(Trips, #id)();
  TextColumn get type => text()();
  TextColumn get localPath => text()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get ocrStatus => text().withDefault(const Constant('pending'))();
  TextColumn get extractedJson => text().nullable()();
  TextColumn get rawText => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get country => text().nullable()();
}

class Expenses extends Table with SyncColumns {
  TextColumn get tripId => text().references(Trips, #id)();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  RealColumn get amountMain => real().nullable()();
  RealColumn get fxRate => real().nullable()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  DateTimeColumn get spentAt => dateTime()();
  TextColumn get country => text().nullable()();
  TextColumn get receiptDocumentId =>
      text().nullable().references(Documents, #id)();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get note => text().nullable()();
  TextColumn get receiptPath => text().nullable()();
  // společná cesta: kdo platil (uid) a za koho (JSON seznam uid; null = všichni)
  TextColumn get paidBy => text().nullable()();
  TextColumn get splitWith => text().nullable()();
}

class CalendarEvents extends Table with SyncColumns {
  TextColumn get tripId => text().references(Trips, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get title => text()();
  TextColumn get placeId => text().nullable().references(Places, #id)();
  TextColumn get documentId => text().nullable().references(Documents, #id)();
  TextColumn get expenseId => text().nullable().references(Expenses, #id)();
  // ubytování: date = příjezd, endDate = odjezd
  DateTimeColumn get endDate => dateTime().nullable()();
  // čas v rámci dne, v minutách od půlnoci (null = bez času)
  IntColumn get startMinutes => integer().nullable()();
  // upozornění X minut předem (null = bez upozornění)
  IntColumn get remindMinutes => integer().nullable()();
}

class Tickets extends Table with SyncColumns {
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get carrier => text().nullable()();
  TextColumn get number => text().nullable()();
  TextColumn get bookingRef => text().nullable()();
  DateTimeColumn get departAt => dateTime().nullable()();
  DateTimeColumn get arriveAt => dateTime().nullable()();
  TextColumn get fromPlace => text().nullable()();
  TextColumn get toPlace => text().nullable()();
  TextColumn get qrData => text().nullable()();
  TextColumn get barcodeData => text().nullable()();
  // qr / pdf417 / aztec / code128 / code39 / ean13 / dataMatrix / unknown
  TextColumn get barcodeFormat => text().nullable()();
  TextColumn get passenger => text().nullable()();
  TextColumn get seat => text().nullable()();
  // gate letu nebo nástupiště
  TextColumn get gate => text().nullable()();
  RealColumn get price => real().nullable()();
  TextColumn get currency => text().nullable()();
}

class Photos extends Table with SyncColumns {
  TextColumn get placeId => text().references(Places, #id)();
  TextColumn get localPath => text()();
  TextColumn get remoteUrl => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
}

/// Zaznamenaná trasa (tracker): body jako JSON [[lat, lng, sekundy od začátku], …].
class Tracks extends Table with SyncColumns {
  TextColumn get tripId => text().nullable().references(Trips, #id)();
  TextColumn get name => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get distanceM => real().withDefault(const Constant(0))();
  TextColumn get points => text().withDefault(const Constant('[]'))();
}

/// Šifrovaný blob; klíč nikdy neopouští zařízení (Android Keystore / iOS Keychain).
class VaultItems extends Table with SyncColumns {
  TextColumn get type => text()();
  BlobColumn get encryptedBlob => blob()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
}

@DriftDatabase(tables: [
  Trips,
  Places,
  Documents,
  Expenses,
  CalendarEvents,
  Tickets,
  Photos,
  VaultItems,
  Tracks,
])
class AppDatabase extends _$AppDatabase {
  /// [key] = klíč šifrování z Android Keystore (viz `core/db_crypto.dart`).
  AppDatabase(String key)
      : super(driftDatabase(
          name: dbName,
          native: DriftNativeOptions(setup: (db) => db.execute(keyPragma(key))),
        ));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(calendarEvents, calendarEvents.endDate);
            await m.addColumn(calendarEvents, calendarEvents.startMinutes);
            await m.addColumn(calendarEvents, calendarEvents.remindMinutes);
          }
          if (from < 3) {
            await m.addColumn(documents, documents.title);
            await m.addColumn(tickets, tickets.barcodeFormat);
          }
          if (from < 4) {
            await m.addColumn(expenses, expenses.note);
            await m.addColumn(expenses, expenses.receiptPath);
          }
          if (from < 5) {
            await m.addColumn(tickets, tickets.passenger);
            await m.addColumn(tickets, tickets.seat);
            await m.addColumn(tickets, tickets.gate);
            await m.addColumn(documents, documents.country);
            await m.addColumn(places, places.country);
          }
          if (from < 6) {
            await m.createTable(tracks);
            await m.addColumn(trips, trips.shareRole);
            await m.addColumn(expenses, expenses.paidBy);
            await m.addColumn(expenses, expenses.splitWith);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Klíč databáze – načte se v `main()` před spuštěním aplikace.
final databaseKeyProvider = Provider<String>((ref) => throw UnimplementedError());

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(ref.watch(databaseKeyProvider));
  ref.onDispose(db.close);
  return db;
});
