import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import 'vault_repository.dart';

/// SOS: SMS s polohou nouzovým kontaktům + karta pro záchranáře (anglicky).
/// Data bere z Vaultu (nouzové kontakty, zdravotní údaje, pojištění).
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  Position? _pos;
  String? _posError;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _posError = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Zapni v telefonu Polohu (GPS).';
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        throw 'Aplikace nemá povolenou polohu.';
      }
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) setState(() => _pos = last);
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
      );
      if (mounted) setState(() => _pos = p);
    } catch (e) {
      if (mounted) setState(() => _posError = _pos == null ? '$e' : null);
    }
    if (mounted) setState(() => _locating = false);
  }

  String _smsText() {
    final p = _pos;
    final where = p == null
        ? 'Polohu se nepodařilo zjistit.'
        : 'Moje poloha: https://maps.google.com/?q=${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)} '
            '(přesnost ±${p.accuracy.round()} m)';
    return 'SOS – potřebuji pomoc. $where';
  }

  Future<void> _sms(List<String> phones) async {
    // aplikace Zprávy se otevře s předvyplněnou zprávou, odeslání potvrdíš tam
    final body = Uri.encodeComponent(_smsText());
    final uri = Platform.isIOS
        // iOS: víc příjemců jen přes /open?addresses=, text za „&body=“
        ? Uri.parse('sms:/open?addresses=${phones.join(',')}&body=$body')
        : Uri.parse('sms:${phones.join(',')}?body=$body');
    await launchUrl(uri);
  }

  String _phone(String s) => s.replaceAll(RegExp(r'[^0-9+]'), '');

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(vaultRowsProvider).value ?? const <VaultItem>[];
    return FutureBuilder<List<VaultEntry>>(
      key: ValueKey(rows.map((r) => '${r.id}${r.updatedAt}').join()),
      future: Future.wait(rows.map(ref.read(vaultRepositoryProvider).decrypt)),
      builder: (context, snap) {
        final items = snap.data ?? const <VaultEntry>[];
        final contacts = items
            .where((e) => e.type == 'contact' && _phone(e.fields['phone'] ?? '').isNotEmpty)
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('SOS'),
            backgroundColor: Colors.red.shade900,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: _locating
                      ? const SizedBox(
                          width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(_pos == null ? Icons.location_off : Icons.my_location),
                  title: Text(_pos == null
                      ? (_locating ? 'Zjišťuji polohu…' : 'Poloha neznámá')
                      : '${_pos!.latitude.toStringAsFixed(5)}, ${_pos!.longitude.toStringAsFixed(5)}'),
                  subtitle: Text(_posError ??
                      (_pos == null ? '' : 'přesnost ±${_pos!.accuracy.round()} m')),
                  trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: _locate),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(64),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: contacts.isEmpty
                    ? null
                    : () => _sms([for (final c in contacts) _phone(c.fields['phone']!)]),
                icon: const Icon(Icons.sms),
                label: Text(contacts.isEmpty
                    ? 'Přidej nouzové kontakty do Vaultu'
                    : 'Poslat SMS s polohou všem (${contacts.length})'),
              ),
              const SizedBox(height: 8),
              for (final c in contacts)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(c.title),
                    subtitle: Text([
                      if (c.fields['relation']?.isNotEmpty == true) c.fields['relation']!,
                      c.fields['phone']!,
                    ].join(' · ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'SMS s polohou',
                          icon: const Icon(Icons.sms_outlined),
                          onPressed: () => _sms([_phone(c.fields['phone']!)]),
                        ),
                        IconButton(
                          tooltip: 'Zavolat',
                          icon: const Icon(Icons.call),
                          onPressed: () => launchUrl(
                              Uri(scheme: 'tel', path: _phone(c.fields['phone']!))),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => RescuerCard(items: items),
                )),
                icon: const Icon(Icons.medical_information),
                label: const Text('Karta pro záchranáře (anglicky)'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tip: tísňovou linku vytočíš i bez odemčení telefonu (tlačítko „Tísňové volání“ '
                'na zamykací obrazovce). Zdravotní údaje si můžeš dát i do „Nouzových informací“ '
                'v Nastavení telefonu – záchranáři je uvidí bez odemčení.',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Velká, čitelná karta v angličtině – telefon se podá záchranáři.
class RescuerCard extends StatelessWidget {
  const RescuerCard({super.key, required this.items});
  final List<VaultEntry> items;

  @override
  Widget build(BuildContext context) {
    VaultEntry? first(String type) {
      for (final e in items) {
        if (e.type == type) return e;
      }
      return null;
    }

    final med = first('medical');
    final passport = first('passport');
    final contacts = items.where((e) => e.type == 'contact').toList();
    final insurance = items.where((e) => e.type == 'insurance').toList();
    String? f(VaultEntry? e, String k) {
      final v = e?.fields[k]?.trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    final name = f(med, 'name') ?? f(passport, 'name');
    final birth = parseIsoDate(f(med, 'birthDate') ?? f(passport, 'birthDate'));

    Widget row(String label, String? value, {bool big = false, VoidCallback? onTap}) {
      if (value == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: const TextStyle(fontSize: 13, color: Colors.black54, letterSpacing: 1)),
              Text(value,
                  style: TextStyle(
                      fontSize: big ? 30 : 22,
                      fontWeight: big ? FontWeight.bold : FontWeight.w500,
                      color: onTap != null ? Colors.red.shade900 : Colors.black)),
            ],
          ),
        ),
      );
    }

    String tel(String s) => s.replaceAll(RegExp(r'[^0-9+]'), '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        title: const Text('EMERGENCY INFORMATION'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          row('Name', name, big: true),
          row('Date of birth', birth == null ? null : fmtDate(birth)),
          row('Nationality', f(passport, 'nationality')),
          row('Blood type', f(med, 'bloodType'), big: true),
          row('Allergies', f(med, 'allergies')),
          row('Medications', f(med, 'medications')),
          row('Medical conditions', f(med, 'conditions')),
          row('Doctor', f(med, 'doctor')),
          if (contacts.isNotEmpty) ...[
            const Divider(height: 32),
            const Text('IN CASE OF EMERGENCY CONTACT',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
            for (final c in contacts)
              row(
                [c.title, if (f(c, 'relation') != null) '(${f(c, 'relation')})'].join(' '),
                f(c, 'phone'),
                onTap: f(c, 'phone') == null
                    ? null
                    : () => launchUrl(Uri(scheme: 'tel', path: tel(f(c, 'phone')!))),
              ),
          ],
          if (insurance.isNotEmpty) ...[
            const Divider(height: 32),
            const Text('TRAVEL INSURANCE',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
            for (final i in insurance) ...[
              row('Company', f(i, 'company')),
              row('Policy number', f(i, 'policy')),
              row('24/7 assistance', f(i, 'assistance'),
                  onTap: f(i, 'assistance') == null
                      ? null
                      : () => launchUrl(Uri(scheme: 'tel', path: tel(f(i, 'assistance')!)))),
            ],
          ],
          if (med == null)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text('(Doplň ve Vaultu „Zdravotní údaje“ – tady se pak ukážou.)',
                  style: TextStyle(color: Colors.black54)),
            ),
        ],
      ),
    );
  }
}
