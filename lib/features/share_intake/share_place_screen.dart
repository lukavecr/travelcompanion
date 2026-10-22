import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/country_info.dart';
import '../../core/format.dart';
import '../../core/geocode.dart';
import '../places/place_types.dart';
import '../trips/trip_repository.dart';
import 'share_parser.dart';

class SharePlaceScreen extends ConsumerStatefulWidget {
  const SharePlaceScreen({super.key, required this.text});
  final String text;

  @override
  ConsumerState<SharePlaceScreen> createState() => _SharePlaceScreenState();
}

class _SharePlaceScreenState extends ConsumerState<SharePlaceScreen> {
  final _nameC = TextEditingController();
  final _countryC = TextEditingController();
  String? _routeNote;
  late final SharedPlace _shared;
  Coords? _coords;
  bool _resolving = false;
  String _type = 'attraction';
  String? _tripId;
  bool _addToPlan = false;
  DateTime? _date;
  DateTime? _endDate; // jen ubytování
  int? _minutes; // jen ostatní typy
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _shared = parseSharedText(widget.text);
    _nameC.text = _shared.name;
    _coords = _shared.coords;
    if (_shared.url != null && (_coords == null || _shared.name.isEmpty)) {
      _resolving = true;
      resolveMaps(_shared.url!).then((r) {
        if (!mounted) return;
        setState(() {
          _coords ??= r.coords;
          if (_nameC.text.trim().isEmpty && r.name != null) {
            _nameC.text = r.name!;
          }
          if (r.origin != null && r.destination != null) {
            _routeNote = 'Sdílená trasa. Časy spojů se z Map přenést nedají, '
                'odkaz se uloží a po klepnutí se otevře v Mapách.';
            _type = 'transport';
            if (_nameC.text.trim().isEmpty) {
              _nameC.text = '${r.origin} → ${r.destination}';
            }
          }
          _resolving = false;
        });
        _lookupCountry();
      });
    }
    if (_coords != null) _lookupCountry();
  }

  Future<void> _lookupCountry() async {
    final c = _coords;
    if (c == null || _countryC.text.trim().isNotEmpty) return;
    final country = await reverseCountry(c.lat, c.lng);
    if (!mounted || country == null || _countryC.text.trim().isNotEmpty) return;
    setState(() => _countryC.text = country);
  }

  @override
  void dispose() {
    _countryC.dispose();
    _nameC.dispose();
    super.dispose();
  }

  DateTime get _hotelEnd =>
      _endDate ?? DateTime(_date!.year, _date!.month, _date!.day + 1);

  Future<void> _save() async {
    final name = _nameC.text.trim();
    if (name.isEmpty || _tripId == null) return;
    setState(() => _saving = true);
    final repo = ref.read(tripRepositoryProvider);
    final placeId = await repo.addPlace(
      tripId: _tripId!,
      name: name,
      type: _type,
      lat: _coords?.lat,
      lng: _coords?.lng,
      mapUrl: _shared.url,
      country: _countryC.text.trim().isEmpty
          ? null
          : matchCountry(_countryC.text.trim(),
              tripCountries(ref.read(tripProvider(_tripId!)).value)),
    );
    if (_addToPlan && _date != null) {
      final stay = _type == 'hotel';
      await repo.addEvent(
        tripId: _tripId!,
        date: _date!,
        endDate: stay ? _hotelEnd : null,
        startMinutes: stay ? null : _minutes,
        title: name,
        placeId: placeId,
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Místo uloženo')));
    context.go('/trips/trip/$_tripId');
  }

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      initialDateRange: DateTimeRange(start: _date!, end: _hotelEnd),
      helpText: 'Od kdy do kdy',
    );
    if (r != null) {
      setState(() {
        _date = r.start;
        _endDate = r.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider).value ?? const [];
    if (_tripId == null && trips.isNotEmpty) _tripId = trips.first.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uložit místo'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/trips'),
        ),
      ),
      body: trips.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nejdřív vytvoř cestu v záložce Cesty.',
                    textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nameC,
                  decoration: const InputDecoration(labelText: 'Název místa'),
                ),
                const SizedBox(height: 8),
                Text(
                  _resolving
                      ? 'Zjišťuji název a polohu…'
                      : _coords != null
                          ? 'Poloha nalezena: '
                              '${_coords!.lat.toStringAsFixed(5)}, '
                              '${_coords!.lng.toStringAsFixed(5)}'
                          : 'Souřadnice se nepodařilo zjistit, uložím alespoň odkaz.',
                ),
                if (_routeNote != null) ...[
                  const SizedBox(height: 8),
                  Text(_routeNote!),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _countryC,
                  decoration: const InputDecoration(
                      labelText: 'Země (doplní se z polohy)'),
                ),
                const SizedBox(height: 20),
                Text('Typ', style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in placeTypes.entries)
                      ChoiceChip(
                        label: Text(e.value),
                        selected: _type == e.key,
                        onSelected: (_) => setState(() => _type = e.key),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Do které cesty',
                    style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final t in trips)
                      ChoiceChip(
                        label: Text(t.name),
                        selected: _tripId == t.id,
                        onSelected: (_) => setState(() {
                          _tripId = t.id;
                          _date = null;
                          _endDate = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Přidat také do plánu'),
                  value: _addToPlan,
                  onChanged: (v) => setState(() {
                    _addToPlan = v;
                    if (v && _date == null) {
                      final t = trips.firstWhere((t) => t.id == _tripId);
                      _date = t.startDate ?? DateTime.now();
                    }
                  }),
                ),
                if (_addToPlan && _date != null) ...[
                  if (_type == 'hotel')
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text('${fmtDate(_date!)} – ${fmtDate(_hotelEnd)}'),
                      onPressed: _pickRange,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.event),
                            label: Text(fmtDate(_date!)),
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _date!,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2040),
                              );
                              if (d != null) setState(() => _date = d);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.schedule),
                            label: Text(
                                _minutes == null ? 'Čas' : fmtTime(_minutes!)),
                            onPressed: () async {
                              final start = _minutes ?? 540;
                              final t = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: start ~/ 60, minute: start % 60),
                              );
                              if (t != null) {
                                setState(() => _minutes = t.hour * 60 + t.minute);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Uložit místo'),
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Přijatý text (pro kontrolu)'),
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
