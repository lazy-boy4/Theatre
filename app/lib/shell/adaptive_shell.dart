import 'package:flutter/material.dart';

// Adaptive navigation shell — PRD F4, architecture §14.
// NavigationBar (compact <600dp) → NavigationRail (medium <1200dp) →
// NavigationDrawer (expanded). Structure is driven by window size class,
// never by device-model checks. One shell; every destination stays
// reachable in every class (adapt.native: never hide core functionality
// on smaller devices).

/// Shared destinations so Bar, Rail, and Drawer can never drift apart.
const theatreDestinations = [
  (Icons.home_outlined, Icons.home, 'Home'),
  (Icons.search_outlined, Icons.search, 'Search'),
  (Icons.download_outlined, Icons.download, 'Downloads'),
  (Icons.folder_outlined, Icons.folder, 'Library'),
  (Icons.history_outlined, Icons.history, 'History'),
];

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.children,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return _CompactShell(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        children: children,
      );
    } else if (width < 1200) {
      return _MediumShell(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        children: children,
      );
    } else {
      return _ExpandedShell(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        children: children,
      );
    }
  }
}

List<NavigationDestination> _barDestinations() => [
      for (final d in theatreDestinations)
        NavigationDestination(
          icon: Icon(d.$1),
          selectedIcon: Icon(d.$2),
          label: d.$3,
        ),
    ];

List<NavigationRailDestination> _railDestinations() => [
      for (final d in theatreDestinations)
        NavigationRailDestination(
          icon: Icon(d.$1),
          selectedIcon: Icon(d.$2),
          label: Text(d.$3),
        ),
    ];

List<NavigationDrawerDestination> _drawerDestinations() => [
      for (final d in theatreDestinations)
        NavigationDrawerDestination(
          icon: Icon(d.$1),
          selectedIcon: Icon(d.$2),
          label: Text(d.$3),
        ),
    ];

class _CompactShell extends StatelessWidget {
  const _CompactShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.children,
  });
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          top: false,
          child: IndexedStack(index: selectedIndex, children: children),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: _barDestinations(),
          onDestinationSelected: onDestinationSelected,
          selectedIndex: selectedIndex,
        ),
      );
}

class _MediumShell extends StatelessWidget {
  const _MediumShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.children,
  });
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                groupAlignment: 0,
                labelType: NavigationRailLabelType.all,
                destinations: _railDestinations(),
                onDestinationSelected: onDestinationSelected,
                selectedIndex: selectedIndex,
              ),
              Expanded(
                child: IndexedStack(index: selectedIndex, children: children),
              ),
            ],
          ),
        ),
      );
}

class _ExpandedShell extends StatelessWidget {
  const _ExpandedShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.children,
  });
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationDrawer(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
                    child: Text('Theatre'),
                  ),
                  ..._drawerDestinations(),
                ],
              ),
              Expanded(
                child: IndexedStack(index: selectedIndex, children: children),
              ),
            ],
          ),
        ),
      );
}
