import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/dialogs.dart';
import '../../core/format.dart';
import 'vault_repository.dart';
import 'vault_sync.dart';
import 'vault_types.dart';

/// Nová položka nebo úprava (všechna pole podle typu + šifrované fotky).
class VaultItemScreen extends ConsumerStatefulWidget {
  const VaultItemScreen({super.key, required this.type, this.existing});
  final String type;
  final VaultEntry? existing;

  @override
  ConsumerState<VaultItemScreen> createState() => _VaultItemScreenState();
}

class _VaultItemScreenState extends ConsumerState<VaultItemScreen> {
  late final VaultType _def = vaultType(widget.type);
  late final Map<String, TextEditingController> _c = {
    for (final f in _def.fields)
      f.key: TextEditingController(text: widget.existing?.fields[f.key] ?? ''),
  };
  late final List<String> _photos = [...?widget.existing?.photoIds];
  final _removed = <String>[];
  final _added = <String>[];
  bool _saved = false;
  bool _busy = false;

  @override
  void dispose() {
    if (!_saved) {
      // fotky přidané do neuloženého formuláře nenechávat ležet
      final repo = ref.read(vaultRepositoryProvider);
      for (final id in _added) {
        repo.deletePhoto(id);
      }
    }
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(VaultField f) async {
    final cur = parseIsoDate(_c[f.key]!.text) ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: cur,
      firstDate: DateTime(1920),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _c[f.key]!.text = toIsoDate(d));
  }

  Future<void> _addPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;
    setState(() => _busy = true);
    final id = await ref.read(vaultRepositoryProvider).addPhoto(picked.path);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (id != null) {
        _photos.add(id);
        _added.add(id);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final repo = ref.read(vaultRepositoryProvider);
    await repo.save(
      id: widget.existing?.id,
      type: widget.type,
      fields: {
        for (final e in _c.entries)
          if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
      },
      photoIds: _photos,
    );
    for (final id in _removed) {
      await repo.deletePhoto(id);
    }
    _saved = true;
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final e = widget.existing!;
    final ok = await confirm(context,
        'Smazat „${e.title}“ (${_def.label}) včetně fotek? Smaže se i ze zálohy.');
    if (!ok) return;
    await ref.read(vaultRepositoryProvider).delete(e);
    _saved = true;
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? _def.label : 'Nové: ${_def.label}'),
        actions: [
          if (editing)
            IconButton(
              tooltip: 'Smazat',
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy ? null : _delete,
            ),
        ],
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          for (final f in _def.fields) ...[
            _field(f),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Text('Fotky (šifrovaně)', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in _photos)
                _PhotoThumb(
                  id: id,
                  title: _def.label,
                  onRemove: () => setState(() {
                    _photos.remove(id);
                    _removed.add(id);
                  }),
                ),
              _AddPhoto(
                icon: Icons.photo_camera,
                label: 'Vyfotit',
                onTap: _busy ? null : () => _addPhoto(ImageSource.camera),
              ),
              _AddPhoto(
                icon: Icons.photo_library,
                label: 'Z galerie',
                onTap: _busy ? null : () => _addPhoto(ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: const Icon(Icons.save),
            label: const Text('Uložit'),
          ),
        ],
      ),
    );
  }

  Widget _field(VaultField f) {
    final c = _c[f.key]!;
    switch (f.kind) {
      case FieldKind.date:
        final d = parseIsoDate(c.text);
        return InkWell(
          onTap: () => _pickDate(f),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: f.label,
              border: const OutlineInputBorder(),
              suffixIcon: d == null
                  ? const Icon(Icons.event)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => c.clear()),
                    ),
            ),
            child: Text(d == null ? '' : fmtDate(d)),
          ),
        );
      case FieldKind.phone:
        return TextField(
          controller: c,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: f.label,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: 'Zavolat',
              icon: const Icon(Icons.call),
              onPressed: () {
                final n = c.text.replaceAll(RegExp(r'[^0-9+]'), '');
                if (n.isNotEmpty) launchUrl(Uri(scheme: 'tel', path: n));
              },
            ),
          ),
        );
      default:
        return TextField(
          controller: c,
          minLines: f.kind == FieldKind.multiline ? 2 : 1,
          maxLines: f.kind == FieldKind.multiline ? 6 : 1,
          keyboardType: f.kind == FieldKind.email ? TextInputType.emailAddress : null,
          textCapitalization: f.kind == FieldKind.email
              ? TextCapitalization.none
              : TextCapitalization.sentences,
          decoration: InputDecoration(labelText: f.label, border: const OutlineInputBorder()),
        );
    }
  }
}

class _AddPhoto extends StatelessWidget {
  const _AddPhoto({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon), const SizedBox(height: 4), Text(label)],
          ),
        ),
      );
}

/// Náhled odšifrované fotky; klepnutí = celá obrazovka, podržení = odebrat.
class _PhotoThumb extends ConsumerWidget {
  const _PhotoThumb({required this.id, required this.title, required this.onRemove});
  final String id;
  final String title;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Uint8List?>(
      future: ref.read(vaultRepositoryProvider).loadPhoto(id, download: downloadVaultPhoto),
      builder: (context, snap) {
        final bytes = snap.data;
        return GestureDetector(
          onTap: bytes == null
              ? null
              : () => Navigator.of(context).push(MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(title: Text(title)),
                      body: InteractiveViewer(
                        maxScale: 6,
                        child: Center(child: Image.memory(bytes)),
                      ),
                    ),
                  )),
          onLongPress: () async {
            if (await confirm(context, 'Odebrat fotku?')) onRemove();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 96,
              height: 96,
              child: bytes != null
                  ? Image.memory(bytes, fit: BoxFit.cover)
                  : Center(
                      child: snap.connectionState == ConnectionState.done
                          ? const Icon(Icons.broken_image_outlined)
                          : const CircularProgressIndicator(strokeWidth: 2),
                    ),
            ),
          ),
        );
      },
    );
  }
}
