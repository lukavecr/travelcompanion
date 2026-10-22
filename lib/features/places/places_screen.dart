import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../trips/trip_repository.dart';
import 'locate_place_screen.dart';
import 'open_in_maps.dart';
import 'place_types.dart';
import '../../l10n/tr.dart';

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
          title: Text(tr('Nové místo')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameC,
                  autofocus: true,
                  decoration: InputDecoration(labelText: tr('Název')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlC,
                  decoration: InputDecoration(
                      labelText: tr('Odkaz na mapu (nepovinné)')),
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
              child: Text(tr('Zrušit')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('Uložit')),
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
      appBar: AppBar(title: Text(tr('Uložená místa'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPlace(context, ref),
        icon: const Icon(Icons.add_location_alt),
        label: Text(tr('Přidat místo')),
      ),
      body: places.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Chyba: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  tr('Zatím tu nejsou žádná místa.\n' 'V Google Maps klepni na „Sdílet“ a vyber Travel Companion AI.'),
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
                    '${hasCoords ? 'poloha uložena' : 'bez polohy – klepni a najdi'}'
                    '${(p.country ?? '').isEmpty ? '' : ' · ${p.country}'}',
                  ),
                  onTap: hasCoords
                      ? () => openPlaceInMaps(p)
                      : () => locatePlace(context, ref, p),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'locate') locatePlace(context, ref, p);
                      if (v == 'delete') {
                        ref.read(tripRepositoryProvider).deletePlace(p.id);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'locate',
                          child: Text(hasCoords ? tr('Změnit polohu') : tr('Najít polohu'))),
                      PopupMenuItem(value: 'delete', child: Text(tr('Smazat'))),
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
