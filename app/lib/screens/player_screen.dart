import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../api/theatre_api.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final ResolvedStream stream;
  final String title;
  final ContentRef content;
  const PlayerScreen({super.key, required this.stream, required this.title, required this.content});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _player = Player();
    _controller = VideoController(_player);

    // Build Media with auth headers
    final httpHeaders = Map<String, String>.from(widget.stream.headers);
    _player.open(Media(widget.stream.url, httpHeaders: httpHeaders));

    // Auto-hide controls
    _scheduleHideControls();

    // Progress persistence
    _player.stream.position.listen((pos) {
      if (pos.inSeconds > 0 && pos.inSeconds % 10 == 0) _saveProgress(pos.inSeconds);
    });
  }

  void _scheduleHideControls() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _saveProgress(int seconds) {
    TheatreApi.instance.recordPlayback(HistoryEntry(
      id: '${widget.content.source}-${widget.content.contentId}',
      sourceId: widget.content.source,
      contentId: widget.content.contentId,
      title: widget.title,
      positionSeconds: seconds,
      lastWatched: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ));
  }

  @override
  void dispose() {
    _saveProgress(_player.state.position.inSeconds);
    _player.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() => _controlsVisible = !_controlsVisible);
          if (_controlsVisible) _scheduleHideControls();
        },
        child: Stack(
          children: [
            Center(
              child: Video(
                controller: _controller,
                controls: NoVideoControls,
              ),
            ),
            AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _OverlayControls(player: _player, title: widget.title, stream: widget.stream),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayControls extends StatefulWidget {
  final Player player;
  final String title;
  final ResolvedStream stream;
  const _OverlayControls({required this.player, required this.title, required this.stream});

  @override
  State<_OverlayControls> createState() => _OverlayControlsState();
}

class _OverlayControlsState extends State<_OverlayControls> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent, Colors.transparent, Colors.black54],
          stops: [0, 0.25, 0.75, 1],
        ),
      ),
      child: Column(
        children: [
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis)),
                  // Variant selector
                  if (widget.stream.variants.isNotEmpty)
                    _VariantButton(player: widget.player, stream: widget.stream),
                  // Speed
                  _SpeedButton(player: widget.player),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Center play/pause
          StreamBuilder(
            stream: widget.player.stream.playing,
            builder: (_, snap) => IconButton(
              iconSize: 64,
              icon: Icon(snap.data == true ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 64),
              onPressed: widget.player.playOrPause,
            ),
          ),
          const Spacer(),
          // Bottom seek bar + skip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                StreamBuilder<Duration>(
                  stream: widget.player.stream.position,
                  builder: (_, posSnap) => StreamBuilder<Duration>(
                    stream: widget.player.stream.duration,
                    builder: (_, durSnap) {
                      final pos = posSnap.data ?? Duration.zero;
                      final dur = durSnap.data ?? Duration.zero;
                      return Column(
                        children: [
                          Slider(
                            value: dur.inSeconds > 0 ? pos.inSeconds / dur.inSeconds : 0,
                            onChanged: (v) => widget.player.seek(Duration(seconds: (v * dur.inSeconds).round())),
                            activeColor: Colors.red,
                            inactiveColor: Colors.white30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_fmt(pos), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(_fmt(dur), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.replay_10, color: Colors.white), onPressed: () async {
                      final pos = widget.player.state.position;
                      await widget.player.seek(Duration(seconds: (pos.inSeconds - 10).clamp(0, 999999)));
                    }),
                    const SizedBox(width: 24),
                    IconButton(icon: const Icon(Icons.forward_30, color: Colors.white), onPressed: () async {
                      final pos = widget.player.state.position;
                      await widget.player.seek(Duration(seconds: pos.inSeconds + 30));
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
                 : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _SpeedButton extends StatefulWidget {
  final Player player;
  const _SpeedButton({required this.player});
  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton> {
  final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double current = 1.0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final val = await showMenu<double>(
          context: context,
          position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width - 80, 60, 0, 0),
          items: speeds.map((s) => PopupMenuItem(value: s, child: Text('${s}x', style: const TextStyle(color: Colors.white)))).toList(),
          color: Colors.grey[900],
        );
        if (val != null) {
          await widget.player.setRate(val);
          setState(() => current = val);
        }
      },
      child: Text('${current}x', style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class _VariantButton extends StatelessWidget {
  final Player player;
  final ResolvedStream stream;
  const _VariantButton({required this.player, required this.stream});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.hd, color: Colors.white),
      onPressed: () async {
        final selected = await showModalBottomSheet<Variant>(
          context: context,
          backgroundColor: Colors.grey[900],
          builder: (_) => _VariantSheet(variants: stream.variants, selected: stream.selectedVariant),
        );
        if (selected == null) return;
        // Re-resolve with variant — caller handles this at the detail screen level
      },
    );
  }
}

class _VariantSheet extends StatelessWidget {
  final List<Variant> variants;
  final String? selected;
  const _VariantSheet({required this.variants, this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Quality', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...variants.map((v) => ListTile(
            title: Text(v.label, style: const TextStyle(color: Colors.white)),
            subtitle: v.bitrateKbps != null ? Text('${v.bitrateKbps} kbps', style: const TextStyle(color: Colors.white54)) : null,
            trailing: v.id == selected ? const Icon(Icons.check, color: Colors.red) : null,
            onTap: () => Navigator.pop(context, v),
          )),
        ],
      ),
    );
  }
}
