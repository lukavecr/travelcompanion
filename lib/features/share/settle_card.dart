import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import 'share_logic.dart';
import 'shared_trips.dart';
import '../../l10n/tr.dart';

/// Peníze ve společné cestě: kdo kolik zaplatil a kdo komu kolik pošle.
class SettleCard extends StatelessWidget {
  const SettleCard({super.key, required this.trip, required this.expenses});
  final Trip trip;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SharedTrips.instance,
      builder: (context, _) {
        final s = SharedTrips.instance;
        final members = s.membersOf(trip.id);
        if (members.length < 2) return const SizedBox.shrink();
        final ids = [for (final m in members) m.uid];
        final owner = members.firstWhere((m) => m.role == 'owner', orElse: () => members.first).uid;
        final list = [
          for (final e in expenses)
            if (e.amountMain != null)
              SplitExpense(
                amount: e.amountMain!,
                paidBy: e.paidBy ?? owner, // výdaje z doby před sdílením platil zakladatel
                splitWith: e.splitWith == null
                    ? null
                    : [for (final x in jsonDecode(e.splitWith!) as List) x as String],
              )
        ];
        final paid = {for (final id in ids) id: 0.0};
        for (final e in list) {
          paid[e.paidBy] = (paid[e.paidBy] ?? 0) + e.amount;
        }
        final transfers = settle(balances(list, ids));
        final me = SharedTrips.myUid;
        final cur = trip.mainCurrency;
        String name(String uid) => uid == me ? tr('ty') : s.nameOf(trip.id, uid);
        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.group, size: 20),
                  const SizedBox(width: 8),
                  Text(tr('Kdo kolik zaplatil'), style: theme.textTheme.titleSmall),
                ]),
                const SizedBox(height: 8),
                for (final m in members)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [
                      Expanded(child: Text(m.uid == me ? tr('{name} (ty)', {'name': m.name}) : m.name)),
                      Text('${fmtMoney(paid[m.uid] ?? 0)} $cur'),
                    ]),
                  ),
                const Divider(height: 20),
                Text(tr('Vyrovnání'), style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                if (transfers.isEmpty)
                  Text(tr('Všichni jsou vyrovnaní.'))
                else
                  for (final t in transfers)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        Expanded(child: Text('${name(t.from)} → ${name(t.to)}')),
                        Text('${fmtMoney(t.amount)} $cur',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: t.from == me ? theme.colorScheme.error : null)),
                      ]),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
