import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../design/src/theme.dart';
import '../ffi/bridge.dart';

/// Player states (harden): every failure in this category is expected
/// (expiring links, 403s), so error is a first-class state with recovery —
/// never a black rectangle.
enum _PlayerStatus { loading, ready, error }

class PlayerScreen extends ConsumerStatefulWidget {
  final ResolvedStream stream;
  final String title;
  final ContentRef content;
  final String? posterUrl;
  final int? durationSeconds;
  final String? initialVariant;
  const PlayerScreen({
    super.key,
    required this.stream,
    required this.title,
    required this.content,
    this.posterUrl,
    this.durationSeconds,
    this.initialVariant,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  final _subs = <StreamSubscription>[];
  bool _controlsVisible = true;
  Timer? _hideTimer;
  _PlayerStatus _status = _PlayerStatus.loading;
  String? _variant;

  @override
  void initState() {
    super.initState();
    _variant = widget.initialVariant ?? widget.stream.selectedVariant;
    WakelockPlus.enable();
    // No orientation lock: handheld users get landscape by rotating;
    // desktop windows must never be yanked (adapt.native).
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _player = Player();
    _controller = VideoController(_player);

    _subs.add(
      _player.stream.playing.listen((playing) {
        if (playing && mounted && _status == _PlayerStatus.loading) {
          setState(() => _status = _PlayerStatus.ready);
        }
      }),
    );
    _subs.add(
      _player.stream.error.listen((message) {
        if (mounted) setState(() => _status = _PlayerStatus.error);
      }),
    );

    _open(widget.stream.url, widget.stream.headers);
    _scheduleHideControls();

    _player.stream.position.listen((pos) {
      if (pos.inSeconds > 0 && pos.inSeconds % 10 == 0) {
        _saveProgress(pos.inSeconds);
      }
    });
  }

  Future<void> _open(String url, Map<String, String> headers) async {
    setState(() => _status = _PlayerStatus.loading);
    try {
      await _player.open(Media(url, httpHeaders: Map.of(headers)));
    } catch (_) {
      if (mounted) setState(() => _status = _PlayerStatus.error);
    }
  }

  /// Transparent re-resolve, then retry (PRD §8: auto re-resolve once
  /// before surfacing an error — the UI half of that contract).
  Future<void> _refreshLink() async {
    late final ResolvedStream fresh;
    try {
      // Force a new upstream link, bypassing the short cache.
      fresh = await theatreResolve(
        content: widget.content,
        variant: _variant,
        forceRefresh: true,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't get a fresh link. Check your connection and try again.",
            ),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    await _open(fresh.url, fresh.headers);
  }

  Future<void> _changeVariant(String? variantId) async {
    _variant = variantId;
    await _refreshLink();
  }

  void _scheduleHideControls() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _status == _PlayerStatus.ready) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _saveProgress(int seconds) {
    theatreRecordPlayback(
      entry: HistoryEntry(
        id: '${widget.content.source}-${widget.content.contentId}',
        sourceId: widget.content.source,
        contentId: widget.content.contentId,
        title: widget.title,
        posterUrl: widget.posterUrl,
        positionSeconds: seconds,
        durationSeconds: widget.durationSeconds,
        lastWatched: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
    );
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _hideTimer?.cancel();
    _saveProgress(_player.state.position.inSeconds);
    _player.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              child: Video(controller: _controller, controls: NoVideoControls),
            ),
            if (_status == _PlayerStatus.loading)
              const Center(child: CircularProgressIndicator()),
            if (_status == _PlayerStatus.error)
              _ErrorPanel(
                onRetry: () => _open(
                  widget.stream.url,
                  widget.stream.headers,
                ),
                onRefreshLink: _refreshLink,
                onBackToDetails: () => Navigator.pop(context),
              ),
            if (_status == _PlayerStatus.ready)
              AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _OverlayControls(
                  player: _player,
                  title: widget.title,
                  stream: widget.stream,
                  currentVariant: _variant,
                  onVariantChanged: _changeVariant,
                ),
              ),
            // Keep the scrim readable while loading, without blocking retry.
            if (_status != _PlayerStatus.ready)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Row(
                    children: [
                      const BackButton(color: Colors.white),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Recovery for the expected failure: expired/signed links, 403s, offline.
/// Names the problem, offers the next step, preserves the user's place.
class _ErrorPanel extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onRefreshLink;
  final VoidCallback onBackToDetails;
  const _ErrorPanel({
    required this.onRetry,
    required this.onRefreshLink,
    required this.onBackToDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(TSpace.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                color: theme.colorScheme.onSurface,
                size: 48,
              ),
              const SizedBox(height: TSpace.lg),
              Text(
                'This stream stopped working',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSpace.sm),
              Text(
                'Links from community sources expire. Refreshing usually fixes it — your place is saved.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSpace.xxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Get a fresh link'),
                  onPressed: onRefreshLink,
                ),
              ),
              const SizedBox(height: TSpace.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  ),
                  const SizedBox(width: TSpace.sm),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onBackToDetails,
                      child: const Text('Details'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayControls extends StatefulWidget {
  final Player player;
  final String title;
  final ResolvedStream stream;
  final String? currentVariant;
  final ValueChanged<String?> onVariantChanged;
  const _OverlayControls({
    required this.player,
    required this.title,
    required this.stream,
    required this.currentVariant,
    required this.onVariantChanged,
  });

  @override
  State<_OverlayControls> createState() => _OverlayControlsState();
}

class _OverlayControlsState extends State<_OverlayControls> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
            Colors.transparent,
            Colors.black54,
          ],
          stops: [0, 0.25, 0.75, 1],
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TSpace.sm,
                vertical: TSpace.xs,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: TSpace.sm),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.stream.variants.isNotEmpty)
                    _VariantButton(
                      stream: widget.stream,
                      current: widget.currentVariant,
                      onChanged: (v) {
                        widget.onVariantChanged(v);
                        setState(() {});
                      },
                    ),
                  _SpeedButton(player: widget.player),
                ],
              ),
            ),
          ),
          const Spacer(),
          StreamBuilder(
            stream: widget.player.stream.playing,
            builder: (_, snap) => Semantics(
              button: true,
              label: snap.data == true ? 'Pause' : 'Play',
              child: IconButton(
                iconSize: 64,
                icon: Icon(
                  snap.data == true
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  color: Colors.white,
                  size: 64,
                ),
                onPressed: widget.player.playOrPause,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(TSpace.lg, 0, TSpace.lg, TSpace.xxl),
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
                            value: dur.inSeconds > 0
                                ? pos.inSeconds / dur.inSeconds
                                : 0,
                            onChanged: (v) => widget.player.seek(
                              Duration(
                                seconds: (v * dur.inSeconds).round(),
                              ),
                            ),
                            semanticFormatterCallback: (v) =>
                                '${_fmt(pos)} of ${_fmt(dur)}',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _fmt(pos),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                StreamBuilder<bool>(
                                  stream: widget.player.stream.buffering,
                                  builder: (_, buf) => buf.data == true
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _fmt(dur),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                ),
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
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 32,
                      ),
                      tooltip: 'Back 10 seconds',
                      onPressed: () async {
                        final pos = widget.player.state.position;
                        await widget.player.seek(
                          Duration(
                            seconds: (pos.inSeconds - 10).clamp(0, 999999),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: TSpace.xxl),
                    IconButton(
                      icon: const Icon(
                        Icons.forward_30,
                        color: Colors.white,
                        size: 32,
                      ),
                      tooltip: 'Forward 30 seconds',
                      onPressed: () async {
                        final pos = widget.player.state.position;
                        await widget.player.seek(
                          Duration(seconds: pos.inSeconds + 30),
                        );
                      },
                    ),
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
    return h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
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
  static const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double current = 1.0;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Playback speed',
      child: TextButton(
      onPressed: () async {
        final val = await showModalBottomSheet<double>(
          context: context,
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(TSpace.lg),
                  child: Text(
                    'Playback speed',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final s in speeds)
                  ListTile(
                    title: Text('${s}x'),
                    trailing: s == current
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, s),
                  ),
              ],
            ),
          ),
        );
        if (val != null) {
          await widget.player.setRate(val);
          setState(() => current = val);
        }
      },
      child: Text(
        '${current}x',
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      ),
    );
  }
}

class _VariantButton extends StatelessWidget {
  final ResolvedStream stream;
  final String? current;
  final ValueChanged<String?> onChanged;
  const _VariantButton({
    required this.stream,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.hd, color: Colors.white),
      tooltip: 'Quality',
      onPressed: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          builder: (_) => _VariantSheet(
            variants: stream.variants,
            selected: current ?? stream.selectedVariant,
          ),
        );
        if (selected != null) onChanged(selected);
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
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(TSpace.lg),
            child: Text(
              'Quality',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final v in variants)
                  ListTile(
                    title: Text(v.label),
                    subtitle: v.bitrateKbps != null
                        ? Text('${v.bitrateKbps} kbps')
                        : null,
                    trailing: v.id == selected
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(context, v.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
