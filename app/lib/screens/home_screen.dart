import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/play.dart';
import '../design/src/theme.dart';
import '../providers/history_provider.dart';
import '../ffi/bridge.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueWatching = ref.watch(continueWatchingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            pinned: true,
            title: const Text(
              'Theatre',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
              ),
              const SizedBox(width: TSpace.sm),
            ],
          ),
          SliverToBoxAdapter(
            child: continueWatching.when(
              data: (entries) => entries.isEmpty
                  ? const SizedBox.shrink()
                  : _ContinueWatchingSection(entries: entries),
              loading: () => const SizedBox(height: TSpace.sm),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SliverToBoxAdapter(child: _PromoBanner()),
          SliverPadding(
            padding: const EdgeInsets.all(TSpace.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Browse', style: theme.textTheme.titleLarge),
                  const SizedBox(height: TSpace.md),
                  const _BrowseGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueWatchingSection extends StatelessWidget {
  final List<HistoryEntry> entries;
  const _ContinueWatchingSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TSpace.lg,
            TSpace.lg,
            TSpace.lg,
            TSpace.sm,
          ),
          child: Text(
            'Continue Watching',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TSpace.lg),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(width: TSpace.md),
            itemBuilder: (ctx, i) => _ContinueCard(entry: entries[i]),
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends ConsumerWidget {
  final HistoryEntry entry;
  const _ContinueCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress =
        (entry.durationSeconds != null && entry.durationSeconds! > 0)
            ? entry.positionSeconds / entry.durationSeconds!
            : 0.0;
    final remaining = entry.durationSeconds != null
        ? _remainingLabel(entry.durationSeconds! - entry.positionSeconds)
        : null;
    return Semantics(
      button: true,
      label: 'Resume ${entry.title}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          final source = entry.sourceId;
          final id = entry.contentId;
          if (source == null || id == null) return;
          playContent(
            context,
            ref,
            content: ContentRef(
              source: source,
              contentId: id,
              kind: ContentKind.movie,
            ),
            title: entry.title,
            variant: entry.variant,
            posterUrl: entry.posterUrl,
            durationSeconds: entry.durationSeconds,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                width: 180,
                color: theme.colorScheme.surfaceContainerHighest,
                child: entry.posterUrl != null
                    ? Image.network(
                        entry.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 3,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.black54,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (remaining != null)
                            Text(
                              remaining,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white70,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _remainingLabel(int seconds) {
    if (seconds <= 0) return 'Done';
    final h = seconds ~/ 3600, m = (seconds % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m left' : '${m}m left';
  }
}

/// Search entry point. A banner that does nothing is a broken promise —
/// this one is a button.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(TSpace.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: Ink(
          height: 168,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.primaryContainer,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.movie_filter,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 48,
                ),
                const SizedBox(height: TSpace.sm),
                Text(
                  'Find something to watch',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: TSpace.xs),
                Text(
                  'Search across your sources',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrowseGrid extends StatelessWidget {
  const _BrowseGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = [
      ('Movies', Icons.movie),
      ('Series', Icons.live_tv),
      ('Downloads', Icons.download),
      ('Library', Icons.folder_open),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: TSpace.md,
      crossAxisSpacing: TSpace.md,
      childAspectRatio: 2.2,
      children: [
        for (final t in tiles) _BrowseTile(label: t.$1, icon: t.$2, theme: theme),
      ],
    );
  }
}

class _BrowseTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeData theme;
  const _BrowseTile({
    required this.label,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchScreen(prefilter: label.toLowerCase()),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            const SizedBox(width: TSpace.md),
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: TSpace.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: TSpace.sm),
          ],
        ),
      ),
    );
  }
}
