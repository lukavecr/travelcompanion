import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../pro/paywall.dart';
import 'trip_repository.dart';

class TripFormResult {
  const TripFormResult(this.name, this.range, this.countries);
  final String name;
  final DateTimeRange? range;
  final List<String> countries;
}

/// Dialog pro vytvoření i úpravu cesty (název a termín od–do).
Future<TripFormResult?> askTrip(
  BuildContext context, {
  required String heading,
  String initialName = '',
  DateTimeRange? initialRange,
  String initialCountries = '',
  String confirmLabel = 'Uložit',
}) async {
  final nameController = TextEditingController(text: initialName);
  final countriesController = TextEditingController(text: initialCountries);
  var range = initialRange;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(heading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: initialName.isEmpty,
              decoration: const InputDecoration(
                labelText: 'Název (např. Cesta kolem světa 2027)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countriesController,
              decoration: const InputDecoration(
                labelText: 'Země cesty (oddělené čárkou)',
                hintText: 'Thajsko, Vietnam, Japonsko',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(range == null
                  ? 'Vybrat termín'
                  : '${fmtDate(range!.start)} – ${fmtDate(range!.end)}'),
              onPressed: () async {
                final r = await showDateRangePicker(
                  context: ctx,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2040),
                  initialDateRange: range,
                  helpText: 'Od kdy do kdy',
                );
                if (r != null) setState(() => range = r);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ),
  );

  final name = nameController.text.trim();
  if (ok != true || name.isEmpty) return null;
  return TripFormResult(name, range, parseCountryList(countriesController.text));
}

class TripsListScreen extends ConsumerWidget {
  const TripsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    final repo = ref.read(tripRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje cesty'),
        actions: [
          IconButton(
            tooltip: 'Záloha a účet',
            icon: const Icon(Icons.cloud_outlined),
            onPressed: () => context.push('/sync'),
          ),
          IconButton(
            tooltip: 'Nastavení',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!await ensureCanAdd(context, ref.read(databaseProvider), ProLimit.trip)) return;
          if (!context.mounted) return;
          final r = await askTrip(context,
              heading: 'Nová cesta', confirmLabel: 'Vytvořit');
          if (r != null) {
            await repo.addTrip(
                name: r.name,
                start: r.range?.start,
                end: r.range?.end,
                countries: r.countries);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nová cesta'),
      ),
      body: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Chyba: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Zatím tu nemáš žádnou cestu.\nKlepni na „Nová cesta“.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final t = list[i];
              final dates = (t.startDate != null && t.endDate != null)
                  ? '${fmtDate(t.startDate!)} – ${fmtDate(t.endDate!)}'
                  : 'Bez termínu';
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.flight_takeoff),
                  title: Text(t.name),
                  subtitle: Text(dates),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        final r = await askTrip(
                          context,
                          heading: 'Upravit cestu',
                          initialName: t.name,
                          initialCountries: tripCountries(t).join(', '),
                          initialRange: (t.startDate != null && t.endDate != null)
                              ? DateTimeRange(start: t.startDate!, end: t.endDate!)
                              : null,
                        );
                        if (r != null) {
                          await repo.updateTrip(t.id,
                              name: r.name,
                              start: r.range?.start,
                              end: r.range?.end,
                              countries: r.countries);
                        }
                      } else if (v == 'delete' &&
                          await confirm(context, 'Smazat cestu „${t.name}“?')) {
                        await repo.deleteTrip(t.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Upravit (název, termín)')),
                      PopupMenuItem(value: 'delete', child: Text('Smazat')),
                    ],
                  ),
                  onTap: () => context.go('/trips/trip/${t.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
