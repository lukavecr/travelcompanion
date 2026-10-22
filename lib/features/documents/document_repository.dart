import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/format.dart';
import '../../data/database.dart';

class DocView {
  const DocView(this.doc, this.ticket, this.trip);
  final Document doc;
  final Ticket? ticket;
  final Trip trip;

  DateTime? get when => ticket?.departAt;
}

List<DocView> sortDocs(List<DocView> list) {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final upcoming = list
      .where((d) => d.when != null && !d.when!.isBefore(startOfToday))
      .toList()
    ..sort((a, b) => a.when!.compareTo(b.when!));
  final undated = list.where((d) => d.when == null).toList()
    ..sort((a, b) => b.doc.updatedAt.compareTo(a.doc.updatedAt));
  final past = list
      .where((d) => d.when != null && d.when!.isBefore(startOfToday))
      .toList()
    ..sort((a, b) => b.when!.compareTo(a.when!));
  return [...upcoming, ...undated, ...past];
}

class DocumentRepository {
  DocumentRepository(this.db);
  final AppDatabase db;
  static const _uuid = Uuid();

  Stream<List<DocView>> watchAll() {
    final query = db.select(db.documents).join([
      leftOuterJoin(
        db.tickets,
        db.tickets.documentId.equalsExp(db.documents.id) &
            db.tickets.deletedAt.isNull(),
      ),
      innerJoin(db.trips, db.trips.id.equalsExp(db.documents.tripId)),
    ])
      ..where(db.documents.deletedAt.isNull() & db.trips.deletedAt.isNull());

    return query.watch().map((rows) => sortDocs([
          for (final r in rows)
            DocView(
              r.readTable(db.documents),
              r.readTableOrNull(db.tickets),
              r.readTable(db.trips),
            ),
        ]));
  }

  Future<String> saveScanned({
    required String tripId,
    required String type,
    required String title,
    required String localPath,
    required String rawText,
    String? carrier,
    String? number,
    String? bookingRef,
    String? from,
    String? to,
    String? passenger,
    String? seat,
    String? gate,
    String? country,
    DateTime? departAt,
    String? code,
    String? codeFormat,
  }) async {
    final docId = _uuid.v4();
    await db.transaction(() async {
      await db.into(db.documents).insert(DocumentsCompanion.insert(
            id: docId,
            tripId: tripId,
            type: type,
            localPath: localPath,
            title: Value(title),
            country: Value(country),
            rawText: Value(rawText),
            ocrStatus: const Value('done'),
          ));
      await db.into(db.tickets).insert(TicketsCompanion.insert(
            id: _uuid.v4(),
            documentId: docId,
            carrier: Value(carrier),
            number: Value(number),
            bookingRef: Value(bookingRef),
            fromPlace: Value(from),
            toPlace: Value(to),
            departAt: Value(departAt),
            passenger: Value(passenger),
            seat: Value(seat),
            gate: Value(gate),
            qrData: Value(code),
            barcodeFormat: Value(codeFormat),
          ));
    });
    return docId;
  }

  /// Úprava dokladu. Propojené položky plánu se aktualizují společně s ním.
  Future<void> updateScanned(
    String docId, {
    required String tripId,
    required String type,
    required String title,
    String? country,
    String? carrier,
    String? number,
    String? bookingRef,
    String? from,
    String? to,
    String? passenger,
    String? seat,
    String? gate,
    DateTime? departAt,
  }) async {
    final now = DateTime.now();
    await db.transaction(() async {
      await (db.update(db.documents)..where((d) => d.id.equals(docId))).write(
        DocumentsCompanion(
          tripId: Value(tripId),
          type: Value(type),
          title: Value(title),
          country: Value(country),
          updatedAt: Value(now),
          syncState: const Value('pending'),
        ),
      );

      final existing = await (db.select(db.tickets)
            ..where((t) => t.documentId.equals(docId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (existing == null) {
        await db.into(db.tickets).insert(TicketsCompanion.insert(
              id: _uuid.v4(),
              documentId: docId,
              carrier: Value(carrier),
              number: Value(number),
              bookingRef: Value(bookingRef),
              fromPlace: Value(from),
              toPlace: Value(to),
              passenger: Value(passenger),
              seat: Value(seat),
              gate: Value(gate),
              departAt: Value(departAt),
            ));
      } else {
        await (db.update(db.tickets)..where((t) => t.id.equals(existing.id))).write(
          TicketsCompanion(
            carrier: Value(carrier),
            number: Value(number),
            bookingRef: Value(bookingRef),
            fromPlace: Value(from),
            toPlace: Value(to),
            passenger: Value(passenger),
            seat: Value(seat),
            gate: Value(gate),
            departAt: Value(departAt),
            updatedAt: Value(now),
            syncState: const Value('pending'),
          ),
        );
      }

      // položky plánu propojené s dokladem
      await (db.update(db.calendarEvents)..where((e) => e.documentId.equals(docId)))
          .write(CalendarEventsCompanion(
        tripId: Value(tripId),
        title: Value(title),
        date: departAt == null ? const Value.absent() : Value(dayOnly(departAt)),
        startMinutes: (departAt == null || (departAt.hour == 0 && departAt.minute == 0))
            ? const Value.absent()
            : Value(departAt.hour * 60 + departAt.minute),
        updatedAt: Value(now),
        syncState: const Value('pending'),
      ));
    });
  }

  Future<void> deleteDocument(String id) async {
    final now = DateTime.now();
    await db.transaction(() async {
      await (db.update(db.documents)..where((d) => d.id.equals(id))).write(
        DocumentsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value('pending'),
        ),
      );
      await (db.update(db.tickets)..where((t) => t.documentId.equals(id)))
          .write(
        TicketsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value('pending'),
        ),
      );
      // položky plánu zůstanou, jen se odpojí od smazaného dokladu
      await (db.update(db.calendarEvents)
            ..where((e) => e.documentId.equals(id)))
          .write(CalendarEventsCompanion(
        documentId: const Value(null),
        updatedAt: Value(now),
        syncState: const Value('pending'),
      ));
    });
  }
}

final documentRepositoryProvider =
    Provider((ref) => DocumentRepository(ref.watch(databaseProvider)));

final docViewsProvider = StreamProvider.autoDispose<List<DocView>>(
    (ref) => ref.watch(documentRepositoryProvider).watchAll());
