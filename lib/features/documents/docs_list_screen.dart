import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../pro/paywall.dart';
import 'doc_types.dart';
import 'document_repository.dart';
import 'scan_service.dart';
import '../../l10n/tr.dart';

String docDateLabel(DateTime? d) {
  if (d == null) return 'bez data';
  final hasTime = d.hour != 0 || d.minute != 0;
  return hasTime
      ? '${fmtDate(d)} ${fmtTime(d.hour * 60 + d.minute)}'
      : fmtDate(d);
}

class DocsListScreen extends ConsumerStatefulWidget {
  const DocsListScreen({super.key});

  @override
  ConsumerState<DocsListScreen> createState() => _DocsListScreenState();
}

class _DocsListScreenState extends ConsumerState<DocsListScreen> {
  bool _busy = false;

  Future<void> _add() async {
    if (!await ensureCanAdd(context, ref.read(databaseProvider), ProLimit.document)) return;
    if (!mounted) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(tr('Vyfotit doklad')),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(tr('Vybrat fotku nebo screenshot')),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null || !mounted) return;

    setState(() => _busy = true);
    final result = await scanImage(picked.path);
    if (!mounted) return;
    setState(() => _busy = false);
    context.push('/docs/new', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    final docs = ref.watch(docViewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Moje doklady')),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _add,
        icon: const Icon(Icons.add_a_photo),
        label: Text(tr('Přidat doklad')),
      ),
      body: docs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Chyba: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  tr('Zatím tu nejsou žádné doklady.\n' 'Přidej fotku letenky, jízdenky nebo rezervace.'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final v = list[i];
              final hasCode = (v.ticket?.qrData ?? '').isNotEmpty;
              return Card(
                child: ListTile(
                  leading: Icon(docIcon(v.doc.type)),
                  title: Text(v.doc.title ?? docTypes[v.doc.type] ?? tr('Doklad')),
                  subtitle: Text('${v.trip.name} · ${docDateLabel(v.when)}'),
                  trailing: hasCode ? const Icon(Icons.qr_code_2) : null,
                  onTap: () => context.go('/docs/doc/${v.doc.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
