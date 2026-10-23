import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/core/app_settings.dart';
import 'package:travelcompanion/demo/demo_mode.dart';

void main() {
  test('prezentační data: cesty, doklady, výdaje, Vault, trasa', () async {
    AppSettings.instance.language = 'cs';
    final db = await openDemoDatabase();
    expect((await db.select(db.trips).get()).map((t) => t.name), contains('Japonsko'));
    expect((await db.select(db.documents).get()).length, 2);
    expect((await db.select(db.expenses).get()).length, greaterThan(15));
    expect((await db.select(db.vaultItems).get()).length, 6);
    expect((await db.select(db.tracks).get()).single.distanceM, greaterThan(300));
    final japan = (await db.select(db.trips).get()).firstWhere((t) => t.name == 'Japonsko');
    expect(japan.notes, isNull);
    expect((await db.select(db.expenses).get()).every((e) => e.amountMain != null), isTrue); // počítá se jako normální cesta
    final ev = await db.select(db.calendarEvents).get();
    expect(ev.any((e) => e.date.isAfter(japan.startDate!.subtract(const Duration(seconds: 1)))), isTrue);
    await db.close();
  });
}
