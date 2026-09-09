import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// TODO(T1.1): import generated FFI bindings
// import 'bridge/bridge_generated.dart';

/// Initialise theatre-core before runApp.
Future<void> bootstrapCore() async {
  final dir = await getApplicationSupportDirectory();
  // TODO(T1.1): call theatreInit(InitConfig(dataDir: dir.path, ...))
  debugPrint('Theatre core bootstrap — data dir: ${dir.path}');
}
