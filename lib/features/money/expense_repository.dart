import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import 'fx_service.dart';

class ExpenseRepository {
  ExpenseRepository(this.db);
  final AppDatabase db;
  static const _uuid = Uuid();

  Stream<List<Expense>> watchExpenses(String tripId) =>
      (db.select(db.expenses)
            ..where((e) => e.tripId.equals(tripId) & e.deletedAt.isNull())
            ..orderBy([(e) => OrderingTerm.desc(e.spentAt)]))
          .watch();

  Stream<List<Expense>> watchAll() => (db.select(db.expenses)
        ..where((e) => e.deletedAt.isNull())
        ..orderBy([(e) => OrderingTerm.desc(e.spentAt)]))
      .watch();

  Future<void> addExpense({
    required String tripId,
    required double amount,
    required String currency,
    double? fxRate,
    double? amountMain,
    required String category,
    required DateTime spentAt,
    String? country,
    String? note,
    String? receiptPath,
  }) =>
      db.into(db.expenses).insert(ExpensesCompanion.insert(
            id: _uuid.v4(),
            tripId: tripId,
            amount: amount,
            currency: currency,
            spentAt: spentAt,
            fxRate: Value(fxRate),
            amountMain: Value(amountMain),
            category: Value(category),
            country: Value(country),
            note: Value(note),
            receiptPath: Value(receiptPath),
          ));

  Future<void> updateExpense(
    String id, {
    required double amount,
    required String currency,
    double? fxRate,
    double? amountMain,
    required String category,
    required DateTime spentAt,
    String? country,
    String? note,
    String? receiptPath,
  }) =>
      (db.update(db.expenses)..where((e) => e.id.equals(id))).write(
        ExpensesCompanion(
          amount: Value(amount),
          currency: Value(currency),
          fxRate: Value(fxRate),
          amountMain: Value(amountMain),
          category: Value(category),
          spentAt: Value(spentAt),
          country: Value(country),
          note: Value(note),
          receiptPath: Value(receiptPath),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  Future<void> deleteExpense(String id) =>
      (db.update(db.expenses)..where((e) => e.id.equals(id))).write(
        ExpensesCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  Future<void> setBudget(String tripId, double? budget) =>
      (db.update(db.trips)..where((t) => t.id.equals(tripId))).write(
        TripsCompanion(
          budget: Value(budget),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  /// Doplní kurz a přepočet u výdajů, které vznikly offline.
  Future<int> backfillRates(String tripId, String mainCurrency) async {
    final rows = await (db.select(db.expenses)
          ..where((e) =>
              e.tripId.equals(tripId) &
              e.deletedAt.isNull() &
              e.amountMain.isNull()))
        .get();
    final cache = <String, double?>{};
    var filled = 0;
    for (final e in rows) {
      final key = '${e.currency}|${e.spentAt.year}-${e.spentAt.month}-${e.spentAt.day}';
      final rate = cache.containsKey(key)
          ? cache[key]
          : cache[key] = await fetchRate(
              from: e.currency, to: mainCurrency, date: e.spentAt);
      if (rate == null) continue;
      await (db.update(db.expenses)..where((x) => x.id.equals(e.id))).write(
        ExpensesCompanion(
          fxRate: Value(rate),
          amountMain: Value(e.amount * rate),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );
      filled++;
    }
    return filled;
  }
}

final expenseRepositoryProvider =
    Provider((ref) => ExpenseRepository(ref.watch(databaseProvider)));

final expensesProvider = StreamProvider.autoDispose.family<List<Expense>, String>(
    (ref, tripId) => ref.watch(expenseRepositoryProvider).watchExpenses(tripId));

final allExpensesProvider = StreamProvider.autoDispose<List<Expense>>(
    (ref) => ref.watch(expenseRepositoryProvider).watchAll());
