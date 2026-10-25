import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/secure_screen.dart';
import '../../l10n/tr.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    // záložky Doklady a Vault (včetně detailů a SOS) chráněné před snímky obrazovky
    return SecureScreen(
      enabled: shell.currentIndex == 2 || shell.currentIndex == 4,
      child: Scaffold(
        body: shell,
        // navigace dole = dosažitelná jednou rukou
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.flight_takeoff),
              label: tr('Cesty'),
            ),
            NavigationDestination(icon: Icon(Icons.map), label: tr('Mapa')),
            NavigationDestination(
              icon: Icon(Icons.confirmation_number),
              label: tr('Doklady'),
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet),
              label: tr('Peníze'),
            ),
            NavigationDestination(icon: Icon(Icons.lock), label: tr('Vault')),
          ],
        ),
      ),
    );
  }
}
