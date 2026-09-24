import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/src/theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        data: (s) => _SettingsBody(settings: s),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(height: TSpace.sm),
              const Text("Couldn't load settings."),
              const SizedBox(height: TSpace.md),
              FilledButton(
                onPressed: () => ref.invalidate(settingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
    final theme = Theme.of(context);

    return ListView(
      children: [
        _sectionHeader(context, 'Playback'),
        ListTile(
          leading: const Icon(Icons.subtitles),
          title: const Text('Subtitle Language'),
          subtitle: const Text('Auto-loads matching subtitles when found'),
          trailing: Text(
            subtitleLabel(settings['subtitle_language'] ?? 'Auto'),
          ),
          onTap: () => _pickFromList(
            context,
            'Subtitle Language',
            'subtitle_language',
            const [
              'Auto',
              'en',
              'bn',
              'hi',
              'ar',
              'es',
              'fr',
              'de',
              'ja',
              'ko',
            ],
            (code) => subtitleLabel(code),
            notifier,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.speed),
          title: const Text('Default Speed'),
          trailing: Text('${settings['player_speed'] ?? '1.0'}x'),
          onTap: () => _pickFromList(
            context,
            'Default Speed',
            'player_speed',
            const ['0.5', '0.75', '1.0', '1.25', '1.5', '2.0'],
            (s) => '${s}x',
            notifier,
          ),
        ),
        _sectionHeader(context, 'Downloads'),
        const ListTile(
          leading: Icon(Icons.folder),
          title: Text('Download Location'),
          subtitle: Text(
            'Custom folders arrive in a coming update — titles save to the app folder for now.',
          ),
          enabled: false,
        ),
        ListTile(
          leading: const Icon(Icons.download_for_offline),
          title: const Text('Max Concurrent Downloads'),
          trailing: Text(settings['download_concurrency'] ?? '2'),
          onTap: () => _pickFromList(
            context,
            'Max Downloads',
            'download_concurrency',
            const ['1', '2', '3', '4'],
            (s) => s,
            notifier,
          ),
        ),
        _sectionHeader(context, 'Network'),
        SwitchListTile(
          secondary: const Icon(Icons.vpn_key),
          title: const Text('Loopback Proxy'),
          subtitle: const Text(
            'Lets external download apps reuse your streams. Stays on this device.',
          ),
          value: (settings['proxy_enabled'] ?? 'true') == 'true',
          onChanged: (v) => notifier.set('proxy_enabled', v ? 'true' : 'false'),
        ),
        _sectionHeader(context, 'Appearance'),
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          trailing: Text(settings['theme'] ?? 'Dark'),
          onTap: () => _pickFromList(
            context,
            'Theme',
            'theme',
            const ['Dark', 'AMOLED', 'Dark Blue'],
            (s) => s,
            notifier,
          ),
        ),
        const SizedBox(height: TSpace.xxxl),
        Center(
          child: Text(
            'Theatre 0.1.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: TSpace.lg),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(
      TSpace.lg,
      TSpace.xl,
      TSpace.lg,
      TSpace.xs,
    ),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    ),
  );

  Future<void> _pickFromList(
    BuildContext context,
    String label,
    String key,
    List<String> options,
    String Function(String) display,
    SettingsNotifier notifier,
  ) async {
    final theme = Theme.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(TSpace.lg),
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in options)
                    ListTile(
                      title: Text(display(o)),
                      onTap: () => Navigator.pop(context, o),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) await notifier.set(key, picked);
  }
}
