import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/detail_provider.dart';
import '../providers/download_provider.dart';
import '../api/theatre_api.dart';
import 'player_screen.dart';

class DetailScreen extends ConsumerWidget {
  final ContentRef content;
  final String title;
  const DetailScreen({super.key, required this.content, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(detailProvider(content));

    return Scaffold(
      backgroundColor: Colors.black,
      body: details.when(
        data: (d) => _DetailBody(details: d),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (e, _) => _ErrorBody(error: e.toString(), content: content, title: title),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final Details details;
  const _DetailBody({required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        _BackdropAppBar(details: details),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _PlayButtons(details: details),
              const SizedBox(height: 16),
              _MetaRow(details: details),
              const SizedBox(height: 12),
              if (details.description != null) ..._descriptionBlock(details.description!),
              if (details.episodes.isNotEmpty) _EpisodeList(details: details),
            ]),
          ),
        ),
      ],
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
      backgroundColor: Colors.black,
      leading: const BackButton(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: details.backdropUrl != null
            ? Image.network(details.backdropUrl!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _BackdropPlaceholder())
            : const _BackdropPlaceholder(),
      ),
    );
  }
}

class _BackdropPlaceholder extends StatelessWidget {
  const _BackdropPlaceholder();
  @override
  Widget build(BuildContext context) =>
      Container(color: Colors.grey[900], child: const Center(child: Icon(Icons.movie, color: Colors.white24, size: 64)));
}

class _PlayButtons extends ConsumerWidget {
  final Details details;
  const _PlayButtons({required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _play(context, ref),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30), padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            onPressed: () => _download(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    final resolved = await ref.read(resolveProvider((details.content, null)).future);
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(stream: resolved, title: details.title, content: details.content)));
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    try {
      final resolved = await ref.read(resolveProvider((details.content, null)).future);
      await ref.read(downloadProvider.notifier).enqueue(details.content, resolved, details.title);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download queued')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
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
      if (details.durationSeconds != null) _formatDuration(details.durationSeconds!),
      if (details.genres?.isNotEmpty == true) details.genres!.first,
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: parts.map((p) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
        child: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      )).toList(),
    );
  }

  String _formatDuration(int s) {
    final h = s ~/ 3600, m = (s % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}

List<Widget> _descriptionBlock(String desc) => [
  const Text('About', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
  const SizedBox(height: 6),
  Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4)),
  const SizedBox(height: 16),
];

class _EpisodeList extends StatelessWidget {
  final Details details;
  const _EpisodeList({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Episodes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...details.episodes.map((ep) => _EpisodeTile(ep: ep, content: details.content)),
      ],
    );
  }
}

class _EpisodeTile extends ConsumerWidget {
  final Episode ep;
  final ContentRef content;
  const _EpisodeTile({required this.ep, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ep.thumbnailUrl != null
          ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(ep.thumbnailUrl!, width: 80, height: 45, fit: BoxFit.cover))
          : Container(width: 80, height: 45, color: Colors.grey[900], child: const Icon(Icons.play_arrow, color: Colors.white30)),
      title: Text('S${ep.season} E${ep.episode}: ${ep.title}', style: const TextStyle(color: Colors.white, fontSize: 13)),
      subtitle: ep.description != null
          ? Text(ep.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 11))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      onTap: () async {
        final resolved = await ref.read(resolveProvider((ep.content, null)).future);
        if (!context.mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(stream: resolved, title: 'S${ep.season} E${ep.episode}: ${ep.title}', content: ep.content)));
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String error;
  final ContentRef content;
  final String title;
  const _ErrorBody({required this.error, required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BackButton(),
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(error, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
