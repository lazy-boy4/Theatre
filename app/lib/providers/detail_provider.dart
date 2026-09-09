import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/theatre_api.dart';

final detailProvider = FutureProviderFamily<Details, ContentRef>(
  (ref, content) => TheatreApi.instance.getDetails(content),
);

final resolveProvider = FutureProviderFamily<ResolvedStream, (ContentRef, String?)>(
  (ref, args) => TheatreApi.instance.resolve(args.$1, variant: args.$2),
);
