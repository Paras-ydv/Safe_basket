import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/chemical/presentation/chemical_alternatives_screen.dart';
import '../../features/chemical/presentation/chemical_detail_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/scan/domain/scan_mode.dart';
import '../../features/scan/presentation/manual_entry_screen.dart';
import '../../features/scan/presentation/scan_options_screen.dart';
import '../../features/scan/presentation/scan_result_screen.dart';
import '../../features/scan/presentation/scanning_screen.dart';
import '../../features/scan/presentation/water_check_screen.dart';
import 'route_names.dart';

/// App router. Uses a [StatefulShellRoute] so the bottom-nav tabs keep their
/// own navigation state (indexed stack). The shell owns the
/// [BottomNavigationBar]; individual tab screens do not.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: RouteNames.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: RouteNames.history,
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/water',
              name: RouteNames.water,
              builder: (context, state) => const WaterCheckScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/learn',
              name: RouteNames.learn,
              builder: (context, state) => const LearnScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: RouteNames.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Temporary placeholder for the "Start Scanning" CTA target. Replaced when
    // the scan feature. Lives outside the shell (full-screen flow).
    GoRoute(
      path: '/scan',
      name: RouteNames.scan,
      builder: (context, state) => const ScanOptionsScreen(),
      routes: [
        // Capture modalities — screens not built yet, placeholders for now.
        GoRoute(
          path: 'barcode',
          name: RouteNames.scanBarcode,
          builder: (context, state) =>
              const ScanningScreen(mode: ScanMode.barcode),
        ),
        GoRoute(
          path: 'label',
          name: RouteNames.scanLabel,
          builder: (context, state) =>
              const ScanningScreen(mode: ScanMode.label),
        ),
        GoRoute(
          path: 'manual',
          name: RouteNames.scanManual,
          builder: (context, state) => const ManualEntryScreen(),
        ),
        GoRoute(
          path: 'water',
          name: RouteNames.scanWater,
          builder: (context, state) => const WaterCheckScreen(),
        ),
        // Result screen (§5.4).
        GoRoute(
          path: 'result/:scanId',
          name: RouteNames.scanResult,
          builder: (context, state) =>
              ScanResultScreen(scanId: state.pathParameters['scanId']!),
        ),
      ],
    ),
    // In-app notification inbox (§2).
    GoRoute(
      path: '/notifications',
      name: RouteNames.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    // Chemical Details (§5.5).
    GoRoute(
      path: '/chemical/:id',
      name: RouteNames.chemicalDetail,
      builder: (context, state) =>
          ChemicalDetailScreen(id: state.pathParameters['id']!),
      routes: [
        // Safer alternatives (§3).
        GoRoute(
          path: 'alternatives',
          name: RouteNames.chemicalAlternatives,
          builder: (context, state) =>
              ChemicalAlternativesScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);

/// Scaffold hosting the bottom navigation shared across the tab branches.
class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab returns it to its initial route.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            label: 'Water',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
