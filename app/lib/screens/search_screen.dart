import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/src/theme.dart';
import '../providers/search_provider.dart';
import '../ffi/bridge.dart';
import 'detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? prefilter;

  /// When hosted as a bottom-nav tab there is no route to pop and the
  /// keyboard must not leap up on app start.
  final bool isTab;
  const SearchScreen({super.key, this.prefilter, this.isTab = false});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.prefilter ?? '');
    if (widget.prefilter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchProvider.notifier).search(widget.prefilter!);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        title: TextField(
          controller: _ctrl,
          autofocus: !widget.isTab,
          style: theme.textTheme.titleMedium,
          decoration: InputDecoration(
            hintText: 'Search movies, series…',
            hintStyle: TextStyle(color: theme.hintColor),
            border: InputBorder.none,
          ),
          onSubmitted: (q) => ref.read(searchProvider.notifier).search(q),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (state.query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear search',
              onPressed: () {
                _ctrl.clear();
                ref.read(searchProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: state.page.when(
        data: (page) => page.results.isEmpty
            ? _EmptyState(hasQuery: state.query.isNotEmpty)
            : _ResultsGrid(results: page.results, partial: page.partial),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(TSpace.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: TSpace.md),
                Text(
                  'Search failed — the sources may be down or you may be offline.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSpace.lg),
                FilledButton(
                  onPressed: () =>
                      ref.read(searchProvider.notifier).search(state.query),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  const _EmptyState({required this.hasQuery});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: 72,
            ),
            const SizedBox(height: TSpace.lg),
            Text(
              hasQuery
                  ? 'No results found — try a different title or spelling'
                  : 'Search across your enabled sources',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  final List<SearchResult> results;
  final bool partial;
  const _ResultsGrid({required this.results, required this.partial});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (partial)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TSpace.sm),
            color: theme.colorScheme.tertiaryContainer,
            child: Text(
              'Some sources failed — showing partial results',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(TSpace.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: results.length,
            itemBuilder: (ctx, i) => _PosterCard(result: results[i]),
          ),
        ),
      ],
    );
  }
}

class _PosterCard extends StatelessWidget {
  final SearchResult result;
  const _PosterCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: result.year != null
          ? '${result.title}, ${result.year}'
          : result.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailScreen(content: result.content, title: result.title),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              result.posterUrl != null
                  ? Image.network(
                      result.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PosterPlaceholder(),
                    )
                  : const _PosterPlaceholder(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        result.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (result.year != null) const SizedBox(height: 2),
                      if (result.year != null)
                        Text(
                          '${result.year}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (result.qualityBadges.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: _QualityBadge(label: result.qualityBadges.first),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quality is information, not an alarm — primary container, never red.
class _QualityBadge extends StatelessWidget {
  final String label;
  const _QualityBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.movie,
          color: theme.colorScheme.onSurfaceVariant,
          size: 36,
        ),
      ),
    );
  }
}
