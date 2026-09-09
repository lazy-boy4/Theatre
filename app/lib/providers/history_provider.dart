import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ffi/bridge.dart';

final continueWatchingProvider = FutureProvider<List<HistoryEntry>>(
  (ref) => theatreContinueWatching(limit: 20),
);

final allHistoryProvider = FutureProvider<List<HistoryEntry>>(
  (ref) => theatreAllHistory(limit: 100),
);
