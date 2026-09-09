import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/src/theme.dart';
import '../providers/library_provider.dart';
import '../ffi/bridge.dart';
import 'player_screen.dart';

/// Folder picking isn't wired yet (first file-picker integration). Say so
/// once, in one place, instead of two fake affordances.
const _pickerUnavailableMessage =
    'Adding folders arrives in a coming update — downloaded titles already play from Downloads.';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});
  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String? _browsePath;

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(libraryLocationsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _browsePath != null ? _basename(_browsePath!) : 'Library',
        ),
        leading: _browsePath != null
            ? BackButton(onPressed: () => setState(() => _browsePath = null))
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add folder',
            onPressed: _addFolder,
          ),
        ],
      ),
      body: _browsePath != null
          ? _FolderView(path: _browsePath!, onTap: _handleEntry)
          : locations.when(
              data: (locs) => locs.isEmpty
                  ? _EmptyLibrary(onAdd: _addFolder)
                  : _LocationsList(
                      locations: locs,
                      onBrowse: (p) => setState(() => _browsePath = p),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _LoadError(
                message: "Couldn't list your folders.",
                onRetry: () => ref.invalidate(libraryLocationsProvider),
              ),
            ),
    );
  }

  /// Works for POSIX and Windows separators without a path dependency.
  String _basename(String path) {
    final parts = path.split(RegExp(r'[/\\]')).where((s) => s.isNotEmpty);
    return parts.isEmpty ? path : parts.last;
  }

  void _handleEntry(MediaEntry entry) {
    if (!entry.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${entry.name}" is missing — it may have been moved or deleted.')),
      );
      return;
    }
    if (entry.isDir) {
      setState(() => _browsePath = entry.path);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerScreen(
            stream: ResolvedStream(
              url: 'file://${entry.path}',
              kind: StreamKind.direct,
            ),
            title: entry.name,
            content: ContentRef(
              source: 'local',
              contentId: entry.path,
              kind: ContentKind.movie,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _addFolder() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(_pickerUnavailableMessage)),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(height: TSpace.sm),
          Text(message),
          const SizedBox(height: TSpace.md),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _LocationsList extends ConsumerWidget {
  final List<LibraryLocation> locations;
  final void Function(String) onBrowse;
  const _LocationsList({required this.locations, required this.onBrowse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (_, i) {
        final loc = locations[i];
        return ListTile(
          leading: Icon(
            Icons.folder,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(loc.label ?? loc.path),
          subtitle: Text(
            loc.path,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove folder from library',
                onPressed: () => _confirmDetach(context, ref, loc),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => onBrowse(loc.path),
        );
      },
    );
  }

  Future<void> _confirmDetach(
    BuildContext context,
    WidgetRef ref,
    LibraryLocation loc,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove this folder?'),
        content: Text(
          '"${loc.label ?? loc.path}" leaves your library. Files on disk stay untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remove',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await theatreRemoveLocation(id: loc.id);
      ref.invalidate(libraryLocationsProvider);
    }
  }
}

class _FolderView extends ConsumerWidget {
  final String path;
  final void Function(MediaEntry) onTap;
  const _FolderView({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(browseFolderProvider(path));
    final theme = Theme.of(context);
    return entries.when(
      data: (items) => items.isEmpty
          ? Center(
              child: Text(
                'This folder has no playable files yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final e = items[i];
                return ListTile(
                  leading: Icon(
                    e.isDir ? Icons.folder : Icons.movie,
                    color: e.isDir
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    e.name,
                    style: e.exists
                        ? null
                        : TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                  ),
                  subtitle: e.sizeBytes != null && !e.isDir
                      ? Text(_fmt(e.sizeBytes!))
                      : null,
                  trailing: e.exists ? null : const Icon(Icons.error_outline),
                  onTap: () => onTap(e),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _LoadError(
        message: "Couldn't open this folder.",
        onRetry: () => ref.invalidate(browseFolderProvider(path)),
      ),
    );
  }

  String _fmt(int b) {
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    if (b < 1024 * 1024 * 1024) {
      return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _EmptyLibrary extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyLibrary({required this.onAdd});
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
              Icons.folder_open,
              color: theme.colorScheme.onSurfaceVariant,
              size: 72,
            ),
            const SizedBox(height: TSpace.lg),
            Text(
              'Your own files live here',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: TSpace.sm),
            Text(
              'Add a folder to browse and play videos already on this device.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSpace.lg),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Folder'),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
