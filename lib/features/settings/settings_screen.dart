import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dialogs.dart';
import '../lock/app_lock.dart';
import '../sync/sync_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _wiping = false;

  Future<void> _wipe() async {
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Smazat všechna data?'),
        content: const Text(
          'Smaže se v telefonu i v záloze:\n'
          '• cesty a plán\n• místa\n• doklady a jejich fotky\n• výdaje a účtenky\n\n'
          'Zůstane: Vault, tvůj účet a přihlášení.\n\n'
          'Vrátit to nepůjde.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Theme.of(ctx).colorScheme.onError),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pokračovat'),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;

    // druhé potvrzení: otisk prstu / obličej / PIN telefonu
    final hasLock = await DeviceAuth.deviceHasLock();
    if (!mounted) return;
    final second = hasLock
        ? await DeviceAuth.confirm('Potvrď smazání všech dat')
        : await confirm(context,
            'Telefon nemá zámek obrazovky, proto se smazání potvrzuje jen tady. Opravdu smazat vše?');
    if (second != true || !mounted) return;

    setState(() => _wiping = true);
    String? error;
    try {
      await ref.read(syncServiceProvider).wipeAllData();
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => _wiping = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error == null
          ? 'Všechna data jsou smazaná.'
          : 'Smazání se nepovedlo (jsi online?). V telefonu se nic nesmazalo.\n$error'),
    ));
    if (error == null) context.go('/trips');
  }

  Future<void> _deleteAccount() async {
    final err = Theme.of(context).colorScheme.error;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.person_remove),
        title: const Text('Smazat účet?'),
        content: const Text(
          'Smaže se úplně všechno – cesty, místa, doklady, výdaje i celý Vault – '
          'v telefonu i v záloze, a nakonec tvůj účet.\n\nVrátit to nepůjde.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: err, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pokračovat'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (await DeviceAuth.deviceHasLock() &&
        !await DeviceAuth.confirm('Potvrď smazání účtu')) {
      return;
    }
    if (!mounted) return;
    final password = await _askPassword();
    if (password == null || !mounted) return;

    setState(() => _wiping = true);
    final error = await ref.read(syncServiceProvider).deleteAccount(password);
    if (!mounted) return;
    setState(() => _wiping = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Účet i všechna data jsou smazané.'),
    ));
    // po smazání se aplikace sama vrátí na přihlášení
  }

  Future<String?> _askPassword() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Heslo účtu'),
        content: TextField(
          controller: c,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Heslo, kterým se přihlašuješ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Zrušit')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: const Text('Smazat účet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final danger = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavení'),
        bottom: _wiping
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
      ),
      body: AbsorbPointer(
        absorbing: _wiping,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: const Text('Záloha a účet'),
                subtitle: const Text('Synchronizace, odhlášení'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/sync'),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text('Nebezpečná zóna',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: danger)),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.delete_forever, color: danger),
                title: Text('Smazat všechna data', style: TextStyle(color: danger)),
                subtitle: const Text('Telefon i záloha. Vault a účet zůstanou.'),
                onTap: _wiping ? null : _wipe,
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.person_remove, color: danger),
                title: Text('Smazat účet', style: TextStyle(color: danger)),
                subtitle: const Text('Všechna data včetně Vaultu a účet samotný.'),
                onTap: _wiping ? null : _deleteAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
