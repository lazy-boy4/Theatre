import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: settings.when(
        data: (s) => _SettingsBody(settings: s),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white70))),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final Map<String, String> settings;
  const _SettingsBody({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      children: [
        _sectionHeader('Playback'),
        ListTile(
          leading: const Icon(Icons.subtitles, color: Colors.white54),
          title: const Text('Subtitle Language', style: TextStyle(color: Colors.white)),
          trailing: Text(settings['subtitle_language'] ?? 'Auto', style: const TextStyle(color: Colors.white38)),
          onTap: () => _pickFromList(context, 'Subtitle Language', 'subtitle_language',
              ['Auto', 'en', 'bn', 'hi', 'ar', 'es', 'fr', 'de', 'ja', 'ko'], notifier),
        ),
        ListTile(
          leading: const Icon(Icons.speed, color: Colors.white54),
          title: const Text('Default Speed', style: TextStyle(color: Colors.white)),
          trailing: Text('${settings['player_speed'] ?? '1.0'}x', style: const TextStyle(color: Colors.white38)),
          onTap: () => _pickFromList(context, 'Default Speed', 'player_speed',
              ['0.5', '0.75', '1.0', '1.25', '1.5', '2.0'], notifier),
        ),
        _sectionHeader('Downloads'),
        ListTile(
          leading: const Icon(Icons.folder, color: Colors.white54),
          title: const Text('Download Location', style: TextStyle(color: Colors.white)),
          subtitle: Text(settings['download_root'] ?? 'Default', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          onTap: () {/* TODO: folder picker */},
        ),
        ListTile(
          leading: const Icon(Icons.download_for_offline, color: Colors.white54),
          title: const Text('Max Concurrent Downloads', style: TextStyle(color: Colors.white)),
          trailing: Text(settings['download_concurrency'] ?? '2', style: const TextStyle(color: Colors.white38)),
          onTap: () => _pickFromList(context, 'Max Downloads', 'download_concurrency', ['1', '2', '3', '4'], notifier),
        ),
        _sectionHeader('Network'),
        SwitchListTile(
          secondary: const Icon(Icons.vpn_key, color: Colors.white54),
          title: const Text('Loopback Proxy', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Required for HLS streams with auth headers', style: TextStyle(color: Colors.white38, fontSize: 11)),
          value: (settings['proxy_enabled'] ?? 'true') == 'true',
          onChanged: (v) => notifier.set('proxy_enabled', v ? 'true' : 'false'),
          activeThumbColor: Colors.red,
        ),
        _sectionHeader('Appearance'),
        ListTile(
          leading: const Icon(Icons.palette, color: Colors.white54),
          title: const Text('Theme', style: TextStyle(color: Colors.white)),
          trailing: Text(settings['theme'] ?? 'Dark', style: const TextStyle(color: Colors.white38)),
          onTap: () => _pickFromList(context, 'Theme', 'theme', ['Dark', 'AMOLED', 'Dark Blue'], notifier),
        ),
        const SizedBox(height: 32),
        const Center(child: Text('Theatre 0.1.0', style: TextStyle(color: Colors.white24, fontSize: 12))),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
  );

  Future<void> _pickFromList(
    BuildContext context,
    String label,
    String key,
    List<String> options,
    SettingsNotifier notifier,
  ) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            ...options.map((o) => ListTile(
              title: Text(o, style: const TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, o),
            )),
          ],
        ),
      ),
    );
    if (picked != null) await notifier.set(key, picked);
  }
}
