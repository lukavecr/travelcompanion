import 'package:flutter/material.dart';

import 'format.dart';

/// Jednoduchý dialog s jedním textovým polem. Vrátí null, když uživatel zruší.
Future<String?> askText(
  BuildContext context, {
  required String title,
  String initial = '',
  String label = 'Název',
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Zrušit'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('Uložit'),
        ),
      ],
    ),
  );
  final text = result?.trim();
  return (text == null || text.isEmpty) ? null : text;
}

Future<bool> confirm(BuildContext context, String question) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(question),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Ne'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Ano'),
        ),
      ],
    ),
  );
  return r ?? false;
}

class EventFormResult {
  const EventFormResult(this.title, this.minutes, this.remindMinutes);
  final String title;
  final int? minutes; // minuty od půlnoci, null = bez času
  final int? remindMinutes; // upozornit X minut předem, null = ne
}

const _leadOptions = [5, 10, 15, 20, 30, 45, 60, 90, 120, 180];

/// Dialog pro položku dne: název + volitelný čas.
Future<EventFormResult?> askEvent(
  BuildContext context, {
  required String heading,
  String title = '',
  int? minutes,
  int? remind,
}) async {
  final controller = TextEditingController(text: title);
  var mins = minutes;
  var lead = remind;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(heading),
        content: SingleChildScrollView(
         child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Název'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(mins == null ? 'Čas (nepovinné)' : fmtTime(mins!)),
                    onPressed: () async {
                      final start = mins ?? 540;
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime:
                            TimeOfDay(hour: start ~/ 60, minute: start % 60),
                      );
                      if (t != null) setState(() => mins = t.hour * 60 + t.minute);
                    },
                  ),
                ),
                if (mins != null)
                  IconButton(
                    tooltip: 'Smazat čas',
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      mins = null;
                      lead = null;
                    }),
                  ),
              ],
            ),
            if (mins != null) ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Upozornit předem'),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 0,
                children: [
                  for (final v in _leadOptions)
                    ChoiceChip(
                      label: Text(fmtLead(v)),
                      selected: lead == v,
                      onSelected: (sel) => setState(() => lead = sel ? v : null),
                    ),
                ],
              ),
            ],
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
  final t = controller.text.trim();
  if (ok != true || t.isEmpty) return null;
  return EventFormResult(t, mins, mins == null ? null : lead);
}
