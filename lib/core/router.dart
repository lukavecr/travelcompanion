import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/documents/docs_list_screen.dart';
import '../features/documents/document_detail_screen.dart';
import '../features/documents/new_document_screen.dart';
import '../features/documents/document_repository.dart' show DocView;
import '../features/documents/scan_service.dart';
import '../features/map/map_screen.dart';
import '../features/money/expense_form_screen.dart';
import '../features/money/money_screen.dart';
import '../features/places/places_screen.dart';
import '../features/share_intake/share_place_screen.dart';
import '../features/shell/placeholder_screen.dart';
import '../features/sync/sync_screen.dart';
import '../features/shell/shell_scaffold.dart';
import '../features/trips/trip_detail_screen.dart';
import '../features/trips/trips_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  GoRoute tab(String path, String title, IconData icon) => GoRoute(
        path: path,
        builder: (context, state) => PlaceholderScreen(title: title, icon: icon),
      );

  return GoRouter(
    initialLocation: '/trips',
    redirect: (context, state) {
      if (auth.isLoading) return null;
      final loggedIn = auth.value != null;
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn) return atLogin ? null : '/login';
      if (atLogin) return '/trips';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/sync', builder: (context, state) => const SyncScreen()),
      GoRoute(
        path: '/share',
        builder: (context, state) =>
            SharePlaceScreen(text: (state.extra as String?) ?? ''),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/trips',
              builder: (context, state) => const TripsListScreen(),
              routes: [
                GoRoute(
                  path: 'trip/:id',
                  builder: (context, state) =>
                      TripDetailScreen(tripId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'places',
                      builder: (context, state) =>
                          PlacesScreen(tripId: state.pathParameters['id']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/docs',
              builder: (context, state) => const DocsListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) =>
                      NewDocumentScreen(scan: state.extra as ScanResult),
                ),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) =>
                      NewDocumentScreen(existing: state.extra as DocView),
                ),
                GoRoute(
                  path: 'doc/:id',
                  builder: (context, state) => DocumentDetailScreen(
                      docId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/money',
              builder: (context, state) => const MoneyScreen(),
              routes: [
                GoRoute(
                  path: 'form',
                  builder: (context, state) => ExpenseFormScreen(
                      args: state.extra as ExpenseFormArgs),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [tab('/vault', 'Vault', Icons.lock)]),
        ],
      ),
    ],
  );
});
