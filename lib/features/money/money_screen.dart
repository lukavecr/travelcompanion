import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../trips/trip_repository.dart';
import '../pro/paywall.dart';
import 'categories.dart';
import 'expense_form_screen.dart';
import 'expense_repository.dart';
import '../../l10n/tr.dart';

const _none = '__none'; // výdaje bez země

class _Bar {
  const _Bar(this.label, this.value, this.color, {this.icon, this.onTap});
  final String label;
  final double value;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;
}

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> {
  String? _tripId; // null = všechny cesty
  bool _init = false;
  int _tab = 1; // 0 výdaje, 1 přehled
  bool _filling = false;
  bool _filledOnce = false;

  Future<void> _fillAll(List<Trip> trips) async {
    setState(() => _filling = true);
    final repo = ref.read(expenseRepositoryProvider);
    for (final t in trips) {
      await repo.backfillRates(t.id, t.mainCurrency);
    }
    if (mounted) setState(() => _filling = false);
  }

  Future<void> _editBudget(Trip trip) async {
    final text = await askText(
      context,
      title: tr('Rozpočet cesty ({mainCurrency})', {'mainCurrency': trip.mainCurrency}),
      initial: trip.budget == null ? '' : trip.budget!.round().toString(),
      label: tr('Částka (0 = bez rozpočtu)'),
    );
    if (text == null) return;
    final v = parseAmount(text);
    if (v == null) return;
    await ref.read(expenseRepositoryProvider).setBudget(trip.id, v > 0 ? v : null);
  }

  Future<void> _addExpense(List<Trip> trips, Trip? trip) async {
    if (!await ensureCanAdd(context, ref.read(databaseProvider), ProLimit.expense)) return;
    if (!mounted) return;
    var tripId = trip?.id;
    if (tripId == null) {
      final picked = await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(title: Text(tr('Do které cesty výdaj patří?'))),
              for (final t in trips)
                ListTile(
                  leading: const Icon(Icons.flight_takeoff),
                  title: Text(t.name),
                  onTap: () => Navigator.pop(ctx, t.id),
                ),
            ],
          ),
        ),
      );
      if (picked == null || !mounted) return;
      tripId = picked;
    }
    context.go(
      '/money/form',
      extra: ExpenseFormArgs(tripId, null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider).value ?? const <Trip>[];
    final allRaw = ref.watch(allExpensesProvider).value ?? const <Expense>[];

    if (trips.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('Peníze'))),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(tr('Nejdřív vytvoř cestu v záložce Cesty.'),
                textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (!_init) {
      _init = true;
      _tripId = trips.length > 1 ? null : trips.first.id;
    }
    Trip? trip;
    for (final t in trips) {
      if (t.id == _tripId) trip = t;
    }
    if (trip == null) _tripId = null;

    if (!_filledOnce) {
      _filledOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fillAll(trips);
      });
    }

    final ids = {for (final t in trips) t.id};
    final all = allRaw.where((e) => ids.contains(e.tripId)).toList();
    final cur = trips.first.mainCurrency;

    final tripTotals = <String, double>{for (final t in trips) t.id: 0};
    for (final e in all) {
      tripTotals[e.tripId] = (tripTotals[e.tripId] ?? 0) + (e.amountMain ?? 0);
    }
    final allTotal = tripTotals.values.fold<double>(0, (a, b) => a + b);

    // výdaje vybrané cesty (nebo všech)
    final expenses = trip == null ? all : all.where((e) => e.tripId == trip!.id).toList();

    var total = 0.0;
    var missing = 0;
    for (final e in expenses) {
      if (e.amountMain == null) {
        missing++;
      } else {
        total += e.amountMain!;
      }
    }

    final today = dayOnly(DateTime.now());
    int days;
    if (trip != null &&
        trip.startDate != null &&
        !today.isBefore(dayOnly(trip.startDate!))) {
      final end = trip.endDate != null && dayOnly(trip.endDate!).isBefore(today)
          ? dayOnly(trip.endDate!)
          : today;
      days = math.max(1, end.difference(dayOnly(trip.startDate!)).inDays + 1);
    } else {
      days = math.max(1, expenses.map((e) => dayOnly(e.spentAt)).toSet().length);
    }

    final currentTrip = trip;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Peníze')),
        bottom: _filling
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExpense(trips, currentTrip),
        icon: const Icon(Icons.add),
        label: Text(tr('Přidat výdaj')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
        children: [
          // jediný řádek: Vše + cesty ze záložky Cesty
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (trips.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: const Icon(Icons.dashboard, size: 18),
                      label: Text(tr('Vše · {allTotal}', {'allTotal': fmtMoney(allTotal)})),
                      selected: trip == null,
                      onSelected: (_) => setState(() => _tripId = null),
                    ),
                  ),
                for (final t in trips)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text((tripTotals[t.id] ?? 0) > 0
                          ? '${t.name} · ${fmtMoney(tripTotals[t.id]!)}'
                          : t.name),
                      selected: trip?.id == t.id,
                      onSelected: (_) => setState(() => _tripId = t.id),
                    ),
                  ),
              ],
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      trip == null
                          ? tr('Celkem za všechny cesty')
                          : 'Celkem: ${trip.name}',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('${fmtMoney(total)} $cur',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(tr('≈ {days} {cur} na den ({days2} dní)', {'days': fmtMoney(total / days), 'cur': cur, 'days2': days})),
                  if (trip != null) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _editBudget(currentTrip!),
                      child: trip.budget == null
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(tr('Nastavit rozpočet')),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (total / trip.budget!).clamp(0.0, 1.0),
                                    minHeight: 8,
                                    color: total > trip.budget!
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(total > trip.budget!
                                    ? tr('Rozpočet {budget} {cur} překročen o {budget2} {cur}', {'budget': fmtMoney(trip.budget!), 'cur': cur, 'budget2': fmtMoney(total - trip.budget!)})
                                    : tr('Zbývá {total} z {budget} {cur}', {'total': fmtMoney(trip.budget! - total), 'budget': fmtMoney(trip.budget!), 'cur': cur})),
                              ],
                            ),
                    ),
                  ],
                  if (missing > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(tr('{missing} výdajů zatím bez přepočtu na {cur}', {'missing': missing, 'cur': cur})),
                        ),
                        TextButton(
                          onPressed: _filling ? null : () => _fillAll(trips),
                          child: Text(tr('Doplnit kurzy')),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                    value: 1, label: Text(tr('Přehled')), icon: Icon(Icons.bar_chart)),
                ButtonSegment(value: 0, label: Text(tr('Výdaje')), icon: Icon(Icons.list)),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          const SizedBox(height: 8),
          if (_tab == 0)
            ..._expenseList(context, trips, trip, cur, expenses)
          else
            ..._stats(context, trips, trip, cur, expenses, tripTotals),
        ],
      ),
    );
  }

  List<Widget> _expenseList(BuildContext context, List<Trip> trips, Trip? trip,
      String cur, List<Expense> list) {
    if (list.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.all(24),
          child: Text(tr('Zatím žádné výdaje.'), textAlign: TextAlign.center),
        ),
      ];
    }
    String tripName(String id) {
      for (final t in trips) {
        if (t.id == id) return t.name;
      }
      return '';
    }

    final byDay = <DateTime, List<Expense>>{};
    for (final e in list) {
      byDay.putIfAbsent(dayOnly(e.spentAt), () => []).add(e);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return [
      for (final d in days) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(fmtDay(d), style: Theme.of(context).textTheme.titleSmall),
              ),
              Text(
                '${fmtMoney(byDay[d]!.fold<double>(0, (s, e) => s + (e.amountMain ?? 0)))} $cur',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        for (final e in byDay[d]!)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: categoryColor(e.category).withValues(alpha: 0.25),
                child: Icon(categoryIcon(e.category),
                    color: categoryColor(e.category), size: 20),
              ),
              title: Text(e.note?.isNotEmpty == true
                  ? e.note!
                  : (expenseCategories[e.category] ?? tr('Výdaj'))),
              subtitle: Text([
                if (trip == null) tripName(e.tripId),
                if (e.country != null && e.country!.isNotEmpty) e.country!,
                if (e.currency != cur)
                  '${fmtMoney(e.amount, e.amount % 1 == 0 ? 0 : 2)} ${e.currency}',
                if (e.receiptPath != null && e.receiptPath!.isNotEmpty) '🧾',
              ].join(' · ')),
              trailing: Text(
                e.amountMain == null
                    ? '—'
                    : '${fmtMoney(e.amountMain!, e.amountMain! < 100 ? 2 : 0)} $cur',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              onTap: () =>
                  context.go('/money/form', extra: ExpenseFormArgs(e.tripId, e)),
            ),
          ),
      ],
    ];
  }

  List<Widget> _stats(
    BuildContext context,
    List<Trip> trips,
    Trip? trip,
    String cur,
    List<Expense> list,
    Map<String, double> tripTotals,
  ) {
    final conv = list.where((e) => e.amountMain != null).toList();
    if (conv.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.all(24),
          child: Text(tr('Přehled se zobrazí po přidání výdajů.'),
              textAlign: TextAlign.center),
        ),
      ];
    }

    final cat = <String, double>{};
    final country = <String, double>{};
    final day = <DateTime, double>{};
    for (final e in conv) {
      cat[e.category] = (cat[e.category] ?? 0) + e.amountMain!;
      final c = (e.country == null || e.country!.trim().isEmpty)
          ? _none
          : e.country!.trim();
      country[c] = (country[c] ?? 0) + e.amountMain!;
      final d = dayOnly(e.spentAt);
      day[d] = (day[d] ?? 0) + e.amountMain!;
    }

    const palette = [
      Color(0xFF2DD4A7),
      Color(0xFF4FA3F7),
      Color(0xFFF5A623),
      Color(0xFF9B7BEA),
      Color(0xFFE86A92),
    ];

    final catBars = (cat.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) => _Bar(expenseCategories[e.key] ?? e.key, e.value,
            categoryColor(e.key),
            icon: categoryIcon(e.key)))
        .toList();

    var i = 0;
    final tripBars = [
      for (final t in trips)
        if ((tripTotals[t.id] ?? 0) > 0)
          _Bar(
            t.name,
            tripTotals[t.id]!,
            palette[i++ % palette.length],
            icon: Icons.flight_takeoff,
            onTap: () => setState(() => _tripId = t.id),
          ),
    ]..sort((a, b) => b.value.compareTo(a.value));

    var j = 0;
    final countryBars = (country.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) {
      final key = e.key;
      return _Bar(
        key == _none ? tr('Bez země') : key,
        e.value,
        palette[j++ % palette.length],
        icon: Icons.public,
      );
    }).toList();

    final dayKeys = day.keys.toList()..sort((a, b) => b.compareTo(a));
    final dayBars = [
      for (final d in dayKeys.take(14)) _Bar(fmtDay(d), day[d]!, palette[1]),
    ];

    Widget section(String title, List<_Bar> bars) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _barList(bars, cur),
              ],
            ),
          ),
        );

    return [
      if (trip == null && tripBars.length > 1)
        section(tr('Podle cest (klepnutím otevřeš cestu)'), tripBars),
      if (trip != null && countryBars.length > 1) section(tr('Podle zemí'), countryBars),
      section(tr('Podle kategorií'), catBars),
      section(tr('Podle dnů (posledních 14)'), dayBars),
    ];
  }

  Widget _barList(List<_Bar> bars, String unit) {
    final maxV = bars.map((b) => b.value).reduce(math.max);
    final sum = bars.fold<double>(0, (s, b) => s + b.value);
    return Column(
      children: [
        for (final b in bars)
          InkWell(
            onTap: b.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (b.icon != null) ...[
                        Icon(b.icon, size: 18, color: b.color),
                        const SizedBox(width: 6),
                      ],
                      Expanded(child: Text(b.label)),
                      Text('${fmtMoney(b.value)} $unit · ${(b.value / sum * 100).round()} %'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxV == 0 ? 0 : b.value / maxV,
                      minHeight: 8,
                      color: b.color,
                      backgroundColor: b.color.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
