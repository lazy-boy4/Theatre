import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/theatre_api.dart';

final libraryLocationsProvider = FutureProvider<List<LibraryLocation>>(
  (ref) => TheatreApi.instance.listLocations(),
);

final browseFolderProvider = FutureProviderFamily<List<MediaEntry>, String>(
  (ref, path) => TheatreApi.instance.browseFolder(path),
);
