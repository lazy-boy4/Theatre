import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../api/theatre_api.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueWatching = ref.watch(continueWatchingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            pinned: true,
            backgroundColor: Colors.black,
            title: const Text('Theatre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: continueWatching.when(
              data: (entries) => entries.isEmpty
                  ? const SizedBox.shrink()
                  : _ContinueWatchingSection(entries: entries),
              loading: () => const SizedBox(height: 8),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SliverToBoxAdapter(child: _PromoBanner()),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Browse', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Continue Watching', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) => _ContinueCard(entry: entries[i]),
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final HistoryEntry entry;
  const _ContinueCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final progress = (entry.durationSeconds != null && entry.durationSeconds! > 0)
        ? entry.positionSeconds / entry.durationSeconds!
        : 0.0;
    return GestureDetector(
      onTap: () {/* Navigate to player */},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              width: 180,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                image: entry.posterUrl != null
                    ? DecorationImage(image: NetworkImage(entry.posterUrl!), fit: BoxFit.cover)
                    : null,
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Column(
                children: [
                  LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 3, color: Colors.red, backgroundColor: Colors.white30),
                  Container(
                    padding: const EdgeInsets.all(6),
                    color: Colors.black54,
                    child: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const Center(child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 36)),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_filter, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text('Search for movies & series', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _BrowseGrid extends StatelessWidget {
  const _BrowseGrid();

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ('Movies',   Icons.movie,             const Color(0xFF8B0000)),
      ('Series',   Icons.live_tv,           const Color(0xFF003366)),
      ('Downloads',Icons.download,          const Color(0xFF1a4a1a)),
      ('Library',  Icons.folder_open,       const Color(0xFF4a3200)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: tiles.map((t) => _BrowseTile(label: t.$1, icon: t.$2, color: t.$3)).toList(),
    );
  }
}

class _BrowseTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _BrowseTile({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(prefilter: label.toLowerCase()))),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
