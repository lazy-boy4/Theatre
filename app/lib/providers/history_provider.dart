import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/theatre_api.dart';

final continueWatchingProvider = FutureProvider<List<HistoryEntry>>(
  (ref) => TheatreApi.instance.continueWatching(limit: 20),
);

final allHistoryProvider = FutureProvider<List<HistoryEntry>>(
  (ref) => TheatreApi.instance.allHistory(limit: 100),
);
