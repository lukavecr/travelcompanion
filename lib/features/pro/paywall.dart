import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart' hide Table;
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import 'pro_service.dart';

enum ProLimit { trip, document, expense, backup }

/// Smí uživatel přidat další položku? Když ne, ukáže nabídku Pro.
/// Vrací true, když může pokračovat (je Pro, nebo je pod limitem, nebo si Pro právě koupil).
Future<bool> ensureCanAdd(BuildContext context, AppDatabase db, ProLimit kind) async {
  final pro = ProService.instance;
  if (pro.isPro) return true;
  final (count, limit) = await usageOf(db, kind);
  if (count < limit) return true;
  if (!context.mounted) return false;
  await openPaywall(context, kind);
  return pro.isPro;
}

/// (použito, limit zdarma)
Future<(int, int)> usageOf(AppDatabase db, ProLimit kind) async => switch (kind) {
      ProLimit.trip => (await _activeTrips(db), ProService.freeActiveTrips),
      ProLimit.document => (await _count(db, db.documents), ProService.freeDocuments),
      ProLimit.expense => (await _count(db, db.expenses), ProService.freeExpenses),
      ProLimit.backup => (1, 0),
    };

Future<int> _count(AppDatabase db, TableInfo<Table, dynamic> t) async {
  final rows = await db
      .customSelect('SELECT COUNT(*) AS c FROM ${t.actualTableName} WHERE deleted_at IS NULL')
      .getSingle();
  return rows.read<int>('c');
}

/// Aktivní = ještě neskončila (bez data konce, nebo konec dnes či později).
Future<int> _activeTrips(AppDatabase db) async {
  final today = dayOnly(DateTime.now());
  final trips = await (db.select(db.trips)..where((t) => t.deletedAt.isNull())).get();
  return trips.where((t) => t.endDate == null || !t.endDate!.isBefore(today)).length;
}

Future<void> openPaywall(BuildContext context, [ProLimit? reason]) => Navigator.of(context)
    .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => PaywallScreen(reason: reason)));

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key, this.reason});
  final ProLimit? reason;

  String? get _reasonText => switch (reason) {
        ProLimit.trip =>
          'Ve verzi zdarma můžeš mít ${ProService.freeActiveTrips} aktivní cestu. Proběhlé cesty zůstávají.',
        ProLimit.document => 'Ve verzi zdarma můžeš mít ${ProService.freeDocuments} dokladů.',
        ProLimit.expense => 'Ve verzi zdarma můžeš mít ${ProService.freeExpenses} výdajů.',
        ProLimit.backup => 'Záloha do cloudu a synchronizace mezi telefony jsou součástí Pro.',
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final pro = ProService.instance;
    return ListenableBuilder(
      listenable: pro,
      builder: (context, _) {
        final theme = Theme.of(context);
        if (pro.isPro && reason != null) {
          // právě koupeno → zpět k akci
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
          });
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Travel Companion Pro')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Icon(Icons.workspace_premium, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              if (_reasonText != null) ...[
                Text(_reasonText!, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
              ],
              if (pro.isPro)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: const Text('Máš Pro'),
                    subtitle: Text(pro.isOwner
                        ? 'Účet majitele aplikace – Pro bez předplatného.'
                        : 'Předplatné je aktivní. Děkuji!'),
                  ),
                ),
              const _Benefit(Icons.all_inclusive, 'Neomezeně cest, dokladů a výdajů'),
              const _Benefit(Icons.cloud_done_outlined,
                  'Šifrovaná záloha do cloudu a synchronizace mezi telefony (i Vault)'),
              const _Benefit(Icons.phonelink_setup, 'Nový telefon? Po přihlášení se vše samo stáhne'),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 12, 4, 0),
                child: Text('Zdarma zůstává: plán cest, mapa, Vault, SOS – bez reklam.'),
              ),
              const SizedBox(height: 24),
              if (!pro.isPro) ...[
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  onPressed: pro.busy || pro.product == null ? null : pro.buy,
                  child: pro.busy
                      ? const SizedBox(
                          width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(pro.product == null
                          ? (pro.storeAvailable
                              ? 'Předplatné se načítá…'
                              : 'Google Play teď není dostupný')
                          : 'Předplatit za ${pro.product!.price} / rok'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: pro.busy ? null : pro.restore,
                  child: const Text('Obnovit nákup (už předplácím)'),
                ),
              ],
              if (pro.lastError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(pro.lastError!,
                      style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                ),
              const SizedBox(height: 16),
              Text(
                'Předplatné se každý rok automaticky obnoví, dokud ho nezrušíš. Zrušit ho můžeš '
                'kdykoli v Google Play (Platby a předplatná). Placení i fakturaci zajišťuje Google.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () =>
                    launchUrl(ProService.manageUrl, mode: LaunchMode.externalApplication),
                child: const Text('Spravovat předplatné v Google Play'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(text),
      );
}
