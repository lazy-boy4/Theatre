import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ffi/bridge.dart';
import '../providers/detail_provider.dart';
import '../screens/player_screen.dart';

// Shared resolve-and-play path (PRD §8: resolve-on-play, never resolve-on-search).
// Home continue cards, history tiles, and episode rows all route through here
// so loading, error copy, and recovery stay identical everywhere.

Future<void> playContent(
  BuildContext context,
  WidgetRef ref, {
  required ContentRef content,
  required String title,
  String? variant,
  String? posterUrl,
  int? durationSeconds,
}) async {
  // Local files need no resolving — play the path directly.
  if (content.source == 'local') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          stream: ResolvedStream(
            url: 'file://${content.contentId}',
            kind: StreamKind.direct,
          ),
          title: title,
          content: content,
          posterUrl: posterUrl,
          durationSeconds: durationSeconds,
        ),
      ),
    );
    return;
  }
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  late final ResolvedStream stream;
  try {
    stream = await ref.read(resolveProvider((content, variant)).future);
  } catch (_) {
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Couldn't load this title. Check your connection, or try another source from Details.",
        ),
      ),
    );
    return;
  }
  if (!context.mounted) return;
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PlayerScreen(
        stream: stream,
        title: title,
        content: content,
        posterUrl: posterUrl,
        durationSeconds: durationSeconds,
        initialVariant: variant,
      ),
    ),
  );
}
