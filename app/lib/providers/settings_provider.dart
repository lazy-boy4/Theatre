import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/theatre_api.dart';

class SettingsNotifier extends AsyncNotifier<Map<String, String>> {
  static const _keys = [
    'subtitle_language', 'download_root', 'player_speed',
    'player_fill', 'proxy_enabled', 'download_concurrency', 'theme',
  ];

  @override
  Future<Map<String, String>> build() async {
    final m = <String, String>{};
    for (final k in _keys) {
      final v = await TheatreApi.instance.getSetting(k);
      if (v != null) m[k] = v;
    }
    return m;
  }

  Future<void> set(String key, String value) async {
    await TheatreApi.instance.setSetting(key, value);
    state = AsyncValue.data({...?state.value, key: value});
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map<String, String>>(SettingsNotifier.new);
