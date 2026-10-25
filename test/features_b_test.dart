import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/core/app_settings.dart';
import 'package:travelcompanion/core/format.dart';
import 'package:travelcompanion/data/database.dart';
import 'package:travelcompanion/features/offline_maps/offline_tiles.dart';
import 'package:travelcompanion/features/tracks/tracker_service.dart';
import 'package:travelcompanion/features/widget/home_widget_service.dart';

void main() {
  late AppDatabase db;
  setUp(() {
    AppSettings.instance.language = 'cs';
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test('widget: plán po dnech, odjezd z ubytování, dnešní útrata', () async {
    final today = DateTime(2026, 10, 23, 15);
    await db.into(db.trips).insert(TripsCompanion.insert(
        id: 't', name: 'Japonsko', startDate: Value(DateTime(2026, 10, 20)), endDate: Value(DateTime(2026, 11, 2)),
        mainCurrency: const Value('CZK')));
    Future<void> ev(String id, DateTime d, String title, {int? min, DateTime? end}) =>
        db.into(db.calendarEvents).insert(CalendarEventsCompanion.insert(
            id: id, tripId: 't', date: d, title: title, startMinutes: Value(min), endDate: Value(end)));
    await ev('a', DateTime(2026, 10, 23), 'Sensō-ji', min: 600);
    await ev('b', DateTime(2026, 10, 23), 'Ramen');
    await ev('c', DateTime(2026, 10, 21), 'Hotel Gracery', end: DateTime(2026, 10, 24));
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        id: 'x', tripId: 't', amount: 1500, currency: 'JPY', amountMain: const Value(230), spentAt: today));
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        id: 'y', tripId: 't', amount: 500, currency: 'JPY', amountMain: const Value(77), spentAt: today));

    final p = buildWidgetPayload(
      trips: await db.select(db.trips).get(),
      events: await db.select(db.calendarEvents).get(),
      expenses: await db.select(db.expenses).get(),
      today: today,
    );
    expect(p.title, 'Japonsko');
    expect(p.days.length, widgetDays);
    expect(p.days[0]['d'], '2026-10-23');
    expect(p.days[0]['items'], ['Ramen', '10:00  Sensō-ji']);
    expect(p.days[1]['items'], ['🏨 Odjezd: Hotel Gracery']);
    expect(p.days[2]['items'], isEmpty);
    expect(p.spend['2026-10-23'], '307 CZK');
  });

  test('trasa: délka, uložení bodů a GPX', () {
    final pts = <TrackPoint>[(50.0875, 14.4213, 0), (50.0865, 14.4114, 300), (50.0840, 14.4005, 620)];
    final len = trackLength(pts);
    expect(len, closeTo(1520, 40)); // Staroměstské nám. → Karlův most → Malostranská
    final back = decodePoints(encodePoints(pts));
    expect(back.length, 3);
    expect(back[1].$3, 300);
    expect(fmtDistance(len), startsWith('1,5'));
    expect(fmtDistance(420), '420 m');
    final t = Track(id: 'x', updatedAt: DateTime(2026), syncState: 'pending', name: 'Praha & okolí',
        startedAt: DateTime.utc(2026, 10, 23, 8), distanceM: len, points: encodePoints(pts));
    final gpx = buildGpx(t);
    expect(gpx, contains('<name>Praha &amp; okolí</name>'));
    expect(gpx, contains('<trkpt lat="50.0865" lon="14.4114"><time>2026-10-23T08:05:00.000Z</time>'));
  });

  test('offline mapa: dlaždice oblasti', () {
    const praha = Bbox(14.33, 50.03, 14.53, 50.13);
    expect(tilesOf(praha, 0).single, (0, 0, 0));
    expect(tilesOf(praha, 14).where((t) => t.$1 == 14).length, 10 * 8);
    expect(tileCount(praha, 14), tilesOf(praha, 14).length);
    expect(tileCount(praha, 14), lessThan(maxTilesPerRegion));
  });

  test('widget: den přechodu na zimní čas (25. 10. 2026 má 25 hodin)', () async {
    final p = buildWidgetPayload(trips: const [], events: const [], expenses: const [], today: DateTime(2026, 10, 25, 8, 21));
    expect([for (final d in p.days.take(3)) d['d']], ['2026-10-25', '2026-10-26', '2026-10-27']);
    expect(addDays(DateTime(2026, 3, 28), 1), DateTime(2026, 3, 29)); // letní čas (23 hodin)
  });
}
