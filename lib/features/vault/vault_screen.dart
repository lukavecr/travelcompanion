import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../sync/sync_service.dart';
import 'sos_screen.dart';
import 'vault_crypto.dart';
import 'vault_item_screen.dart';
import 'vault_repository.dart';
import 'vault_types.dart';

/// Záložka Vault: založení / obnova heslem, odemčení otiskem, seznam položek.
class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

enum _Stage { checking, offline, setup, restore, locked, open }

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final _keys = VaultKeys.instance;
  _Stage _stage = _Stage.checking;

  @override
  void initState() {
    super.initState();
    _keys.addListener(_onKeys);
    _check();
  }

  @override
  void dispose() {
    _keys.removeListener(_onKeys);
    super.dispose();
  }

  void _onKeys() {
    if (!mounted) return;
    if (_keys.unlocked) {
      setState(() => _stage = _Stage.open);
      // stáhne položky z jiného telefonu / po obnově a odešle čekající
      ref.read(syncServiceProvider).syncNow();
    } else if (_stage == _Stage.open) {
      setState(() => _stage = _Stage.locked);
    }
  }

  Future<void> _check() async {
    if (_keys.unlocked) return setState(() => _stage = _Stage.open);
    if (await _keys.hasLocalKey()) {
      setState(() => _stage = _Stage.locked);
      return _unlock();
    }
    setState(() => _stage = _Stage.checking);
    final remote = await _keys.remoteExists();
    if (!mounted) return;
    setState(() => _stage = switch (remote) {
          null => _Stage.offline,
          true => _Stage.restore,
          false => _Stage.setup,
        });
  }

  Future<void> _unlock() => _keys.unlockWithDevice();

  @override
  Widget build(BuildContext context) {
    final open = _stage == _Stage.open;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        actions: [
          if (open) ...[
            IconButton(
              tooltip: 'Zamknout Vault',
              icon: const Icon(Icons.lock_outline),
              onPressed: _keys.lock,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    fullscreenDialog: true, builder: (_) => const SosScreen())),
                icon: const Icon(Icons.sos),
                label: const Text('SOS'),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: open
          ? FloatingActionButton.extended(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Přidat'),
            )
          : null,
      body: switch (_stage) {
        _Stage.checking => const Center(child: CircularProgressIndicator()),
        _Stage.offline => _Message(
            icon: Icons.cloud_off,
            text: 'Pro první nastavení Vaultu se připoj k internetu '
                '(zjišťuji, jestli už nemáš Vault v záloze).',
            button: 'Zkusit znovu',
            onPressed: _check,
          ),
        _Stage.setup => const _PasswordForm(restore: false),
        _Stage.restore => const _PasswordForm(restore: true),
        _Stage.locked => _Message(
            icon: Icons.lock_outline,
            text: 'Vault je zamčený.',
            button: 'Odemknout',
            onPressed: _unlock,
          ),
        _Stage.open => const _VaultList(),
      },
    );
  }

  Future<void> _addItem() async {
    final rows = ref.read(vaultRowsProvider).value ?? const <VaultItem>[];
    final t = await showModalBottomSheet<VaultType>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final t in vaultTypes)
              ListTile(
                leading: Icon(t.icon),
                title: Text(t.label),
                subtitle: t.singleton && rows.any((r) => r.type == t.key)
                    ? const Text('Už máš – otevře se k úpravě')
                    : null,
                onTap: () => Navigator.pop(ctx, t),
              ),
          ],
        ),
      ),
    );
    if (t == null || !mounted) return;
    VaultEntry? existing;
    if (t.singleton) {
      for (final r in rows) {
        if (r.type == t.key) existing = await ref.read(vaultRepositoryProvider).decrypt(r);
      }
    }
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => VaultItemScreen(type: t.key, existing: existing),
    ));
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, required this.button, required this.onPressed});
  final IconData icon;
  final String text;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(text, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onPressed, child: Text(button)),
            ],
          ),
        ),
      );
}

/// Založení Vaultu (heslo 2×) nebo obnova ze zálohy (heslo 1×).
class _PasswordForm extends StatefulWidget {
  const _PasswordForm({required this.restore});
  final bool restore;

  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  bool _busy = false;
  bool _show = false;
  String? _error;

  Future<void> _submit() async {
    final pw = _a.text;
    if (!widget.restore) {
      if (pw.length < 8) return setState(() => _error = 'Heslo musí mít aspoň 8 znaků.');
      if (pw != _b.text) return setState(() => _error = 'Hesla se neshodují.');
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.restore) {
        final ok = await VaultKeys.instance.restore(pw);
        if (!ok && mounted) setState(() => _error = 'Špatné heslo Vaultu.');
      } else {
        await VaultKeys.instance.setup(pw);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Nepovedlo se (jsi online?)\n$e');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(widget.restore ? Icons.restore : Icons.shield_outlined,
            size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(widget.restore ? 'Obnovit Vault ze zálohy' : 'Založit Vault',
            style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          widget.restore
              ? 'Vault už máš v záloze. Zadej heslo Vaultu, které sis zvolil při založení.'
              : 'Pas, víza, pojištění, očkování a nouzové kontakty se ukládají zašifrovaně. '
                  'Zvol si heslo Vaultu – je potřeba jen pro obnovu na novém telefonu. '
                  'Normálně Vault otevřeš otiskem prstu.',
          textAlign: TextAlign.center,
        ),
        if (!widget.restore) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Heslo si poznamenej na bezpečné místo. Když ho zapomeneš a ztratíš telefon, '
                'Vault ze zálohy obnovit nepůjde – nikdo (ani Google) ho nepřečte.',
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _a,
          obscureText: !_show,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Heslo Vaultu',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _show = !_show),
            ),
          ),
        ),
        if (!widget.restore) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _b,
            obscureText: !_show,
            decoration: const InputDecoration(
                labelText: 'Heslo znovu', border: OutlineInputBorder()),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.restore ? 'Obnovit' : 'Založit Vault'),
        ),
      ],
    );
  }
}

/// Seznam položek po sekcích, s upozorněním na konec platnosti.
class _VaultList extends ConsumerWidget {
  const _VaultList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(vaultRowsProvider).value ?? const <VaultItem>[];
    return FutureBuilder<List<VaultEntry>>(
      // klíč = stav řádků, aby se po změně znovu odšifrovalo
      key: ValueKey(rows.map((r) => '${r.id}${r.updatedAt}').join()),
      future: Future.wait(rows.map(ref.read(vaultRepositoryProvider).decrypt)),
      builder: (context, snap) {
        if (!snap.hasData) {
          return snap.hasError
              ? Center(child: Text('Nepodařilo se odšifrovat: ${snap.error}'))
              : const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Vault je prázdný.\nPřidej pas, pojištění, nouzové kontakty a zdravotní údaje – '
                'z nich se skládá i SOS.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
          children: [
            for (final t in vaultTypes)
              if (items.any((e) => e.type == t.key)) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                  child: Text(t.label, style: Theme.of(context).textTheme.titleSmall),
                ),
                for (final e in items.where((e) => e.type == t.key)) _VaultTile(entry: e),
              ],
          ],
        );
      },
    );
  }
}

class _VaultTile extends StatelessWidget {
  const _VaultTile({required this.entry});
  final VaultEntry entry;

  @override
  Widget build(BuildContext context) {
    final exp = entry.expiresAt;
    final today = dayOnly(DateTime.now());
    String? warn;
    Color? warnColor;
    if (exp != null) {
      if (exp.isBefore(today)) {
        warn = 'Platnost skončila ${fmtDate(exp)}';
        warnColor = Theme.of(context).colorScheme.error;
      } else if (exp.isBefore(today.add(entry.def.warnBefore))) {
        warn = 'Platnost končí ${fmtDate(exp)}';
        warnColor = Colors.orange;
      }
    }
    final sub = <String>[
      if (entry.fields['number']?.isNotEmpty == true) entry.fields['number']!,
      if (entry.fields['relation']?.isNotEmpty == true) entry.fields['relation']!,
      if (entry.fields['phone']?.isNotEmpty == true) entry.fields['phone']!,
      if (warn == null && exp != null) 'platí do ${fmtDate(exp)}',
      if (entry.photoIds.isNotEmpty) '📷 ${entry.photoIds.length}',
    ].join(' · ');
    return Card(
      child: ListTile(
        leading: Icon(entry.def.icon),
        title: Text(entry.title),
        subtitle: (sub.isEmpty && warn == null)
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sub.isNotEmpty) Text(sub),
                  if (warn != null)
                    Text(warn, style: TextStyle(color: warnColor, fontWeight: FontWeight.w600)),
                ],
              ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => VaultItemScreen(type: entry.type, existing: entry),
        )),
      ),
    );
  }
}
