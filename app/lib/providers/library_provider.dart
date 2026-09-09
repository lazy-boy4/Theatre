import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ffi/bridge.dart';

final libraryLocationsProvider = FutureProvider<List<LibraryLocation>>(
  (ref) => theatreListLocations(),
);

final browseFolderProvider = FutureProviderFamily<List<MediaEntry>, String>(
  (ref, path) => theatreBrowseFolder(path: path),
);
