import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/dialogs.dart';
import '../../data/database.dart';
import '../pro/paywall.dart';
import '../pro/pro_service.dart';
import '../trips/trip_repository.dart';
import 'share_logic.dart';
import 'shared_trips.dart';
import '../../l10n/tr.dart';

/// Může upravovat plán a zvát? Majitel a účastník s Pro ano, účastník zdarma jen
/// sleduje plán a přidává výdaje a místa.
bool canEditPlan(Trip t) => t.shareRole != 'member' || ProService.instance.isPro;

Future<String?> _askMyName(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final email = FirebaseAuth.instance.currentUser?.email ?? '';
  final c = TextEditingController(
      text: prefs.getString('share_my_name') ??
          FirebaseAuth.instance.currentUser?.displayName ??
          (email.contains('@') ? email.split('@').first : ''));
  if (!context.mounted) return null;
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('Tvoje jméno v cestě')),
      content: TextField(
        controller: c,
        autofocus: true,
        decoration: InputDecoration(helperText: tr('Uvidí ho ostatní účastníci (např. u výdajů).')),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Zrušit'))),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, c.text.trim().isEmpty ? null : c.text.trim()),
          child: Text(tr('Pokračovat')),
        ),
      ],
    ),
  );
  if (name != null) await prefs.setString('share_my_name', name);
  return name;
}

String _inviteText(String tripName, String code) => tr(
    'Přidej se k mé cestě „{trip}“ v aplikaci Travel Companion: uvidíš plán i útraty. '
    'V aplikaci otevři Cesty, klepni na ikonu „Připojit se kódem“ a zadej kód {code} (platí 7 dní).\n'
    'https://play.google.com/store/apps/details?id=com.lukrom.travelcompanion',
    {'trip': tripName, 'code': formatInviteCode(code)});

/// Sdílení cesty: účastníci, pozvánky, odchod.
class ShareTripScreen extends ConsumerStatefulWidget {
  const ShareTripScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<ShareTripScreen> createState() => _ShareTripScreenState();
}

class _ShareTripScreenState extends ConsumerState<ShareTripScreen> {
  final _s = SharedTrips.instance;
  bool _busy = false;
  String? _code;

  @override
  void initState() {
    super.initState();
    _s.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _s.removeListener(_changed);
    super.dispose();
  }

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    try {
      await f();
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('Bez připojení k internetu – zkus to za chvíli znovu.'))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr('Nepodařilo se: {e}. Zkontroluj připojení k internetu.', {'e': e}))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(Trip t) async {
    if (!ProService.instance.isPro) return openPaywall(context, ProLimit.shareTrip);
    final name = await _askMyName(context);
    if (name == null) return;
    await _run(() async => _code = await _s.share(t.id, name));
  }

  Future<void> _invite(Trip t) async {
    if (!ProService.instance.isPro) return openPaywall(context, ProLimit.shareTrip);
    await _run(() async => _code = await _s.createInvite(t.id));
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider(widget.tripId)).value;
    final theme = Theme.of(context);
    if (trip == null) return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    final role = trip.shareRole;
    final members = _s.membersOf(trip.id);
    final me = SharedTrips.myUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Společná cesta')),
        bottom: _busy
            ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(trip.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (role == null) ...[
            Text(tr('Pozvi partnera, rodinu nebo kamarády: všichni uvidí plán, místa a útraty '
                'a můžou přidávat výdaje. Aplikace spočítá, kdo komu kolik dluží.')),
            const SizedBox(height: 8),
            Text(tr('Doklady, Vault a tvoje trasy zůstávají jen tvoje. Data cesty jsou šifrovaná '
                'klíčem, který mají jen účastníci.'),
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : () => _share(trip),
              icon: const Icon(Icons.group_add),
              label: Text(tr('Sdílet cestu')),
            ),
            if (!ProService.instance.isPro)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(tr('Sdílet můžeš s Pro. Pozvaní můžou mít verzi zdarma.'),
                    style: theme.textTheme.bodySmall),
              ),
          ] else ...[
            if (_code != null)
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(tr('Kód pozvánky (platí 7 dní)')),
                      const SizedBox(height: 8),
                      SelectableText(formatInviteCode(_code!),
                          style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.send),
                            label: Text(tr('Poslat pozvánku')),
                            onPressed: () => SharePlus.instance
                                .share(ShareParams(text: _inviteText(trip.name, _code!))),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.copy),
                            label: Text(tr('Kopírovat')),
                            onPressed: () => Clipboard.setData(ClipboardData(text: formatInviteCode(_code!))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(tr('Účastníci'), style: theme.textTheme.titleSmall),
            for (final m in members)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(m.name.isEmpty ? '?' : m.name[0].toUpperCase())),
                title: Text(m.uid == me ? tr('{name} (ty)', {'name': m.name}) : m.name),
                subtitle: Text(m.role == 'owner' ? tr('zakladatel') : tr('účastník')),
                trailing: role == 'owner' && m.uid != me
                    ? IconButton(
                        tooltip: tr('Odebrat'),
                        icon: const Icon(Icons.person_remove_outlined),
                        onPressed: () async {
                          if (await confirm(context, tr('Odebrat {name} z cesty?', {'name': m.name}))) {
                            await _run(() => _s.removeMember(trip.id, m.uid));
                          }
                        },
                      )
                    : null,
              ),
            const SizedBox(height: 12),
            if (canEditPlan(trip))
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _invite(trip),
                icon: const Icon(Icons.person_add_alt),
                label: Text(tr('Pozvat dalšího')),
              ),
            const SizedBox(height: 24),
            if (role == 'owner')
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                icon: const Icon(Icons.link_off),
                label: Text(tr('Zrušit sdílení')),
                onPressed: _busy
                    ? null
                    : () async {
                        if (await confirm(context,
                            tr('Zrušit sdílení? Ostatním zůstane jejich kopie cesty, další změny už neuvidí.'))) {
                          await _run(() => _s.stopSharing(trip.id));
                        }
                      },
              )
            else
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                icon: const Icon(Icons.logout),
                label: Text(tr('Opustit cestu')),
                onPressed: _busy
                    ? null
                    : () async {
                        if (await confirm(context, tr('Opustit cestu? Zmizí z tvého telefonu, ostatním zůstane.'))) {
                          await _run(() => _s.leave(trip.id));
                          if (context.mounted) context.go('/trips');
                        }
                      },
              ),
          ],
        ],
      ),
    );
  }
}

/// Připojení ke společné cestě kódem z pozvánky.
Future<void> joinWithCode(BuildContext context) async {
  final clip = normalizeInviteCode((await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '');
  if (!context.mounted) return;
  final c = TextEditingController(text: clip == null ? '' : formatInviteCode(clip));
  final code = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('Připojit se kódem')),
      content: TextField(
        controller: c,
        autofocus: clip == null,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(hintText: 'ABCD-EFGH-JKMN', helperText: tr('Kód z pozvánky')),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Zrušit'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(tr('Připojit'))),
      ],
    ),
  );
  if (code == null || !context.mounted) return;
  final norm = normalizeInviteCode(code);
  void snack(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  if (norm == null) return snack(tr('To nevypadá jako kód pozvánky (12 znaků).'));
  final name = await _askMyName(context);
  if (name == null || !context.mounted) return;
  try {
    final id = await SharedTrips.instance.join(norm, name);
    if (context.mounted) context.go('/trips/trip/$id');
  } on TimeoutException {
    snack(tr('Bez připojení k internetu – zkus to za chvíli znovu.'));
  } on StateError catch (e) {
    snack(e.message == 'expired'
        ? tr('Pozvánka už vypršela. Požádej o novou.')
        : tr('Pozvánka nenalezena. Zkontroluj kód.'));
  } catch (e) {
    snack(tr('Nepodařilo se: {e}. Zkontroluj připojení k internetu.', {'e': e}));
  }
}
