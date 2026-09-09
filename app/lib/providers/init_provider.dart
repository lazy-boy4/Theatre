import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../ffi/bridge.dart';

final initProvider = FutureProvider<InitResult>((ref) async {
  final dir = await getApplicationSupportDirectory();
  final config = InitConfig(
    dataDir: dir.path,
    appVersion: '0.1.0',
    proxyEnabled: true,
  );
  return theatreInit(config);
});
