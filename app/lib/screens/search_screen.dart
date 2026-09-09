import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../ffi/bridge.dart';
import 'detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? prefilter;
  const SearchScreen({super.key, this.prefilter});

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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white),
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.red,
          decoration: const InputDecoration(
            hintText: 'Search movies, series…',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          onSubmitted: (q) => ref.read(searchProvider.notifier).search(q),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (state.query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white54),
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
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(e.toString(), style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => ref.read(searchProvider.notifier).search(state.query), child: const Text('Retry')),
            ],
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(hasQuery ? Icons.search_off : Icons.search, color: Colors.white24, size: 72),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'No results found' : 'Type to search…',
            style: const TextStyle(color: Colors.white38, fontSize: 18),
          ),
        ],
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
    return Column(
      children: [
        if (partial)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Some sources failed — showing partial results', style: TextStyle(color: Colors.amber, fontSize: 12)),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.65,
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(content: result.content, title: result.title)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            result.posterUrl != null
                ? Image.network(result.posterUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _PosterPlaceholder())
                : const _PosterPlaceholder(),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent]),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    if (result.year != null)
                      Text('${result.year}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ),
            if (result.qualityBadges.isNotEmpty)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(3)),
                  child: Text(result.qualityBadges.first, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();
  @override
  Widget build(BuildContext context) =>
      Container(color: Colors.grey[850], child: const Center(child: Icon(Icons.movie, color: Colors.white24, size: 36)));
}
