import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_settings.dart';
import '../../l10n/tr.dart';

class _Page {
  const _Page(this.icon, this.title, this.text);
  final IconData icon;
  final String title;
  final String text;
}

/// Úvodní průvodce při prvním spuštění (před přihlášením). 3 obrazovky, jde přeskočit.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pc = PageController();
  int _page = 0;

  List<_Page> get _pages => [
        _Page(Icons.event_note, tr('Celá cesta v jedné kapse'),
            tr('Plán po dnech, ubytování, časy a upozornění. Funguje i bez signálu – data jsou v telefonu.')),
        _Page(Icons.qr_code_scanner, tr('Vyfoť lístek, zbytek udělám já'),
            tr('Palubní lístek, jízdenku nebo účtenku jen vyfotíš. Kód i údaje se přečtou přímo v telefonu a výdaje se přepočtou na tvou měnu.')),
        _Page(Icons.shield_outlined, tr('Pas jen pro tvé oči'),
            tr('Vault šifruje pas, víza a pojištění. SOS pošle tvou polohu blízkým a ukáže tísňová čísla země, kde právě jsi.')),
      ];

  Future<void> _finish() async {
    await AppSettings.instance.setOnboardingDone(true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final last = _page == pages.length - 1;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finish, child: Text(tr('Přeskočit'))),
            ),
            Expanded(
              child: PageView(
                controller: _pc,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final p in pages)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(p.icon, size: 60, color: cs.onPrimaryContainer),
                          ),
                          const SizedBox(height: 32),
                          Text(p.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          Text(p.text,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: last
                    ? _finish
                    : () => _pc.nextPage(
                        duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                child: Text(last ? tr('Začít') : tr('Další')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
