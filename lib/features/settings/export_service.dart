import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DataClass, OrderingTerm;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_settings.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../money/categories.dart';

/// Export dat (Nastavení → Data). Soubor se nabídne přes systémové sdílení
/// (uložit do Souborů / na Disk, poslat e-mailem…). Vault se neexportuje (je šifrovaný).
class ExportService {
  ExportService(this.db);
  final AppDatabase db;

  String _stamp() => DateTime.now().toIso8601String().substring(0, 10);

  Future<File> _write(String name, List<int> bytes) async {
    final dir = Directory(p.join((await getTemporaryDirectory()).path, 'export'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final f = File(p.join(dir.path, name));
    await f.writeAsBytes(bytes);
    return f;
  }

  Future<void> _share(File f, String mime, String subject) => SharePlus.instance.share(
        ShareParams(files: [XFile(f.path, mimeType: mime)], subject: subject),
      );

  /// Výdaje jako CSV pro Excel / Tabulky Google.
  Future<void> exportExpensesCsv() async {
    final trips = {for (final t in await db.select(db.trips).get()) t.id: t};
    final rows = await (db.select(db.expenses)
          ..where((e) => e.deletedAt.isNull())
          ..orderBy([(e) => OrderingTerm.asc(e.spentAt)]))
        .get();
    // čeština/němčina/španělština: oddělovač „;“ a desetinná čárka (tak to čeká Excel)
    final comma = AppSettings.instance.effectiveLanguage != 'en';
    final sep = comma ? ';' : ',';
    String num(double? v) =>
        v == null ? '' : (comma ? v.toStringAsFixed(2).replaceAll('.', ',') : v.toStringAsFixed(2));
    String cell(String? s) {
      final v = (s ?? '').replaceAll('"', '""');
      return v.contains(RegExp('[$sep"\\n]')) ? '"$v"' : v;
    }

    final b = StringBuffer()
      ..writeln(['Datum', 'Cesta', 'Kategorie', 'Poznámka', 'Částka', 'Měna', 'Částka v měně cesty',
              'Měna cesty', 'Kurz', 'Země']
          .join(sep));
    for (final e in rows) {
      final t = trips[e.tripId];
      b.writeln([
        fmtDate(e.spentAt),
        cell(t?.name),
        cell(expenseCategories[e.category] ?? e.category),
        cell(e.note),
        num(e.amount),
        e.currency,
        num(e.amountMain),
        t?.mainCurrency ?? '',
        e.fxRate == null ? '' : (comma ? '${e.fxRate}'.replaceAll('.', ',') : '${e.fxRate}'),
        cell(e.country),
      ].join(sep));
    }
    // BOM, aby Excel poznal UTF-8 (háčky a čárky)
    final f = await _write('vydaje-${_stamp()}.csv', [0xEF, 0xBB, 0xBF, ...utf8.encode(b.toString())]);
    await _share(f, 'text/csv', 'Travel Companion – výdaje');
  }

  /// Všechna data (kromě Vaultu a fotek) jako JSON – pro zálohu u sebe nebo žádost dle GDPR.
  Future<void> exportAllJson() async {
    List<Map<String, dynamic>> live<T extends DataClass>(List<T> rows) => [
          for (final r in rows)
            if ((r.toJson()['deletedAt']) == null) r.toJson(),
        ];
    final data = {
      'app': 'Travel Companion',
      'exportedAt': DateTime.now().toIso8601String(),
      'trips': live(await db.select(db.trips).get()),
      'places': live(await db.select(db.places).get()),
      'calendarEvents': live(await db.select(db.calendarEvents).get()),
      'documents': live(await db.select(db.documents).get()),
      'tickets': live(await db.select(db.tickets).get()),
      'expenses': live(await db.select(db.expenses).get()),
    };
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final f = await _write('travel-companion-${_stamp()}.json', utf8.encode(json));
    await _share(f, 'application/json', 'Travel Companion – export dat');
  }
}
