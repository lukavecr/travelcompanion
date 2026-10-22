import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../trips/trip_repository.dart';
import 'open_in_maps.dart';
import 'place_types.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key, required this.tripId});
  final String tripId;

  Future<void> _addPlace(BuildContext context, WidgetRef ref) async {
    final nameC = TextEditingController();
    final urlC = TextEditingController();
    var type = 'attraction';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nové místo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameC,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Název'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlC,
                  decoration: const InputDecoration(
                      labelText: 'Odkaz na mapu (nepovinné)'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in placeTypes.entries)
                      ChoiceChip(
                        label: Text(e.value),
                        selected: type == e.key,
                        onSelected: (_) => setState(() => type = e.key),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Uložit'),
            ),
          ],
        ),
      ),
    );

    final name = nameC.text.trim();
    final url = urlC.text.trim();
    if (ok == true && name.isNotEmpty) {
      await ref.read(tripRepositoryProvider).addPlace(
            tripId: tripId,
            name: name,
            type: type,
            mapUrl: url.isEmpty ? null : url,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('Uložená místa')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPlace(context, ref),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Přidat místo'),
      ),
      body: places.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Chyba: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Zatím tu nejsou žádná místa.\n'
                  'V Google Maps klepni na „Sdílet“ a vyber Travel Companion AI.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];
              final hasCoords = !(p.lat == 0 && p.lng == 0);
              return Card(
                child: ListTile(
                  leading: Icon(placeIcon(p.type)),
                  title: Text(p.name),
                  subtitle: Text(
                    '${placeTypes[p.type] ?? 'Místo'} · '
                    '${hasCoords ? 'poloha uložena' : 'bez souřadnic'}'
                    '${(p.country ?? '').isEmpty ? '' : ' · ${p.country}'}',
                  ),
                  onTap: () => openPlaceInMaps(p),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'delete') {
                        ref.read(tripRepositoryProvider).deletePlace(p.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'delete', child: Text('Smazat')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
