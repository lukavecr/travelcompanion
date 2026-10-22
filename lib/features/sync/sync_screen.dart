import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../pro/paywall.dart';
import '../pro/pro_service.dart';
import 'sync_service.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncServiceProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Záloha a účet')),
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
                    title: const Text('Záloha je součást Pro'),
                    subtitle: const Text(
                        'Ve verzi zdarma jsou data jen v tomto telefonu. Klepni pro víc informací.'),
                    onTap: () => openPaywall(context, ProLimit.backup),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(user?.email ?? 'Nepřihlášen'),
                  subtitle: const Text('Přihlášený účet'),
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
                          Icon(s.error != null
                              ? Icons.error_outline
                              : s.pending > 0
                                  ? Icons.cloud_upload_outlined
                                  : Icons.cloud_done_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.running
                                  ? 'Synchronizuji…'
                                  : s.error != null
                                      ? 'Synchronizace se nepovedla'
                                      : s.pending > 0
                                          ? 'Čeká na odeslání: ${s.pending}'
                                          : 'Vše je zazálohované',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(last == null
                          ? 'Zatím neproběhla žádná synchronizace.'
                          : 'Poslední synchronizace: ${fmtDate(last)} '
                              '${fmtTime(last.hour * 60 + last.minute)}'),
                      if (s.error != null) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          s.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
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
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Synchronizovat teď'),
                onPressed: s.running ? null : sync.syncNow,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Odhlásit se'),
                onPressed: s.running
                    ? null
                    : () async {
                        final ok = await confirm(context,
                            'Odhlásit se? Data se před tím odešlou do zálohy.');
                        if (!ok) return;
                        await sync.syncNow();
                        await FirebaseAuth.instance.signOut();
                      },
              ),
              const SizedBox(height: 16),
              const Text(
                'Zálohují se cesty, plán, místa, doklady, výdaje i obrázky. '
                'Obrázky se do zálohy ukládají zmenšené (do zhruba 0,6 MB), '
                'originály zůstávají v telefonu. Na novém telefonu se po '
                'přihlášení vše samo stáhne.',
              ),
            ],
          );
        },
      ),
    );
  }
}
