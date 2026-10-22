import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dialogs.dart';
import 'bcbp.dart';
import 'doc_types.dart';
import 'docs_list_screen.dart';
import 'document_repository.dart';

class _Code {
  const _Code(this.barcode, this.kind);
  final bw.Barcode barcode;
  final String kind; // square | pdf417 | linear
}

/// Vybere typ kódu k vykreslení. U neznámého formátu zkusí odhad podle čísel.
_Code? _barcodeFor(String? format, String code) {
  var f = format;
  if (f == null || f == 'unknown') {
    if (RegExp(r'^\d{13}$').hasMatch(code)) {
      f = 'ean13';
    } else if (RegExp(r'^\d{12}$').hasMatch(code)) {
      f = 'upca';
    } else if (RegExp(r'^\d{8}$').hasMatch(code)) {
      f = 'ean8';
    }
  }
  switch (f) {
    case 'qr':
      return _Code(bw.Barcode.qrCode(), 'square');
    case 'pdf417':
      return _Code(bw.Barcode.pdf417(), 'pdf417');
    case 'aztec':
      return _Code(bw.Barcode.aztec(), 'square');
    case 'code128':
      return _Code(bw.Barcode.code128(), 'linear');
    case 'code39':
      return _Code(bw.Barcode.code39(), 'linear');
    case 'code93':
      return _Code(bw.Barcode.code93(), 'linear');
    case 'ean13':
      return _Code(bw.Barcode.ean13(), 'linear');
    case 'ean8':
      return _Code(bw.Barcode.ean8(), 'linear');
    case 'upca':
      return _Code(bw.Barcode.upcA(), 'linear');
    case 'upce':
      return _Code(bw.Barcode.upcE(), 'linear');
    case 'itf':
      return _Code(bw.Barcode.itf(), 'linear');
    case 'codabar':
      return _Code(bw.Barcode.codabar(), 'linear');
    case 'dataMatrix':
      return _Code(bw.Barcode.dataMatrix(), 'square');
    default:
      return null;
  }
}

bool _canRender(_Code? b, String code) {
  if (b == null) return false;
  try {
    return b.barcode.isValid(code);
  } catch (_) {
    return false;
  }
}

/// Vykreslí kód na celou dostupnou šířku.
Widget _codeView(String code, _Code c0) {
  return LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      final square = c0.kind == 'square';
      final h = square ? w : (c0.kind == 'pdf417' ? w * 0.35 : 120.0);
      return bw.BarcodeWidget(
        barcode: c0.barcode,
        data: code,
        width: w,
        height: h,
        drawText: c0.kind == 'linear',
        color: Colors.black,
        backgroundColor: Colors.white,
        errorBuilder: (context, error) => const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Kód se nepodařilo znovu vykreslit, použij originál.',
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    },
  );
}

/// Kód přes celou obrazovku (pro letiště, nádraží).
class _FullCodeScreen extends StatelessWidget {
  const _FullCodeScreen(
      {required this.title, required this.code, required this.barcode});
  final String title;
  final String code;
  final _Code barcode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(child: _codeView(code, barcode)),
          ),
        ),
      ),
    );
  }
}

/// Originální fotka přes celou obrazovku, jde přibližovat.
class _FullImageScreen extends StatelessWidget {
  const _FullImageScreen({required this.title, required this.path});
  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(title)),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 6,
        child: Center(child: Image.file(File(path))),
      ),
    );
  }
}

class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({super.key, required this.docId});
  final String docId;

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool? _showOriginal; // null = automaticky

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final views = ref.watch(docViewsProvider).value ?? const <DocView>[];
    DocView? found;
    for (final x in views) {
      if (x.doc.id == widget.docId) found = x;
    }

    if (found == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final view = found;
    final t = view.ticket;
    final code = (t?.qrData ?? '');
    final hasCode = code.isNotEmpty;
    final barcode = hasCode ? _barcodeFor(t?.barcodeFormat, code) : null;
    final canRender = hasCode && _canRender(barcode, code);
    final bcbp = hasCode ? parseBcbp(code) : null;
    final title = view.doc.title ?? docTypes[view.doc.type] ?? 'Doklad';
    final showOriginal = _showOriginal ?? !canRender;

    String? pick(String? saved, String? fromCode) =>
        (saved != null && saved.isNotEmpty) ? saved : fromCode;

    void openFull() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => showOriginal || !canRender
              ? _FullImageScreen(title: title, path: view.doc.localPath)
              : _FullCodeScreen(title: title, code: code, barcode: barcode!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (choice) async {
              if (choice == 'edit') {
                context.push('/docs/edit', extra: view);
                return;
              }
              if (choice == 'delete' &&
                  await confirm(context, 'Smazat doklad?')) {
                await ref
                    .read(documentRepositoryProvider)
                    .deleteDocument(view.doc.id);
                if (context.mounted) context.go('/docs');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Upravit')),
              PopupMenuItem(value: 'delete', child: Text('Smazat')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (canRender)
            Center(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Kód'),
                    icon: Icon(Icons.qr_code_2),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Originál'),
                    icon: Icon(Icons.image),
                  ),
                ],
                selected: {showOriginal},
                onSelectionChanged: (s) =>
                    setState(() => _showOriginal = s.first),
              ),
            )
          else if (hasCode)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Tento kód nejde znovu vykreslit, proto je zobrazen originál.',
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: openFull,
            child: showOriginal
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 460),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(view.doc.localPath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                              'Obrázek se zatím nepodařilo stáhnout ze zálohy.'),
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _codeView(code, barcode!),
                  ),
          ),
          const SizedBox(height: 6),
          const Center(child: Text('Klepnutím zvětšíš na celou obrazovku')),
          const SizedBox(height: 16),
          _row('Typ', docTypes[view.doc.type]),
          _row('Cesta', view.trip.name),
          _row('Datum', t?.departAt == null ? null : docDateLabel(t!.departAt)),
          _row('Země', view.doc.country),
          _row('Cestující / jméno', pick(t?.passenger, bcbp?.name)),
          _row('Sedadlo / vůz', pick(t?.seat, bcbp?.seat)),
          _row('Gate / nástupiště', t?.gate),
          _row('Odkud', pick(t?.fromPlace, bcbp?.from)),
          _row('Kam', pick(t?.toPlace, bcbp?.to)),
          _row('Dopravce', pick(t?.carrier, bcbp?.carrier)),
          _row('Číslo', pick(t?.number, bcbp?.flight)),
          _row('Rezervace', pick(t?.bookingRef, bcbp?.pnr)),
          if (hasCode)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Data kódu'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SelectableText(code),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
