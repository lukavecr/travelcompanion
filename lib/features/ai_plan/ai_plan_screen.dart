import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../places/place_types.dart';
import '../pro/paywall.dart';
import 'ai_trip.dart';
import '../../l10n/tr.dart';

/// „Naplánovat s AI“: zadání pro ChatGPT/Claude/Copilot → vložit odpověď → náhled → nová cesta.
class AiPlanScreen extends ConsumerStatefulWidget {
  const AiPlanScreen({super.key, this.answer});
  final String? answer; // text sdílený z aplikace AI

  @override
  ConsumerState<AiPlanScreen> createState() => _AiPlanScreenState();
}

class _AiPlanScreenState extends ConsumerState<AiPlanScreen> {
  final _where = TextEditingController();
  final _likes = TextEditingController();
  final _answer = TextEditingController();
  DateTimeRange? _range;
  AiTrip? _trip;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.answer != null) {
      _answer.text = widget.answer!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _read());
    }
  }

  @override
  void dispose() {
    for (final c in [_where, _likes, _answer]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _prompt => buildAiPrompt(
        where: _where.text.trim(),
        dates: _range == null ? null : '${fmtDate(_range!.start)} – ${fmtDate(_range!.end)}',
        likes: _likes.text.trim(),
      );

  Future<void> _copy({Uri Function(String prompt)? open}) async {
    if (_where.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Napiš, kam jedeš.'))));
      return;
    }
    await Clipboard.setData(ClipboardData(text: _prompt));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('Zadání je zkopírované. V AI ho vlož (podrž prst → Vložit) a odešli.'))));
    if (open != null) await launchUrl(open(_prompt), mode: LaunchMode.externalApplication);
  }

  Future<void> _paste() async {
    final t = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    _answer.text = t;
    _read();
  }

  void _read() {
    final t = parseAiTrip(_answer.text);
    setState(() {
      _trip = t;
      _error = t == null && _answer.text.trim().isNotEmpty
          ? tr('V textu jsem nenašel plán ve formátu pro aplikaci. Zkopíruj z AI celou odpověď včetně bloku kódu na konci, '
              'případně AI napiš: „Vypiš plán ještě jednou jako JSON podle zadání.“')
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_trip != null) return _AiPreview(trip: _trip!, onBack: () => setState(() => _trip = null));

    Widget aiButton(String label, Uri Function(String p) url) =>
        OutlinedButton(onPressed: () => _copy(open: url), child: Text(label));

    return Scaffold(
      appBar: AppBar(title: Text(tr('Naplánovat s AI'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr('Nech si plán cesty připravit od ChatGPT, Claude, Copilota nebo Gemini. Aplikace z odpovědi '
              'sama vytvoří cestu, plán po dnech, ubytování a místa na mapě.')),
          const SizedBox(height: 16),
          Text(tr('1. Zadání pro AI'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: _where, decoration: InputDecoration(labelText: tr('Kam jedeš'), hintText: tr('např. Japonsko – Tokio a Kjóto'))),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(_range == null
                ? tr('Termín (nepovinné)')
                : '${fmtDate(_range!.start)} – ${fmtDate(_range!.end)}'),
            onPressed: () async {
              final now = DateTime.now();
              final r = await showDateRangePicker(
                  context: context, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 5), initialDateRange: _range);
              if (r != null) setState(() => _range = r);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _likes,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
                labelText: tr('Co tě baví, s kým jedeš (nepovinné)'),
                hintText: tr('např. jídlo, chrámy, příroda; ve dvou; spíš levněji')),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(tr('Zkopírovat zadání')),
            onPressed: () => _copy(),
          ),
          const SizedBox(height: 8),
          Text(tr('…nebo zkopírovat a rovnou otevřít:'), style: theme.textTheme.bodySmall),
          Wrap(spacing: 8, children: [
            aiButton('ChatGPT', (p) => Uri.https('chatgpt.com', '/', {'q': p})),
            aiButton('Claude', (p) => Uri.https('claude.ai', '/new', {'q': p})),
            aiButton('Copilot', (p) => Uri.https('copilot.microsoft.com', '/', {'q': p})),
            aiButton('Gemini', (p) => Uri.https('gemini.google.com', '/app')),
          ]),
          const Divider(height: 40),
          Text(tr('2. Vlož odpověď AI'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(tr('V AI zkopíruj celou odpověď (nebo jen blok kódu na konci). Jde i Sdílet → Travel Companion.'),
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
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
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _read, child: Text(tr('Načíst plán'))),
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
