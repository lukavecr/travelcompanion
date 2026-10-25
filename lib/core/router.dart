import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_settings.dart';
import '../features/auth/auth_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/ai_plan/ai_plan_screen.dart';
import '../features/documents/docs_list_screen.dart';
import '../features/documents/email_import_screen.dart';
import '../features/share/share_screen.dart';
import '../features/tracks/tracks_screen.dart';
import '../features/documents/document_detail_screen.dart';
import '../features/documents/new_document_screen.dart';
import '../features/documents/document_repository.dart' show DocView;
import '../features/documents/scan_service.dart';
import '../features/map/map_screen.dart';
import '../features/money/expense_form_screen.dart';
import '../features/money/money_screen.dart';
import '../features/places/places_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/share_intake/share_place_screen.dart';
import '../features/sync/sync_screen.dart';
import '../features/shell/shell_scaffold.dart';
import '../features/trips/trip_detail_screen.dart';
import '../features/trips/trips_list_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/vault/vault_screen.dart';
import '../demo/demo_mode.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);


  return GoRouter(
    initialLocation: '/${AppSettings.instance.startTab}',
    redirect: (context, state) {
      // odkaz z widgetu (kdyby ho systém předal routeru) → úvodní záložka
      if (state.uri.scheme == 'travelcompanion') return '/${AppSettings.instance.startTab}';
      if (auth.isLoading) return null;
      final loggedIn = kDemo || auth.value != null;
      final atLogin = state.matchedLocation == '/login';
      final atWelcome = state.matchedLocation == '/welcome';
      if (!loggedIn) {
        if (!AppSettings.instance.onboardingDone) return atWelcome ? null : '/welcome';
        return atLogin ? null : '/login';
      }
      if (atWelcome) return '/${AppSettings.instance.startTab}';
      if (atLogin) return '/${AppSettings.instance.startTab}';
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/sync', builder: (context, state) => const SyncScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
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
                  path: 'ai',
                  builder: (context, state) => switch (state.extra) {
                    (String text, String? name) => AiPlanScreen(answer: text, fileName: name),
                    final String text => AiPlanScreen(answer: text),
                    _ => const AiPlanScreen(),
                  },
                ),
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
                    GoRoute(
                      path: 'share',
                      builder: (context, state) =>
                          ShareTripScreen(tripId: state.pathParameters['id']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
              routes: [
                GoRoute(
                  path: 'tracks',
                  builder: (context, state) => const TracksScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) =>
                          TrackDetailScreen(trackId: state.pathParameters['id']!),
                    ),
                  ],
                ),
              ],
            ),
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
                  path: 'import',
                  builder: (context, state) =>
                      EmailImportScreen(text: (state.extra as String?) ?? ''),
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
          StatefulShellBranch(routes: [
            GoRoute(path: '/vault', builder: (context, state) => const VaultScreen()),
          ]),
        ],
      ),
    ],
  );
});
