import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ffi/bridge.dart';

final detailProvider = FutureProviderFamily<Details, ContentRef>(
  (ref, content) => theatreGetDetails(content: content),
);

final resolveProvider = FutureProviderFamily<ResolvedStream, (ContentRef, String?)>(
  (ref, args) => theatreResolve(content: args.$1, variant: args.$2),
);

/// Enabled sources with health, for the Details source row (PRD F1/F8).
final sourcesProvider = FutureProvider<List<SourceInfo>>(
  (ref) => theatreListSources(),
);
