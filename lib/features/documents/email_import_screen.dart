import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../pro/paywall.dart';
import 'doc_types.dart';
import 'email_parser.dart';
import 'new_document_screen.dart';
import 'scan_service.dart';
import '../../l10n/tr.dart';

/// Rezervace z textu e-mailu (sdílení z Gmailu nebo vložení ze schránky).
/// Jeden nalezený doklad → rovnou formulář, víc (lety tam a zpět) → seznam.
class EmailImportScreen extends ConsumerStatefulWidget {
  const EmailImportScreen({super.key, required this.text});
  final String text;

  @override
  ConsumerState<EmailImportScreen> createState() => _EmailImportScreenState();
}

class _EmailImportScreenState extends ConsumerState<EmailImportScreen> {
  late final List<ScanResult> _items = parseBookingText(widget.text);
  final _saved = <int>{};

  Future<void> _open(int i) async {
    if (!await ensureCanAdd(context, ref.read(databaseProvider), ProLimit.document)) return;
    if (!mounted) return;
    final id = await Navigator.of(context).push<String>(MaterialPageRoute(
      builder: (_) => NewDocumentScreen(scan: _items[i], popOnSave: true),
    ));
    if (id != null && mounted) setState(() => _saved.add(i));
  }

  String _subtitle(Map<String, String> f) {
    final parts = <String>[];
    final d = f['date'] != null ? DateTime.tryParse(f['date']!) : null;
    if (d != null) parts.add(fmtDate(d));
    final t = int.tryParse(f['time'] ?? '');
    if (t != null) parts.add(fmtTime(t));
    final e = f['endDate'] != null ? DateTime.tryParse(f['endDate']!) : null;
    if (e != null) parts.add('→ ${fmtDate(e)}');
    if (f['ref'] != null) parts.add(f['ref']!);
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final all = _saved.length == _items.length;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Rezervace z e-mailu'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_items.length == 1
              ? tr('Nalezený doklad otevři, zkontroluj a ulož.')
              : tr('Nalezené doklady: {n}. Ulož každý zvlášť.', {'n': _items.length})),
          const SizedBox(height: 12),
          for (var i = 0; i < _items.length; i++)
            Card(
              child: ListTile(
                leading: Icon(docIcon(_items[i].fields['type'] ?? 'other')),
                title: Text(_items[i].fields['title'] ??
                    docTypes[_items[i].fields['type'] ?? 'other'] ??
                    tr('Doklad')),
                subtitle: Text(_subtitle(_items[i].fields)),
                trailing: _saved.contains(i)
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.chevron_right),
                onTap: _saved.contains(i) ? null : () => _open(i),
              ),
            ),
          const SizedBox(height: 16),
          if (all)
            FilledButton(
              onPressed: () => context.go('/docs'),
              child: Text(tr('Hotovo')),
            ),
          ExpansionTile(
            title: Text(tr('Text e-mailu')),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(widget.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialog „Vložit text e-mailu“ – předvyplní obsah schránky. Vrátí text nebo null.
Future<String?> askEmailText(BuildContext context) async {
  final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
  if (!context.mounted) return null;
  final c = TextEditingController(text: looksLikeBooking(clip) ? clip : '');
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('Text e-mailu s rezervací')),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('V Gmailu označ text rezervace, zkopíruj ho a vlož sem. Nebo v Gmailu zvol Sdílet → Travel Companion.'),
                style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 8),
            TextField(
              controller: c,
              maxLines: 8,
              minLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: tr('Vlož text…'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Zrušit'))),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, c.text.trim().isEmpty ? null : c.text),
          child: Text(tr('Načíst')),
        ),
      ],
    ),
  );
}
