import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/play.dart';
import '../design/src/theme.dart';
import '../providers/history_provider.dart';
import '../ffi/bridge.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(allHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Watch History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all',
            onPressed: () => _confirmClearAll(context, ref),
          ),
        ],
      ),
      body: history.when(
        data: (entries) => entries.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 72,
                    ),
                    const SizedBox(height: TSpace.lg),
                    Text(
                      'Nothing watched yet — your history lands here',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (_, i) => _HistoryTile(entry: entries[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(height: TSpace.sm),
              const Text("Couldn't load history."),
              const SizedBox(height: TSpace.md),
              FilledButton(
                onPressed: () => ref.invalidate(allHistoryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final entries = ref.read(allHistoryProvider).value ?? [];
    if (entries.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Clear ${entries.length} items?'),
        content: const Text('Your watch history will be empty.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      for (final e in entries) {
        await theatreDeleteHistory(id: e.id);
      }
      ref.invalidate(allHistoryProvider);
      ref.invalidate(continueWatchingProvider);
    }
  }
}

class _HistoryTile extends ConsumerWidget {
  final HistoryEntry entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress =
        (entry.durationSeconds != null && entry.durationSeconds! > 0)
        ? (entry.positionSeconds / entry.durationSeconds!).clamp(0.0, 1.0)
        : 0.0;
    final dt = DateTime.fromMillisecondsSinceEpoch(entry.lastWatched * 1000);
    final fmt = DateFormat.yMMMd().add_jm();

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: TSpace.lg),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) async {
        await theatreDeleteHistory(id: entry.id);
        ref.invalidate(allHistoryProvider);
        ref.invalidate(continueWatchingProvider);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${entry.title}"'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await theatreRecordPlayback(entry: entry);
                ref.invalidate(allHistoryProvider);
                ref.invalidate(continueWatchingProvider);
              },
            ),
          ),
        );
      },
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: entry.posterUrl != null
              ? Image.network(
                  entry.posterUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.movie,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.movie,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
        title: Text(entry.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fmt.format(dt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: TSpace.xs),
            LinearProgressIndicator(value: progress, minHeight: 2),
          ],
        ),
        trailing: entry.completed
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: () {
          final source = entry.sourceId;
          final id = entry.contentId;
          if (source == null || id == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This file is no longer available.'),
              ),
            );
            return;
          }
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
      ),
    );
  }
}
