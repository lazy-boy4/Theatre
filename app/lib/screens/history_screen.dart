import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../api/theatre_api.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(allHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white),
        title: const Text('Watch History', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white38),
            tooltip: 'Clear all',
            onPressed: () => _confirmClearAll(context, ref),
          ),
        ],
      ),
      body: history.when(
        data: (entries) => entries.isEmpty
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.history, color: Colors.white24, size: 72),
                SizedBox(height: 16),
                Text('No history yet', style: TextStyle(color: Colors.white38, fontSize: 18)),
              ]))
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (_, i) => _HistoryTile(entry: entries[i], ref: ref),
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white70))),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Clear history?', style: TextStyle(color: Colors.white)),
        content: const Text('This cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      final entries = ref.read(allHistoryProvider).value ?? [];
      for (final e in entries) {
        await TheatreApi.instance.deleteHistory(e.id);
      }
      ref.invalidate(allHistoryProvider);
      ref.invalidate(continueWatchingProvider);
    }
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  final WidgetRef ref;
  const _HistoryTile({required this.entry, required this.ref});

  @override
  Widget build(BuildContext context) {
    final progress = (entry.durationSeconds != null && entry.durationSeconds! > 0)
        ? (entry.positionSeconds / entry.durationSeconds!).clamp(0.0, 1.0)
        : 0.0;
    final dt = DateTime.fromMillisecondsSinceEpoch(entry.lastWatched * 1000);
    final fmt = DateFormat.yMMMd().add_jm();

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await TheatreApi.instance.deleteHistory(entry.id);
        ref.invalidate(allHistoryProvider);
        ref.invalidate(continueWatchingProvider);
      },
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: entry.posterUrl != null
              ? Image.network(entry.posterUrl!, width: 50, height: 50, fit: BoxFit.cover)
              : Container(width: 50, height: 50, color: Colors.grey[850], child: const Icon(Icons.movie, color: Colors.white24)),
        ),
        title: Text(entry.title, style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fmt.format(dt), style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress, color: Colors.red, backgroundColor: Colors.white12, minHeight: 2),
          ],
        ),
        trailing: entry.completed ? const Icon(Icons.check_circle, color: Colors.green, size: 18) : null,
      ),
    );
  }
}
