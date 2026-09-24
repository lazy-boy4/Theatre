import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/play.dart';
import '../design/src/theme.dart';
import '../providers/detail_provider.dart';
import '../providers/download_provider.dart';
import '../providers/settings_provider.dart';
import '../ffi/bridge.dart';
import 'downloads_screen.dart';

class DetailScreen extends ConsumerWidget {
  final ContentRef content;
  final String title;
  const DetailScreen({super.key, required this.content, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(detailProvider(content));

    return Scaffold(
      body: details.when(
        data: (d) => _DetailBody(details: d),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(content: content),
      ),
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  final Details details;
  const _DetailBody({required this.details});

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  String? _variant;
  bool _pickingQuality = false;

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    return CustomScrollView(
      slivers: [
        _BackdropAppBar(details: details),
        SliverPadding(
          padding: const EdgeInsets.all(TSpace.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _StreamMetaRow(
                details: details,
                variant: _variant,
                pickingQuality: _pickingQuality,
                onPickQuality: _pickQuality,
                onSwitchSource: _switchSource,
              ),
              const SizedBox(height: TSpace.md),
              _PlayButtons(details: details, variant: _variant),
              const SizedBox(height: TSpace.lg),
              _MetaRow(details: details),
              const SizedBox(height: TSpace.md),
              if (details.description != null)
                ..._descriptionBlock(context, details.description!),
              if (details.episodes.isNotEmpty) _EpisodeList(details: details),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _pickQuality() async {
    setState(() => _pickingQuality = true);
    late final ResolvedStream resolved;
    try {
      resolved = await ref.read(
        resolveProvider((widget.details.content, null)).future,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _pickingQuality = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't fetch quality options. Check your connection and try again.",
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _pickingQuality = false);
    if (resolved.variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This source offers a single quality — playing as-is.'),
        ),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _OptionSheet(
        title: 'Quality',
        options: [
          // '' means Auto; dismiss returns null — the two stay distinct.
          const ('', 'Auto (recommended)'),
          for (final v in resolved.variants)
            (
              v.id,
              v.bitrateKbps != null
                  ? '${v.label} · ${v.bitrateKbps} kbps'
                  : v.label,
            ),
        ],
        selected: _variant ?? '',
      ),
    );
    if (picked != null && mounted) {
      setState(() => _variant = picked.isEmpty ? null : picked);
    }
  }

  Future<void> _switchSource(String sourceId) async {
    if (sourceId == widget.details.content.source) return;
    final content = widget.details.content;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          content: ContentRef(
            source: sourceId,
            contentId: content.contentId,
            kind: content.kind,
          ),
          title: widget.details.title,
        ),
      ),
    );
  }
}

/// Source × quality × subtitle disclosure (PRD F1/F3/F10). The decision that
/// determines whether playback succeeds lives above the Play button.
class _StreamMetaRow extends ConsumerWidget {
  final Details details;
  final String? variant;
  final bool pickingQuality;
  final VoidCallback onPickQuality;
  final void Function(String sourceId) onSwitchSource;

  const _StreamMetaRow({
    required this.details,
    required this.variant,
    required this.pickingQuality,
    required this.onPickQuality,
    required this.onSwitchSource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(sourcesProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    final current = sources.valueOrNull
        ?.where((s) => s.id == details.content.source)
        .firstOrNull;
    final enabled = sources.valueOrNull?.where((s) => s.enabled).toList() ?? [];
    final subLang = settings.valueOrNull?['subtitle_language'] ?? 'Auto';

    return Wrap(
      spacing: TSpace.sm,
      runSpacing: TSpace.sm,
      children: [
        ActionChip(
          avatar: Icon(
            Icons.dns,
            size: 16,
            color: current?.status == SourceStatus.degraded
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          label: Text(current?.name ?? details.content.source),
          tooltip: current?.status == SourceStatus.degraded
              ? 'This source is having trouble — tap to try another'
              : 'Source — tap to switch provider',
          onPressed: enabled.length > 1
              ? () async {
                  final picked = await showModalBottomSheet<String>(
                    context: context,
                    builder: (_) => _OptionSheet(
                      title: 'Source',
                      options: [
                        for (final s in enabled)
                          (
                            s.id,
                            s.status == SourceStatus.degraded
                                ? '${s.name} · having trouble'
                                : s.name,
                          ),
                      ],
                      selected: details.content.source,
                    ),
                  );
                  if (picked != null) onSwitchSource(picked);
                }
              : null,
        ),
        ActionChip(
          avatar: pickingQuality
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.hd, size: 16),
          label: Text(variant ?? 'Auto quality'),
          tooltip: 'Quality — tap to choose before playing or downloading',
          onPressed: pickingQuality ? null : onPickQuality,
        ),
        Chip(
          avatar: const Icon(Icons.subtitles, size: 16),
          label: Text('Subs: ${subtitleLabel(subLang)}'),
        ),
      ],
    );
  }
}

/// Generic single-select bottom sheet (quality, source, speed, settings).
class _OptionSheet extends StatelessWidget {
  final String title;
  final List<(String?, String)> options;
  final String? selected;
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

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
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final o in options)
                  ListTile(
                    title: Text(o.$2),
                    trailing: o.$1 == selected
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(context, o.$1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropAppBar extends StatelessWidget {
  final Details details;
  const _BackdropAppBar({required this.details});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      leading: const BackButton(),
      flexibleSpace: FlexibleSpaceBar(
        background: details.backdropUrl != null
            ? Image.network(
                details.backdropUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _BackdropPlaceholder(),
              )
            : const _BackdropPlaceholder(),
      ),
    );
  }
}

class _BackdropPlaceholder extends StatelessWidget {
  const _BackdropPlaceholder();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.movie,
          color: theme.colorScheme.onSurfaceVariant,
          size: 64,
        ),
      ),
    );
  }
}

class _PlayButtons extends ConsumerWidget {
  final Details details;
  final String? variant;
  const _PlayButtons({required this.details, required this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Play',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => playContent(
              context,
              ref,
              content: details.content,
              title: details.title,
              variant: variant,
              posterUrl: details.posterUrl,
              durationSeconds: details.durationSeconds,
            ),
          ),
        ),
        const SizedBox(width: TSpace.md),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            onPressed: () => _download(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    late final ResolvedStream resolved;
    try {
      resolved = await ref.read(
        resolveProvider((details.content, variant)).future,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't prepare this download. Check your connection and try again.",
          ),
        ),
      );
      return;
    }
    try {
      await ref
          .read(downloadProvider.notifier)
          .enqueue(details.content, resolved, details.title, variant: variant);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't queue this download.")),
      );
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Download queued'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DownloadsScreen()),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Details details;
  const _MetaRow({required this.details});

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (details.year != null) '${details.year}',
      if (details.rating != null) details.rating!,
      if (details.durationSeconds != null)
        _formatDuration(details.durationSeconds!),
      if (details.genres?.isNotEmpty == true) details.genres!.first,
    ];
    return Wrap(
      spacing: TSpace.md,
      runSpacing: TSpace.xs,
      children: [for (final p in parts) Chip(label: Text(p))],
    );
  }

  String _formatDuration(int s) {
    final h = s ~/ 3600, m = (s % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}

List<Widget> _descriptionBlock(BuildContext context, String desc) {
  final theme = Theme.of(context);
  return [
    Text(
      'About',
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    const SizedBox(height: TSpace.sm),
    Text(desc, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
    const SizedBox(height: TSpace.lg),
  ];
}

class _EpisodeList extends StatelessWidget {
  final Details details;
  const _EpisodeList({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Episodes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: TSpace.sm),
        ...details.episodes.map((ep) => _EpisodeTile(ep: ep)),
      ],
    );
  }
}

class _EpisodeTile extends ConsumerWidget {
  final Episode ep;
  const _EpisodeTile({required this.ep});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ep.thumbnailUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                ep.thumbnailUrl!,
                width: 80,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 45,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.play_arrow,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : Container(
              width: 80,
              height: 45,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.play_arrow,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      title: Text('S${ep.season} E${ep.episode}: ${ep.title}'),
      subtitle: ep.description != null
          ? Text(ep.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
      trailing: const Icon(Icons.play_arrow),
      onTap: () => playContent(
        context,
        ref,
        content: ep.content,
        title: 'S${ep.season} E${ep.episode}: ${ep.title}',
        durationSeconds: ep.durationSeconds,
      ),
    );
  }
}

class _ErrorBody extends ConsumerWidget {
  final ContentRef content;
  const _ErrorBody({required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BackButton(),
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: TSpace.md),
            Text(
              "Couldn't load these details. The source may be down — try another source, or retry.",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSpace.lg),
            FilledButton(
              onPressed: () => ref.invalidate(detailProvider(content)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
