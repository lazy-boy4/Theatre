import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/theatre_api.dart';

class DownloadNotifier extends AsyncNotifier<List<DownloadJob>> {
  Timer? _timer;

  @override
  Future<List<DownloadJob>> build() async {
    // Poll every 2 seconds for progress updates
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _refresh());
    ref.onDispose(() => _timer?.cancel());
    return TheatreApi.instance.listDownloads();
  }

  Future<void> _refresh() async {
    final jobs = await AsyncValue.guard(TheatreApi.instance.listDownloads);
    state = jobs;
  }

  Future<String> enqueue(
    ContentRef content,
    ResolvedStream stream,
    String title, {
    String? variant,
  }) async {
    final id = await TheatreApi.instance.enqueueDownload(content, stream, title, variant: variant);
    await _refresh();
    return id;
  }

  Future<void> pause(String id)  async { await TheatreApi.instance.pauseDownload(id);  await _refresh(); }
  Future<void> cancel(String id) async { await TheatreApi.instance.cancelDownload(id); await _refresh(); }
  Future<void> resume(String id) async { await TheatreApi.instance.resumeDownload(id); await _refresh(); }
}

final downloadProvider = AsyncNotifierProvider<DownloadNotifier, List<DownloadJob>>(DownloadNotifier.new);
