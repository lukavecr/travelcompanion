import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/format.dart';
import '../../data/database.dart';

class TripRepository {
  TripRepository(this.db);
  final AppDatabase db;
  static const _uuid = Uuid();

  // ---- Cesty ----
  Stream<List<Trip>> watchTrips() => (db.select(db.trips)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
      .watch();

  Stream<Trip?> watchTrip(String id) =>
      (db.select(db.trips)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<void> addTrip({
    required String name,
    DateTime? start,
    DateTime? end,
    List<String> countries = const [],
  }) =>
      db.into(db.trips).insert(TripsCompanion.insert(
            id: _uuid.v4(),
            name: name,
            startDate: Value(start),
            endDate: Value(end),
            countries: Value(jsonEncode(countries)),
          ));

  Future<void> setCountries(String tripId, List<String> countries) =>
      (db.update(db.trips)..where((t) => t.id.equals(tripId))).write(
        TripsCompanion(
          countries: Value(jsonEncode(countries)),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  Future<void> deleteTrip(String id) async {
    final now = DateTime.now();
    await (db.update(db.trips)..where((t) => t.id.equals(id))).write(
      TripsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
    // smaž i položky plánu (a tím jejich upozornění)
    await (db.update(db.calendarEvents)..where((e) => e.tripId.equals(id)))
        .write(
      CalendarEventsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<void> updateTrip(String id,
          {required String name,
          DateTime? start,
          DateTime? end,
          List<String>? countries}) =>
      (db.update(db.trips)..where((t) => t.id.equals(id))).write(
        TripsCompanion(
          name: Value(name),
          startDate: Value(start),
          endDate: Value(end),
          countries: countries == null
              ? const Value.absent()
              : Value(jsonEncode(countries)),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  // ---- Plán dne ----
  Stream<List<CalendarEvent>> watchEvents(String tripId) =>
      (db.select(db.calendarEvents)
            ..where((e) => e.tripId.equals(tripId) & e.deletedAt.isNull())
            ..orderBy([
              (e) => OrderingTerm.asc(e.date),
              (e) => OrderingTerm.asc(e.sortOrder),
            ]))
          .watch();

  int _nowOrder() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> addEvent({
    required String tripId,
    required DateTime date,
    required String title,
    String? placeId,
    String? documentId,
    DateTime? endDate,
    int? startMinutes,
    int? remindMinutes,
  }) =>
      db.into(db.calendarEvents).insert(CalendarEventsCompanion.insert(
            id: _uuid.v4(),
            tripId: tripId,
            date: dayOnly(date),
            title: title,
            placeId: Value(placeId),
            documentId: Value(documentId),
            endDate: Value(endDate == null ? null : dayOnly(endDate)),
            startMinutes: Value(startMinutes),
            remindMinutes: Value(remindMinutes),
            sortOrder: Value(_nowOrder()),
          ));

  /// Změní název a čas (čas null = bez času).
  Future<void> updateEventDetails(String id,
          {required String title, int? startMinutes, int? remindMinutes}) =>
      (db.update(db.calendarEvents)..where((e) => e.id.equals(id))).write(
        CalendarEventsCompanion(
          title: Value(title),
          startMinutes: Value(startMinutes),
          remindMinutes: Value(remindMinutes),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  /// Změní termín ubytování.
  Future<void> updateStay(String id, DateTime start, DateTime end) =>
      (db.update(db.calendarEvents)..where((e) => e.id.equals(id))).write(
        CalendarEventsCompanion(
          date: Value(dayOnly(start)),
          endDate: Value(dayOnly(end)),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  Future<void> updateEvent(String id, {String? title, DateTime? date}) =>
      (db.update(db.calendarEvents)..where((e) => e.id.equals(id))).write(
        CalendarEventsCompanion(
          title: title == null ? const Value.absent() : Value(title),
          date: date == null ? const Value.absent() : Value(dayOnly(date)),
          sortOrder: date == null ? const Value.absent() : Value(_nowOrder()),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  Future<void> deleteEvent(String id) =>
      (db.update(db.calendarEvents)..where((e) => e.id.equals(id))).write(
        CalendarEventsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  // ---- Místa ----
  Stream<List<Place>> watchPlaces(String tripId) => (db.select(db.places)
        ..where((p) => p.tripId.equals(tripId) & p.deletedAt.isNull())
        ..orderBy([(p) => OrderingTerm.asc(p.name)]))
      .watch();

  /// Souřadnice 0,0 znamenají „neznámé“ (mapa přijde později).
  Future<String> addPlace({
    required String tripId,
    required String name,
    String type = 'custom',
    double? lat,
    double? lng,
    String? mapUrl,
    String? country,
  }) async {
    final id = _uuid.v4();
    await db.into(db.places).insert(PlacesCompanion.insert(
          id: id,
          tripId: tripId,
          name: name,
          lat: lat ?? 0,
          lng: lng ?? 0,
          type: Value(type),
          mapUrl: Value(mapUrl),
          country: Value(country),
        ));
    return id;
  }

  Future<void> deletePlace(String id) =>
      (db.update(db.places)..where((p) => p.id.equals(id))).write(
        PlacesCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ),
      );

  /// Položky, u kterých je nastavený čas i upozornění (všechny cesty).
  Stream<List<CalendarEvent>> watchReminderEvents() =>
      (db.select(db.calendarEvents)
            ..where((e) =>
                e.deletedAt.isNull() &
                e.startMinutes.isNotNull() &
                e.remindMinutes.isNotNull()))
          .watch();

  /// Uloží nové pořadí položek v rámci jednoho dne.
  Future<void> reorder(List<String> orderedIds) async {
    await db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          db.calendarEvents,
          CalendarEventsCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
            syncState: const Value('pending'),
          ),
          where: (e) => e.id.equals(orderedIds[i]),
        );
      }
    });
  }
}

final tripRepositoryProvider =
    Provider((ref) => TripRepository(ref.watch(databaseProvider)));

/// Nadcházející cesty nahoře (nejbližší první), proběhlé dole (nejnovější první).
List<Trip> sortTrips(List<Trip> trips) {
  final today = dayOnly(DateTime.now());
  bool isPast(Trip t) {
    final last = t.endDate ?? t.startDate;
    return last != null && dayOnly(last).isBefore(today);
  }

  final upcoming = trips.where((t) => !isPast(t)).toList()
    ..sort((a, b) {
      if (a.startDate == null && b.startDate == null) return 0;
      if (a.startDate == null) return 1;
      if (b.startDate == null) return -1;
      return a.startDate!.compareTo(b.startDate!);
    });
  final past = trips.where(isPast).toList()
    ..sort((a, b) => (b.startDate ?? b.endDate!).compareTo(a.startDate ?? a.endDate!));
  return [...upcoming, ...past];
}

final tripsProvider = StreamProvider.autoDispose<List<Trip>>(
    (ref) => ref.watch(tripRepositoryProvider).watchTrips().map(sortTrips));

final tripProvider = StreamProvider.autoDispose.family<Trip?, String>(
    (ref, id) => ref.watch(tripRepositoryProvider).watchTrip(id));

final eventsProvider =
    StreamProvider.autoDispose.family<List<CalendarEvent>, String>(
        (ref, tripId) => ref.watch(tripRepositoryProvider).watchEvents(tripId));

final placesProvider = StreamProvider.autoDispose.family<List<Place>, String>(
    (ref, tripId) => ref.watch(tripRepositoryProvider).watchPlaces(tripId));

final reminderEventsProvider = StreamProvider<List<CalendarEvent>>(
    (ref) => ref.watch(tripRepositoryProvider).watchReminderEvents());

/// Země naplánované u cesty (v pořadí, jak je uživatel zadal).
List<String> tripCountries(Trip? t) {
  if (t == null) return const [];
  try {
    final v = jsonDecode(t.countries);
    if (v is List) {
      return [
        for (final x in v)
          if (x is String && x.trim().isNotEmpty) x.trim(),
      ];
    }
  } catch (_) {}
  return const [];
}

/// "Thajsko, Vietnam ; Japonsko" -> [Thajsko, Vietnam, Japonsko] bez duplicit.
List<String> parseCountryList(String text) {
  final out = <String>[];
  for (final part in text.split(RegExp(r'[,;\n]'))) {
    final c = part.trim();
    if (c.isEmpty) continue;
    if (out.any((x) => x.toLowerCase() == c.toLowerCase())) continue;
    out.add(c);
  }
  return out;
}
