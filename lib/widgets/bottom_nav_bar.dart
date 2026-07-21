import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (int index) {
        navigationShell.goBranch(
          index,
          // Support tapping the active tab to return to the root of that stack
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      backgroundColor: AppTheme.surfaceContainerLow,
      indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 70,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: AppTheme.primary),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics, color: AppTheme.primary),
          label: 'Analytics',
        ),
        NavigationDestination(
          // Center item slightly larger
          icon: Icon(Icons.auto_graph_outlined, size: 26),
          selectedIcon: Icon(Icons.auto_graph, size: 28, color: AppTheme.primary),
          label: 'Predict',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications, color: AppTheme.primary),
          label: 'Alerts',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppTheme.primary),
          label: 'Profile',
        ),
      ],
    );
  }
}
