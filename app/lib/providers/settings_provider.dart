import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ffi/bridge.dart';

class SettingsNotifier extends AsyncNotifier<Map<String, String>> {
  static const _keys = [
    'subtitle_language', 'download_root', 'player_speed',
    'player_fill', 'proxy_enabled', 'download_concurrency', 'theme',
  ];

  @override
  Future<Map<String, String>> build() async {
    final m = <String, String>{};
    for (final k in _keys) {
      final v = await theatreGetSetting(key: k);
      if (v != null) m[k] = v;
    }
    return m;
  }

  Future<void> set(String key, String value) async {
    await theatreSetSetting(key: key, value: value);
    state = AsyncValue.data({...?state.value, key: value});
  }
}

/// Human-readable subtitle language names (settings + details share these).
String subtitleLabel(String code) => switch (code) {
      'Auto' => 'Auto',
      'en' => 'English',
      'bn' => 'Bengali (বাংলা)',
      'hi' => 'Hindi (हिन्दी)',
      'ar' => 'Arabic (العربية)',
      'es' => 'Spanish (Español)',
      'fr' => 'French (Français)',
      'de' => 'German (Deutsch)',
      'ja' => 'Japanese (日本語)',
      'ko' => 'Korean (한국어)',
      _ => code,
    };

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map<String, String>>(SettingsNotifier.new);
