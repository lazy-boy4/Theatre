import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'design/tokens.dart';
import 'providers/init_provider.dart';
import 'shell/adaptive_shell.dart';
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
      darkTheme: theatreTheme(brightness: Brightness.dark),
      theme: theatreTheme(brightness: Brightness.dark),
      home: const AppShell(),
    );
  }
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
    SearchScreen(isTab: true),
    DownloadsScreen(),
    LibraryScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveShell(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        children: _screens,
      ),
      drawer: _AppDrawer(
        onSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final VoidCallback onSettings;
  const _AppDrawer({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Theatre',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                onSettings();
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v0.1.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
