import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      // navigace dole = dosažitelná jednou rukou
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.flight_takeoff), label: 'Cesty'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(
              icon: Icon(Icons.confirmation_number), label: 'Doklady'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet), label: 'Peníze'),
          NavigationDestination(icon: Icon(Icons.lock), label: 'Vault'),
        ],
      ),
    );
  }
}
