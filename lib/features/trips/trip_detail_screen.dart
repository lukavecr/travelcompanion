import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../places/place_types.dart';
import '../reminders/reminder_service.dart';
import 'trip_repository.dart';
import 'trips_list_screen.dart' show askTrip;

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId));
    final events = ref.watch(eventsProvider(tripId));

    return trip.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Chyba: $e'))),
      data: (t) {
        if (t == null) {
          return const Scaffold(body: Center(child: Text('Cesta nenalezena')));
        }
        final evs = events.value ?? const <CalendarEvent>[];

        // dny = rozsah cesty + dny, ve kterých už něco je (i ubytování)
        final days = <DateTime>{};
        void addRange(DateTime a, DateTime b) {
          var d = dayOnly(a);
          final end = dayOnly(b);
          var n = 0;
          while (!d.isAfter(end) && n < 400) {
            days.add(d);
            d = DateTime(d.year, d.month, d.day + 1);
            n++;
          }
        }

        if (t.startDate != null && t.endDate != null) {
          addRange(t.startDate!, t.endDate!);
        }
        for (final e in evs) {
          addRange(e.date, e.endDate ?? e.date);
        }
        final sorted = days.toList()..sort();

        return Scaffold(
          appBar: AppBar(
            title: Text(t.name),
            actions: [
              IconButton(
                tooltip: 'Uložená místa',
                icon: const Icon(Icons.place_outlined),
                onPressed: () => context.go('/trips/trip/$tripId/places'),
              ),
              PopupMenuButton<String>(
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
                      await ref.read(tripRepositoryProvider).updateTrip(t.id,
                          name: r.name,
                          start: r.range?.start,
                          end: r.range?.end,
                          countries: r.countries);
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'edit', child: Text('Upravit cestu (název, termín)')),
                ],
              ),
            ],
          ),
          body: sorted.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Cesta nemá termín, takže nejsou žádné dny.\n'
                      'Smaž ji a vytvoř znovu s termínem.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
                  itemCount: sorted.length,
                  itemBuilder: (context, i) {
                    final day = sorted[i];
                    final stays = evs
                        .where((e) =>
                            e.endDate != null &&
                            !day.isBefore(dayOnly(e.date)) &&
                            !day.isAfter(dayOnly(e.endDate!)))
                        .toList();
                    final dayEvents = evs
                        .where((e) => e.endDate == null && dayOnly(e.date) == day)
                        .toList();
                    return _DayCard(
                      tripId: tripId,
                      day: day,
                      dayNumber: t.startDate == null
                          ? null
                          : day.difference(dayOnly(t.startDate!)).inDays + 1,
                      stays: stays,
                      events: dayEvents,
                    );
                  },
                ),
        );
      },
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({
    required this.tripId,
    required this.day,
    required this.dayNumber,
    required this.stays,
    required this.events,
  });

  final String tripId;
  final DateTime day;
  final int? dayNumber;
  final List<CalendarEvent> stays;
  final List<CalendarEvent> events;

  String get _label => dayNumber != null && dayNumber! > 0
      ? 'Den $dayNumber · ${fmtDay(day)}'
      : fmtDay(day);

  Future<void> _addStay(BuildContext context, TripRepository repo,
      String name, String? placeId) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      initialDateRange: DateTimeRange(
        start: day,
        end: DateTime(day.year, day.month, day.day + 1),
      ),
      helpText: 'Od kdy do kdy',
    );
    if (range == null) return;
    await repo.addEvent(
      tripId: tripId,
      date: range.start,
      endDate: range.end,
      title: name,
      placeId: placeId,
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(tripRepositoryProvider);
    final places = ref.read(placesProvider(tripId)).value ?? const <Place>[];
    final choice = await showModalBottomSheet<Object>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Vlastní položka'),
              onTap: () => Navigator.pop(ctx, 'custom'),
            ),
            ListTile(
              leading: const Icon(Icons.hotel),
              title: const Text('Ubytování (od–do)'),
              onTap: () => Navigator.pop(ctx, 'stay'),
            ),
            if (places.isNotEmpty) const Divider(),
            for (final p in places)
              ListTile(
                leading: Icon(placeIcon(p.type)),
                title: Text(p.name),
                onTap: () => Navigator.pop(ctx, p),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (choice == 'custom') {
      final r = await askEvent(context, heading: 'Nová položka · $_label');
      if (r != null) {
        await repo.addEvent(
          tripId: tripId,
          date: day,
          title: r.title,
          startMinutes: r.minutes,
          remindMinutes: r.remindMinutes,
        );
        if (r.remindMinutes != null) await ReminderService.ensurePermissions();
      }
    } else if (choice == 'stay') {
      final name = await askText(context, title: 'Název ubytování');
      if (name == null || !context.mounted) return;
      await _addStay(context, repo, name, null);
    } else if (choice is Place) {
      if (choice.type == 'hotel') {
        await _addStay(context, repo, choice.name, choice.id);
      } else {
        final r = await askEvent(context,
            heading: 'Přidat do dne', title: choice.name);
        if (r != null) {
          await repo.addEvent(
            tripId: tripId,
            date: day,
            title: r.title,
            placeId: choice.id,
            startMinutes: r.minutes,
            remindMinutes: r.remindMinutes,
          );
          if (r.remindMinutes != null) await ReminderService.ensurePermissions();
        }
      }
    }
  }

  Widget _eventMenu(BuildContext context, WidgetRef ref, CalendarEvent e) {
    final repo = ref.read(tripRepositoryProvider);
    return PopupMenuButton<String>(
      onSelected: (v) async {
        if (v == 'edit') {
          final r = await askEvent(context,
              heading: 'Upravit',
              title: e.title,
              minutes: e.startMinutes,
              remind: e.remindMinutes);
          if (r != null) {
            await repo.updateEventDetails(e.id,
                title: r.title,
                startMinutes: r.minutes,
                remindMinutes: r.remindMinutes);
            if (r.remindMinutes != null) await ReminderService.ensurePermissions();
          }
        } else if (v == 'move') {
          final d = await showDatePicker(
            context: context,
            initialDate: e.date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2040),
          );
          if (d != null) await repo.updateEvent(e.id, date: d);
        } else if (v == 'delete') {
          await repo.deleteEvent(e.id);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Upravit (název, čas)')),
        PopupMenuItem(value: 'move', child: Text('Přesunout na jiný den')),
        PopupMenuItem(value: 'delete', child: Text('Smazat')),
      ],
    );
  }

  Widget _stayTile(BuildContext context, WidgetRef ref, CalendarEvent e) {
    final repo = ref.read(tripRepositoryProvider);
    final start = dayOnly(e.date);
    final end = dayOnly(e.endDate!);
    final what = day == start
        ? 'Check-in'
        : day == end
            ? 'Check-out'
            : 'Ubytování';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.hotel),
        title: Text(e.title),
        subtitle: Text('$what · ${fmtDate(start)} – ${fmtDate(end)}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'range') {
              final r = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2040),
                initialDateRange: DateTimeRange(start: start, end: end),
                helpText: 'Od kdy do kdy',
              );
              if (r != null) await repo.updateStay(e.id, r.start, r.end);
            } else if (v == 'delete') {
              await repo.deleteEvent(e.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'range', child: Text('Změnit termín')),
            PopupMenuItem(value: 'delete', child: Text('Smazat')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(tripRepositoryProvider);

    final timed = events.where((e) => e.startMinutes != null).toList()
      ..sort((a, b) {
        final c = a.startMinutes!.compareTo(b.startMinutes!);
        return c != 0 ? c : a.sortOrder.compareTo(b.sortOrder);
      });
    final untimed = events.where((e) => e.startMinutes == null).toList();
    final empty = stays.isEmpty && events.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_label,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                    tooltip: 'Přidat do dne',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _add(context, ref),
                  ),
                ],
              ),
            ),
            for (final s in stays) _stayTile(context, ref, s),
            if (empty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('Zatím nic naplánováno'),
              ),
            for (final e in timed)
              ListTile(
                key: ValueKey(e.id),
                leading: Text(
                  fmtTime(e.startMinutes!),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                title: Text(e.title),
                onTap: e.documentId == null
                    ? null
                    : () => context.go('/docs/doc/${e.documentId}'),
                subtitle: (e.placeId != null ||
                        e.documentId != null ||
                        e.remindMinutes != null)
                    ? Text([
                        if (e.documentId != null) 'doklad',
                        if (e.placeId != null) 'uložené místo',
                        if (e.remindMinutes != null)
                          '🔔 ${fmtLead(e.remindMinutes!)} předem',
                      ].join(' · '))
                    : null,
                trailing: _eventMenu(context, ref, e),
              ),
            if (untimed.isNotEmpty)
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final ids = untimed.map((e) => e.id).toList();
                  final moved = ids.removeAt(oldIndex);
                  ids.insert(newIndex, moved);
                  repo.reorder(ids);
                },
                children: [
                  for (final e in untimed)
                    ListTile(
                      key: ValueKey(e.id),
                      leading: e.documentId != null
                          ? const Icon(Icons.confirmation_number)
                          : (e.placeId != null ? const Icon(Icons.place) : null),
                      title: Text(e.title),
                      onTap: e.documentId == null
                          ? null
                          : () => context.go('/docs/doc/${e.documentId}'),
                      trailing: _eventMenu(context, ref, e),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
