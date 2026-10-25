import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/country_info.dart';
import '../../core/file_crypto.dart';
import '../../core/format.dart';
import '../../core/full_image_screen.dart';
import '../../data/database.dart';
import '../money/receipt_reader.dart' show guessCurrency;
import '../trips/trip_repository.dart';
import 'bcbp.dart';
import 'doc_types.dart';
import 'email_parser.dart';
import 'document_repository.dart';
import 'guess.dart';
import 'scan_service.dart';
import '../../l10n/tr.dart';

/// NovÃ½ doklad (z naskenovanÃ©ho obrÃ¡zku) i Ãºprava existujÃ­cÃ­ho dokladu.
class NewDocumentScreen extends ConsumerStatefulWidget {
  const NewDocumentScreen({super.key, this.scan, this.existing, this.popOnSave = false});
  final ScanResult? scan;
  final DocView? existing;
  final bool popOnSave; // import z e-mailu s vÃ­ce doklady: po uloÅ¾enÃ­ zpÄ›t na seznam

  @override
  ConsumerState<NewDocumentScreen> createState() => _NewDocumentScreenState();
}

class _NewDocumentScreenState extends ConsumerState<NewDocumentScreen> {
  final _title = TextEditingController();
  final _number = TextEditingController();
  final _ref = TextEditingController();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _carrier = TextEditingController();
  final _passenger = TextEditingController();
  final _seat = TextEditingController();
  final _gate = TextEditingController();
  final _country = TextEditingController();

  late final ScanResult _scan;
  Bcbp? _bcbp;
  String _type = 'other';
  String? _tripId;
  int _codeIdx = 0;
  DateTime? _date;
  DateTime? _endDate; // ubytovÃ¡nÃ­: do kdy
  int? _minutes;
  bool _addToPlan = false;
  bool _defaultsDone = false;
  bool _saving = false;

  bool get _editing => widget.existing != null;
  bool get _fromText => _scan.path == emailDocPath;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      final t = ex.ticket;
      _scan = ScanResult(
        ex.doc.localPath,
        [
          if ((t?.qrData ?? '').isNotEmpty)
            ScannedCode(t!.qrData!, t.barcodeFormat ?? 'unknown'),
        ],
        ex.doc.rawText ?? '',
      );
      _type = ex.doc.type;
      _tripId = ex.trip.id;
      _title.text = ex.doc.title ?? '';
      _country.text = ex.doc.country ?? '';
      if (t != null) {
        _carrier.text = t.carrier ?? '';
        _number.text = t.number ?? '';
        _ref.text = t.bookingRef ?? '';
        _from.text = t.fromPlace ?? '';
        _to.text = t.toPlace ?? '';
        _passenger.text = t.passenger ?? '';
        _seat.text = t.seat ?? '';
        _gate.text = t.gate ?? '';
        if (t.departAt != null) {
          _date = dayOnly(t.departAt!);
          final m = t.departAt!.hour * 60 + t.departAt!.minute;
          _minutes = m == 0 ? null : m;
        }
      }
      _defaultsDone = true;
      return;
    }

    _scan = widget.scan!;
    final f = _scan.fields;
    Bcbp? found;
    for (var i = 0; i < _scan.codes.length; i++) {
      final b = parseBcbp(_scan.codes[i].value);
      if (b != null) {
        found = b;
        _codeIdx = i;
        break;
      }
    }
    _bcbp = found;
    if (found != null) {
      _type = 'flight';
      _title.text = tr('Let {flight} {from} â†’ {to}', {'flight': found.flight, 'from': found.from, 'to': found.to});
      _number.text = found.flight;
      _from.text = found.from;
      _to.text = found.to;
      _carrier.text = found.carrier;
    } else {
      _type = f['type'] ?? _guessType(_scan.text);
      _title.text = f['title'] ?? '';
      _number.text = f['flight'] ?? '';
      _carrier.text = f['carrier'] ?? '';
      _from.text = f['from'] ?? '';
      _to.text = f['to'] ?? '';
      _endDate = f['endDate'] != null ? DateTime.tryParse(f['endDate']!) : null;
    }
    _ref.text = found?.pnr ?? f['ref'] ?? guessBookingRef(_scan.text) ?? '';
    _passenger.text = found?.name ?? f['name'] ?? '';
    _seat.text = found?.seat ?? f['seat'] ?? '';
    _gate.text = f['gate'] ?? '';
  }

  String _guessType(String text) {
    final s = text.toLowerCase();
    bool any(List<String> k) => k.any(s.contains);
    if (any(['shinkansen', 'æ–°å¹¹ç·š', 'ä¹—è»Šåˆ¸', 'ç‰¹æ€¥åˆ¸', 'railway', 'train ticket'])) {
      return 'train';
    }
    if (any(['admission', 'entrance', 'å…¥å ´', 'æ‹è¦³', 'temple', 'shrine', 'museum',
        'universal', 'theme park'])) {
      return 'ticket';
    }
    if (any(['ferry', 'ä¹—èˆ¹'])) return 'ferry';
    if (any(['hotel', 'check-in', 'check in', 'å®¿æ³Š'])) return 'hotel';
    if (any(['bus ticket', 'ãƒã‚¹'])) return 'bus';
    return 'other';
  }

  @override
  void dispose() {
    for (final c in [
      _title, _number, _ref, _from, _to, _carrier, _passenger, _seat, _gate, _country
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Po naÄtenÃ­ cest doplnÃ­ vÃ½chozÃ­ cestu, datum a zemi.
  void _applyDefaults(List<Trip> trips) {
    if (_defaultsDone || trips.isEmpty) return;
    _defaultsDone = true;
    final f = _scan.fields;
    final first = trips.first;
    final refDate = first.startDate ?? DateTime.now();

    if (_bcbp != null) {
      _date = dateFromJulian(_bcbp!.julianDay, refDate);
    } else {
      _date = (f['date'] != null ? DateTime.tryParse(f['date']!) : null) ??
          guessDate(_scan.text);
      _minutes = (f['time'] != null ? int.tryParse(f['time']!) : null) ??
          guessTime(_scan.text);
    }

    _tripId = first.id;
    if (_date != null) {
      final d = dayOnly(_date!);
      for (final t in trips) {
        if (t.startDate != null &&
            t.endDate != null &&
            !d.isBefore(dayOnly(t.startDate!)) &&
            !d.isAfter(dayOnly(t.endDate!))) {
          _tripId = t.id;
          break;
        }
      }
      _addToPlan = true;
    }

    final trip = trips.firstWhere((t) => t.id == _tripId, orElse: () => first);
    final guessed = guessCountry(_scan.text, currency: guessCurrency(_scan.text));
    final matched = matchCountry(guessed, tripCountries(trip));
    if (matched != null && _country.text.isEmpty) _country.text = matched;
  }

  String? _clean(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    if (_tripId == null) return;
    setState(() => _saving = true);
    final repo = ref.read(documentRepositoryProvider);
    final title = _title.text.trim().isEmpty
        ? (docTypes[_type] ?? tr('Doklad'))
        : _title.text.trim();
    final departAt = _date == null
        ? null
        : DateTime(_date!.year, _date!.month, _date!.day, 0, _minutes ?? 0);
    final country = _clean(_country);

    String docId;
    if (_editing) {
      docId = widget.existing!.doc.id;
      await repo.updateScanned(
        docId,
        tripId: _tripId!,
        type: _type,
        title: title,
        country: country,
        carrier: _clean(_carrier),
        number: _clean(_number),
        bookingRef: _clean(_ref),
        from: _clean(_from),
        to: _clean(_to),
        passenger: _clean(_passenger),
        seat: _clean(_seat),
        gate: _clean(_gate),
        departAt: departAt,
      );
    } else {
      final stored = _fromText ? emailDocPath : await storeImage(_scan.path);
      final code = _scan.codes.isEmpty ? null : _scan.codes[_codeIdx];
      docId = await repo.saveScanned(
        tripId: _tripId!,
        type: _type,
        title: title,
        localPath: stored,
        rawText: _scan.text,
        carrier: _clean(_carrier),
        number: _clean(_number),
        bookingRef: _clean(_ref),
        from: _clean(_from),
        to: _clean(_to),
        passenger: _clean(_passenger),
        seat: _clean(_seat),
        gate: _clean(_gate),
        country: country,
        departAt: departAt,
        code: code?.value,
        codeFormat: code?.format,
      );
      if (_addToPlan && _date != null) {
        await ref.read(tripRepositoryProvider).addEvent(
              tripId: _tripId!,
              date: _date!,
              title: title,
              startMinutes: _minutes,
              documentId: docId,
              endDate: _type == 'hotel' ? _endDate : null,
            );
      }
    }
    if (!mounted) return;
    if (widget.popOnSave) {
      context.pop(docId);
    } else {
      context.go('/docs/doc/$docId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider).value ?? const <Trip>[];
    _applyDefaults(trips);
    final scan = _scan;
    final transport = transportTypes.contains(_type);
    Trip? currentTrip;
    for (final t in trips) {
      if (t.id == _tripId) currentTrip = t;
    }
    final planned = tripCountries(currentTrip);

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? tr('Upravit doklad') : tr('NovÃ½ doklad'))),
      body: trips.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(tr('NejdÅ™Ã­v vytvoÅ™ cestu v zÃ¡loÅ¾ce Cesty.'),
                    textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_fromText)
                GestureDetector(
                  onTap: () => openFullImage(context, tr('Doklad'), scan.path),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 160,
                      child: EncryptedImage(scan.path, fit: BoxFit.cover, errorText: tr('ObrÃ¡zek nenÃ­ k dispozici')),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_editing)
                  Text(
                    _fromText
                        ? tr('Ãšdaje z e-mailu jsou pÅ™edvyplnÄ›nÃ©, zkontroluj je.')
                        : _bcbp != null
                        ? tr('RozpoznÃ¡n palubnÃ­ lÃ­stek â€“ Ãºdaje jsou pÅ™edvyplnÄ›nÃ©.')
                        : scan.fields.isNotEmpty || scan.codes.isNotEmpty
                            ? tr('NÄ›co se rozpoznalo, Ãºdaje zkontroluj.')
                            : tr('Nic se nepodaÅ™ilo spolehlivÄ› pÅ™eÄÃ­st, Ãºdaje doplÅˆ ruÄnÄ›.'),
                  ),
                const SizedBox(height: 16),
                Text(tr('Typ'), style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in docTypes.entries)
                      ChoiceChip(
                        label: Text(e.value),
                        selected: _type == e.key,
                        onSelected: (_) => setState(() => _type = e.key),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(tr('Do kterÃ© cesty'),
                    style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final t in trips)
                      ChoiceChip(
                        label: Text(t.name),
                        selected: _tripId == t.id,
                        onSelected: (_) => setState(() => _tripId = t.id),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _title,
                  decoration: InputDecoration(labelText: tr('NÃ¡zev')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _country,
                  decoration: InputDecoration(labelText: tr('ZemÄ›')),
                ),
                if (planned.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final c in planned)
                        ActionChip(
                          label: Text(c),
                          onPressed: () => setState(() => _country.text = c),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                if (transport) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _from,
                          decoration: InputDecoration(labelText: tr('Odkud')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _to,
                          decoration: InputDecoration(labelText: tr('Kam')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _carrier,
                          decoration:
                              InputDecoration(labelText: tr('Dopravce')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _number,
                          decoration: InputDecoration(
                              labelText: tr('ÄŒÃ­slo letu / spoje')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _seat,
                          decoration: InputDecoration(
                              labelText: tr('Sedadlo / vÅ¯z')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _gate,
                          decoration: InputDecoration(
                              labelText: tr('Gate / nÃ¡stupiÅ¡tÄ›')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _passenger,
                  decoration: InputDecoration(
                      labelText: tr('JmÃ©no (cestujÃ­cÃ­ / zÃ¡kaznÃ­k)')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ref,
                  decoration:
                      InputDecoration(labelText: tr('ÄŒÃ­slo rezervace')),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event),
                        label: Text(_date == null ? tr('Datum') : fmtDate(_date!)),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _date ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2040),
                          );
                          if (d != null) {
                            setState(() {
                              _date = d;
                              if (!_editing) _addToPlan = true;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.schedule),
                        label: Text(
                            _minutes == null ? tr('ÄŒas') : fmtTime(_minutes!)),
                        onPressed: () async {
                          final start = _minutes ?? 540;
                          final t = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay(hour: start ~/ 60, minute: start % 60),
                          );
                          if (t != null) {
                            setState(() => _minutes = t.hour * 60 + t.minute);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_type == 'hotel' && !_editing) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: Text(_endDate == null
                        ? tr('Odjezd (do kdy)')
                        : tr('Odjezd: {d}', {'d': fmtDate(_endDate!)})),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? _date ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2040),
                      );
                      if (d != null) setState(() => _endDate = d);
                    },
                  ),
                ],
                if (_date != null && !_editing)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tr('PÅ™idat do plÃ¡nu dne')),
                    value: _addToPlan,
                    onChanged: (v) => setState(() => _addToPlan = v),
                  ),
                if (!_editing && scan.codes.length > 1) ...[
                  const SizedBox(height: 8),
                  Text(tr('KterÃ½ kÃ³d zobrazit'),
                      style: Theme.of(context).textTheme.titleSmall),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < scan.codes.length; i++)
                        ChoiceChip(
                          label: Text(
                            '${scan.codes[i].format}: '
                            '${scan.codes[i].value.length > 14 ? scan.codes[i].value.substring(0, 14) : scan.codes[i].value}',
                          ),
                          selected: _codeIdx == i,
                          onSelected: (_) => setState(() => _codeIdx = i),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_editing ? tr('UloÅ¾it zmÄ›ny') : tr('UloÅ¾it doklad')),
                ),
                const SizedBox(height: 12),
                ExpansionTile(
                  title: Text(tr('RozpoznanÃ½ text (pro kontrolu)')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(
                          scan.text.isEmpty ? tr('(nic nenalezeno)') : scan.text),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
