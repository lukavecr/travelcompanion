import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:travelcompanion/core/app_settings.dart';
import 'package:travelcompanion/data/database.dart';
import 'package:travelcompanion/features/onboarding/demo_trip.dart';
import 'package:travelcompanion/features/pro/paywall.dart';
import 'package:travelcompanion/features/trips/trip_export.dart';

void main() {
  late AppDatabase db;
  setUp(() {
    AppSettings.instance.language = 'cs';
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test('ukázková cesta: plán, místa, výdaje – a nepočítá se do limitů zdarma', () async {
    final id = await createDemoTrip(db);
    final events = await (db.select(db.calendarEvents)..where((e) => e.tripId.equals(id))).get();
    final places = await db.select(db.places).get();
    expect(events.length, 9);
    expect(places.where((p) => p.lat != 0).length, 7);
    expect((await usageOf(db, ProLimit.trip)).$1, 0);
    expect((await usageOf(db, ProLimit.expense)).$1, 0);
  });

  test('PDF s plánem ukázkové cesty (build/test_trip.pdf)', () async {
    final id = await createDemoTrip(db);
    final trip = await (db.select(db.trips)..where((t) => t.id.equals(id))).getSingle();
    final events = await (db.select(db.calendarEvents)..where((e) => e.tripId.equals(id))).get()
      ..sort((a, b) => a.date.compareTo(b.date) != 0 ? a.date.compareTo(b.date) : a.sortOrder.compareTo(b.sortOrder));
    final places = {for (final p in await db.select(db.places).get()) p.id: p};
    final expenses = await db.select(db.expenses).get();
    final bytes = await buildTripPdf(
      TripData(trip, events, places, const [], const {}, expenses),
      pw.Font.ttf(File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync().buffer.asByteData()),
      pw.Font.ttf(File('assets/fonts/NotoSans-Bold.ttf').readAsBytesSync().buffer.asByteData()),
    );
    File('build/test_trip.pdf').writeAsBytesSync(bytes);
    expect(bytes.length, greaterThan(1000));
  });
}
