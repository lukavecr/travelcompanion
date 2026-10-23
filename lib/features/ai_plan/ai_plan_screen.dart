import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../places/place_types.dart';
import '../pro/paywall.dart';
import 'ai_trip.dart';
import '../../l10n/tr.dart';

/// „Naplánovat s AI“: návod, jak si u AI nechat vytvořit soubor s plánem, a jeho import.
class AiPlanScreen extends ConsumerStatefulWidget {
  const AiPlanScreen({super.key, this.answer, this.fileName});
  final String? answer; // obsah souboru / text sdílený z aplikace AI
  final String? fileName;

  @override
  ConsumerState<AiPlanScreen> createState() => _AiPlanScreenState();
}

class _AiPlanScreenState extends ConsumerState<AiPlanScreen> {
  final _answer = TextEditingController();
  bool _showPaste = false;
  String? _fileName;
  AiTrip? _trip;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.answer != null) {
      _answer.text = widget.answer!;
      _fileName = widget.fileName;
      WidgetsBinding.instance.addPostFrameCallback((_) => _read());
    }
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _snack(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  String get _fillMessage => tr('Vyplň přiložený soubor detailním itinerářem den po dni s konkrétními místy, která mám navštívit: '
      'jedu do Vietnamu 5. 12. 2026 – 15. 1. 2027. Zachovej sloupce a vrať mi vyplněný soubor CSV ke stažení.');

  /// Vzorový soubor (hlavička + ukázkové řádky) – AI ho jen vyplní, takže ho aplikace určitě přečte.
  Future<void> _shareTemplate() async {
    final save = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.send),
            title: Text(tr('Poslat do aplikace AI (ChatGPT, Claude…)')),
            onTap: () => Navigator.pop(ctx, false),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: Text(tr('Uložit do telefonu')),
            onTap: () => Navigator.pop(ctx, true),
          ),
        ]),
      ),
    );
    if (save == null) return;
    if (save) {
      final uri = await FilePicker.saveFile(
        fileName: 'travel-companion-plan.csv',
        bytes: Uint8List.fromList(utf8.encode(aiCsvExample)),
        mimeType: 'text/csv',
      );
      if (uri != null && mounted) _snack(tr('Vzor je uložený. V AI ho přilož přes 📎.'));
      return;
    }
    final dir = await getTemporaryDirectory();
    final f = File(p.join(dir.path, 'travel-companion-plan.csv'));
    await f.writeAsString(aiCsvExample);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(f.path, mimeType: 'text/csv')],
      text: _fillMessage,
      subject: tr('Vzor plánu cesty'),
    ));
  }

  Future<void> _copyInstruction() async {
    await Clipboard.setData(ClipboardData(text: buildAiCsvInstruction()));
    if (mounted) _snack(tr('Pokyn je zkopírovaný. V AI ho vlož za svou zprávu (podrž prst → Vložit).'));
  }

  Future<void> _pickFile() async {
    final f = await FilePicker.pickFile();
    if (f == null) return;
    _fileName = f.name;
    try {
      final bytes = await f.readAsBytes();
      _answer.text = utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      _snack(tr('Soubor se nepodařilo otevřít: {e}', {'e': e}));
      return;
    }
    _read();
  }

  Future<void> _paste() async {
    _answer.text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    _read();
  }

  void _read() {
    final t = parseAiTrip(_answer.text, fileName: _fileName);
    setState(() {
      _trip = t;
      _error = t == null && _answer.text.trim().isNotEmpty
          ? tr('V souboru jsem nenašel plán. Zkontroluj, že je to soubor CSV od AI se sloupci podle pokynu, '
              'případně AI napiš: „Vytvoř z plánu soubor CSV podle pokynu.“')
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_trip != null) return _AiPreview(trip: _trip!, onBack: () => setState(() => _trip = null));

    Widget step(int n, String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 14, child: Text('$n')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3, bottom: 6),
                      child: Text(title, style: theme.textTheme.titleSmall),
                    ),
                    ...children,
                  ],
                ),
              ),
            ],
          ),
        );
    Widget open(String label, String url) => OutlinedButton(
        onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication), child: Text(label));
    final box = BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      appBar: AppBar(title: Text(tr('Naplánovat s AI'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr('Nech si plán cesty připravit od AI a naimportuj ho. Aplikace sama vyplní cestu, plán po dnech, '
              'ubytování a místa na mapě.')),
          const SizedBox(height: 20),
          step(1, tr('Otevři svou AI'), [
            Wrap(spacing: 8, runSpacing: 4, children: [
              open('ChatGPT', 'https://chatgpt.com/'),
              open('Claude', 'https://claude.ai/new'),
              open('Copilot', 'https://copilot.microsoft.com/'),
              open('Gemini', 'https://gemini.google.com/app'),
            ]),
          ]),
          step(2, tr('Dej AI vzorový soubor a napiš, kam a kdy jedeš'), [
            Text(tr('Stáhni vzor (můžeš ho rovnou sdílet do aplikace ChatGPT), v chatu ho přilož přes 📎 a napiš:')),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: box,
              child: Text(_fillMessage, style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                icon: const Icon(Icons.download),
                label: Text(tr('Stáhnout vzorový soubor')),
                onPressed: _shareTemplate,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: Text(tr('Zkopírovat zprávu')),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _fillMessage));
                  _snack(tr('Zpráva je zkopírovaná – uprav v ní cíl a termín.'));
                },
              ),
            ]),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(tr('Bez vzoru: pokyn textem'), style: theme.textTheme.bodyMedium),
              children: [
                Text(tr('Napiš, kam a kdy jedeš, a hned za to vlož tento pokyn:'), style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: box,
                  child: Text(buildAiCsvInstruction(),
                      maxLines: 6, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: Text(tr('Zkopírovat pokyn')),
                    onPressed: _copyInstruction,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            Text(tr('Aplikace přečte i jiný itinerář v CSV (třeba sloupce Datum, Program, Oblast), se vzorem ale bude '
                'plán přesnější – s časy, ubytováním a polohou míst.'),
                style: theme.textTheme.bodySmall),
          ]),
          step(3, tr('Stáhni soubor .csv, který AI vytvoří'), [
            Text(tr('Když AI soubor nenabídne ke stažení, napiš jí: „Vytvoř z toho soubor CSV ke stažení.“ '
                'Soubor můžeš před importem upravit třeba v Excelu.')),
          ]),
          step(4, tr('Importuj soubor do aplikace'), [
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              icon: const Icon(Icons.upload_file),
              label: Text(tr('Importovat soubor z AI (.csv)')),
              onPressed: _pickFile,
            ),
            const SizedBox(height: 4),
            Text(tr('Jde to i ze složky Stažené: soubor → Sdílet → Travel Companion.'), style: theme.textTheme.bodySmall),
          ]),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ),
          TextButton.icon(
            icon: Icon(_showPaste ? Icons.expand_less : Icons.expand_more),
            label: Text(tr('Nemáš soubor? Vlož text odpovědi')),
            onPressed: () => setState(() => _showPaste = !_showPaste),
          ),
          if (_showPaste) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.content_paste),
              label: Text(tr('Vložit ze schránky')),
              onPressed: _paste,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _answer,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(border: const OutlineInputBorder(), hintText: tr('…nebo sem odpověď vlož ručně')),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _read, child: Text(tr('Načíst plán'))),
          ],
        ],
      ),
    );
  }
}

/// Náhled načteného plánu a vytvoření cesty (s ověřením polohy míst).
class _AiPreview extends ConsumerStatefulWidget {
  const _AiPreview({required this.trip, required this.onBack});
  final AiTrip trip;
  final VoidCallback onBack;

  @override
  ConsumerState<_AiPreview> createState() => _AiPreviewState();
}

class _AiPreviewState extends ConsumerState<_AiPreview> {
  int? _done;

  Future<void> _create() async {
    final db = ref.read(databaseProvider);
    if (!await ensureCanAdd(context, db, ProLimit.trip)) return;
    setState(() => _done = 0);
    await verifyPlaces(widget.trip, onProgress: (d, _) {
      if (mounted) setState(() => _done = d);
    });
    final id = await importAiTrip(db, widget.trip);
    if (!mounted) return;
    final missing = widget.trip.places.where((p) => p.lat == null).length;
    if (missing > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('Cesta je vytvořená. Polohu {n} míst se nepodařilo najít – doplníš ji na Mapě („Doplnit“).', {'n': missing}))));
    }
    context.go('/trips/trip/$id');
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final theme = Theme.of(context);
    final busy = _done != null;
    String? placeName(String? key) {
      for (final p in t.places) {
        if (p.key == key) return p.name;
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Plán z AI')),
        leading: BackButton(onPressed: busy ? null : widget.onBack),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text(t.name, style: theme.textTheme.headlineSmall),
          if (t.start != null)
            Text(t.end == null ? fmtDate(t.start!) : '${fmtDate(t.start!)} – ${fmtDate(t.end!)}'),
          if (t.countries.isNotEmpty) Text(t.countries.join(', '), style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            Chip(avatar: const Icon(Icons.calendar_month, size: 18), label: Text(tr('{n} dní', {'n': t.days.length}))),
            Chip(avatar: const Icon(Icons.checklist, size: 18), label: Text(tr('{n} položek', {'n': t.itemCount}))),
            Chip(avatar: const Icon(Icons.place, size: 18), label: Text(tr('{n} míst', {'n': t.places.length}))),
            if (t.stays.isNotEmpty)
              Chip(avatar: const Icon(Icons.hotel, size: 18), label: Text(tr('{n} ubytování', {'n': t.stays.length}))),
          ]),
          for (final s in t.stays)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.hotel),
              title: Text(s.name),
              subtitle: Text('${fmtDate(s.checkIn)} – ${fmtDate(s.checkOut)}'),
            ),
          for (final d in t.days) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(fmtDay(d.date), style: theme.textTheme.titleSmall),
            ),
            for (final it in d.items)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(width: 52, child: Text(it.minutes == null ? '' : fmtTime(it.minutes!))),
                title: Text(it.title),
                subtitle: placeName(it.placeKey) == null || placeName(it.placeKey) == it.title
                    ? null
                    : Text(placeName(it.placeKey)!),
              ),
          ],
          if (t.places.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(tr('Místa na mapu'), style: theme.textTheme.titleSmall),
            for (final p in t.places)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(placeIcon(p.type)),
                title: Text(p.name),
                subtitle: Text([p.city, p.country].whereType<String>().join(', ')),
              ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy ? null : _create,
        icon: busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.add),
        label: Text(busy
            ? tr('Hledám polohu míst {a}/{b}…', {'a': _done, 'b': t.places.length})
            : tr('Vytvořit cestu')),
      ),
    );
  }
}
