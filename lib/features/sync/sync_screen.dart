import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../pro/paywall.dart';
import '../pro/pro_service.dart';
import '../vault/vault_crypto.dart';
import 'backup_crypto.dart';
import 'sync_service.dart';
import '../../l10n/tr.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncServiceProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Záloha a účet'))),
      body: ValueListenableBuilder<SyncStatus>(
        valueListenable: sync.status,
        builder: (context, s, _) {
          final last = s.lastSync;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!ProService.instance.isPro)
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium),
                    title: Text(tr('Záloha je součást Pro')),
                    subtitle: Text(
                      tr(
                        'Ve verzi zdarma jsou data jen v tomto telefonu. Klepni pro víc informací.',
                      ),
                    ),
                    onTap: () => openPaywall(context, ProLimit.backup),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(user?.email ?? tr('Nepřihlášen')),
                  subtitle: Text(tr('Přihlášený účet')),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            s.error != null
                                ? Icons.error_outline
                                : s.pending > 0
                                ? Icons.cloud_upload_outlined
                                : Icons.cloud_done_outlined,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.running
                                  ? tr('Synchronizuji…')
                                  : s.needsEncryption &&
                                        ProService.instance.isPro
                                  ? tr('Záloha čeká na nastavení šifrování')
                                  : s.error != null
                                  ? tr('Synchronizace se nepovedla')
                                  : s.pending > 0
                                  ? tr('Čeká na odeslání: {pending}', {
                                      'pending': s.pending,
                                    })
                                  : tr('Vše je zazálohované'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        last == null
                            ? tr('Zatím neproběhla žádná synchronizace.')
                            : tr(
                                'Poslední synchronizace: {last} '
                                '{minute}',
                                {
                                  'last': fmtDate(last),
                                  'minute': fmtTime(
                                    last.hour * 60 + last.minute,
                                  ),
                                },
                              ),
                      ),
                      if (s.error != null) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          s.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      if (s.running) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              const _EncryptionCard(),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.sync),
                label: Text(tr('Synchronizovat teď')),
                onPressed: s.running ? null : sync.syncNow,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.alternate_email),
                label: Text(tr('Změnit e-mail účtu')),
                onPressed: s.running ? null : () => _changeEmail(context),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text(tr('Odhlásit se')),
                onPressed: s.running
                    ? null
                    : () async {
                        final ok = await confirm(
                          context,
                          tr(
                            'Odhlásit se? Data se před tím odešlou do zálohy.',
                          ),
                        );
                        if (!ok) return;
                        await sync.syncNow();
                        await FirebaseAuth.instance.signOut();
                      },
              ),
              const SizedBox(height: 16),
              Text(
                tr(
                  'Zálohují se cesty, plán, místa, doklady, výdaje i obrázky. '
                  'Obrázky se do zálohy ukládají zmenšené (do zhruba 0,6 MB), '
                  'originály zůstávají v telefonu. Na novém telefonu se po '
                  'přihlášení vše samo stáhne.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Změna e-mailu účtu: data i Pro zůstávají (stejný účet), mění se jen přihlašovací adresa.
/// Firebase pošle na novou adresu potvrzovací odkaz; změna platí až po jeho otevření.
Future<void> _changeEmail(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.email == null) return;
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('Změnit e-mail účtu')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tr('Teď: {email}', {'email': user.email})),
          const SizedBox(height: 12),
          TextField(
            controller: emailC,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: InputDecoration(
              labelText: tr('Nový e-mail'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passC,
            obscureText: true,
            decoration: InputDecoration(
              labelText: tr('Současné heslo'),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(tr('Zrušit')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(tr('Změnit')),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final newEmail = emailC.text.trim();
  String msg;
  try {
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: passC.text),
    );
    await user.verifyBeforeUpdateEmail(newEmail);
    msg = tr(
      'Na {newEmail} přišel e-mail s odkazem. Po jeho otevření se změna dokončí '
      'a přihlásíš se novou adresou (heslo zůstává).',
      {'newEmail': newEmail},
    );
  } on FirebaseAuthException catch (e) {
    msg = switch (e.code) {
      'wrong-password' || 'invalid-credential' => tr('Špatné heslo.'),
      'invalid-email' => tr('Neplatný e-mail.'),
      'email-already-in-use' => tr('Na tuhle adresu už je jiný účet.'),
      'network-request-failed' => tr('Nejsi připojený k internetu.'),
      _ => tr('Nepovedlo se ({code}).', {'code': e.code}),
    };
  }
  if (context.mounted) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Stav a zapnutí šifrované zálohy.
class _EncryptionCard extends ConsumerStatefulWidget {
  const _EncryptionCard();

  @override
  ConsumerState<_EncryptionCard> createState() => _EncryptionCardState();
}

class _EncryptionCardState extends ConsumerState<_EncryptionCard> {
  bool _busy = false;

  Future<void> _enable() async {
    if (!ProService.instance.isPro)
      return openPaywall(context, ProLimit.backup);
    final vault = VaultKeys.instance;
    if (!await vault.hasLocalKey()) {
      // Vault ještě není: založí se s heslem a šifrování zálohy se zapne samo (VaultScreen)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Zvol heslo Vaultu – chrání pas i celou zálohu. Šifrování zálohy se pak zapne samo.',
            ),
          ),
        ),
      );
      context.go('/vault');
      return;
    }
    if (!await vault.unlockWithDevice() || !mounted) return;
    setState(() => _busy = true);
    final err = await ref.read(syncServiceProvider).enableEncryptedBackup();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null
              ? tr('Hotovo – záloha je zašifrovaná.')
              : tr('Šifrování se nepovedlo dokončit, zkus to znovu: {err}', {
                  'err': err,
                }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bc = BackupCrypto.instance;
    return ListenableBuilder(
      listenable: bc,
      builder: (context, _) => FutureBuilder<bool>(
        future: bc.active,
        builder: (context, snap) {
          final active = snap.data ?? false;
          if (active) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.green),
                title: Text(tr('Záloha je šifrovaná')),
                subtitle: Text(
                  tr(
                    'Klíč chrání heslo Vaultu. Bez něj zálohu nikdo nepřečte.',
                  ),
                ),
              ),
            );
          }
          if (bc.lockedRemote) {
            return Card(
              color: Colors.orange.withValues(alpha: 0.15),
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.orange),
                title: Text(tr('Záloha je šifrovaná – odemkni ji')),
                subtitle: Text(
                  tr('Otevři Vault a zadej heslo Vaultu, pak se data stáhnou.'),
                ),
                onTap: () => context.go('/vault'),
              ),
            );
          }
          if (!ProService.instance.isPro) return const SizedBox.shrink();
          return Card(
            color: Colors.orange.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.enhanced_encryption_outlined,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tr('Nastav šifrovanou zálohu'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(
                      'Záloha se ukládá jen šifrovaně, aby ji nepřečetl nikdo jiný – ani Google, ani my. '
                      'Klíč chrání heslo Vaultu: na novém telefonu jím zálohu odemkneš. Dokud šifrování nenastavíš, '
                      'nic se do cloudu neodesílá.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _busy
                      ? const LinearProgressIndicator()
                      : FilledButton.icon(
                          icon: const Icon(Icons.lock_outline),
                          onPressed: _enable,
                          label: Text(tr('Nastavit')),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
