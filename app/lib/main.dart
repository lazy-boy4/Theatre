import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'providers/init_provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/library_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: TheatreApp()));
}

class TheatreApp extends ConsumerWidget {
  const TheatreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Init the Rust core on first frame
    ref.watch(initProvider);

    return MaterialApp(
      title: 'Theatre',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: _buildTheme(),
      theme: _buildTheme(),
      home: const AppShell(),
    );
  }

  ThemeData _buildTheme() => ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Colors.red,
      secondary: Color(0xFFE50914),
      surface: Color(0xFF141414),
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
    listTileTheme: const ListTileThemeData(tileColor: Colors.transparent),
    useMaterial3: true,
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    DownloadsScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF141414),
        indicatorColor: Colors.red.withValues(alpha: 0.2),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.download_outlined), selectedIcon: Icon(Icons.download), label: 'Downloads'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Library'),
        ],
      ),
      drawer: _AppDrawer(onHistory: () { setState(() => _index = 0); Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())); },
                        onSettings: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final VoidCallback onHistory;
  final VoidCallback onSettings;
  const _AppDrawer({required this.onHistory, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1a1a1a),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Theatre', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white12),
            ListTile(leading: const Icon(Icons.history, color: Colors.white54), title: const Text('Watch History', style: TextStyle(color: Colors.white)),
                     onTap: () { Navigator.pop(context); onHistory(); }),
            ListTile(leading: const Icon(Icons.settings_outlined, color: Colors.white54), title: const Text('Settings', style: TextStyle(color: Colors.white)),
                     onTap: () { Navigator.pop(context); onSettings(); }),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('v0.1.0', style: TextStyle(color: Colors.white24, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
