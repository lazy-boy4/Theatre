import 'package:flutter/material.dart';

// Adaptive navigation shell — PRD F4, architecture §14.
// NavigationBar (compact) → NavigationRail (medium) → NavigationDrawer (expanded)
// TODO(T0.4): implement with go_router ShellRoute + LayoutBuilder.

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return _CompactShell(child: child);
    } else if (width < 1200) {
      return _MediumShell(child: child);
    } else {
      return _ExpandedShell(child: child);
    }
  }
}

class _CompactShell extends StatelessWidget {
  const _CompactShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.download), label: 'Downloads'),
        NavigationDestination(icon: Icon(Icons.folder), label: 'Library'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onDestinationSelected: (_) {},
      selectedIndex: 0,
    ),
  );
}

class _MediumShell extends StatelessWidget {
  const _MediumShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Row(
      children: [
        NavigationRail(
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.search), label: Text('Search')),
            NavigationRailDestination(icon: Icon(Icons.download), label: Text('Downloads')),
            NavigationRailDestination(icon: Icon(Icons.folder), label: Text('Library')),
            NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
          ],
          onDestinationSelected: (_) {},
          selectedIndex: 0,
        ),
        Expanded(child: child),
      ],
    ),
  );
}

class _ExpandedShell extends StatelessWidget {
  const _ExpandedShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Row(
      children: [
        NavigationDrawer(
          children: const [
            NavigationDrawerDestination(icon: Icon(Icons.search), label: Text('Search')),
            NavigationDrawerDestination(icon: Icon(Icons.download), label: Text('Downloads')),
            NavigationDrawerDestination(icon: Icon(Icons.folder), label: Text('Library')),
            NavigationDrawerDestination(icon: Icon(Icons.settings), label: Text('Settings')),
          ],
          onDestinationSelected: (_) {},
        ),
        Expanded(child: child),
      ],
    ),
  );
}
