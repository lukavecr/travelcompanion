import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/data/database.dart';
import 'package:travelcompanion/features/money/expense_repository.dart';
import 'package:travelcompanion/features/pro/paywall.dart';
import 'package:travelcompanion/features/trips/trip_repository.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('aktivní cesty: proběhlé se nepočítají, smazané taky ne', () async {
    final trips = TripRepository(db);
    final now = DateTime.now();
    await trips.addTrip(name: 'Loni', start: DateTime(2024, 1, 1), end: DateTime(2024, 2, 1));
    expect((await usageOf(db, ProLimit.trip)).$1, 0);
    await trips.addTrip(name: 'Teď', start: now, end: now.add(const Duration(days: 30)));
    await trips.addTrip(name: 'Bez data');
    expect(await usageOf(db, ProLimit.trip), (2, 1));
  });

  test('výdaje: limit 30, smazané se nepočítají', () async {
    final trips = TripRepository(db);
    await trips.addTrip(name: 'Cesta');
    final tripId = (await db.select(db.trips).getSingle()).id;
    final exp = ExpenseRepository(db);
    for (var i = 0; i < 30; i++) {
      await exp.addExpense(
          tripId: tripId, amount: 10, currency: 'CZK', category: 'food', spentAt: DateTime.now());
    }
    expect(await usageOf(db, ProLimit.expense), (30, 30));
    final first = (await db.select(db.expenses).get()).first;
    await (db.update(db.expenses)..where((e) => e.id.equals(first.id)))
        .write(ExpensesCompanion(deletedAt: Value(DateTime.now())));
    expect((await usageOf(db, ProLimit.expense)).$1, 29);
  });
}
