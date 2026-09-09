import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../api/theatre_api.dart';
import 'player_screen.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: _browsePath != null
            ? BackButton(color: Colors.white, onPressed: () => setState(() => _browsePath = null))
            : const BackButton(color: Colors.white),
        title: Text(_browsePath != null ? _browsePath!.split('/').last : 'Library', style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
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
                  : _LocationsList(locations: locs, onBrowse: (p) => setState(() => _browsePath = p), ref: ref),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
              error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white70))),
            ),
    );
  }

  void _handleEntry(MediaEntry entry) {
    if (entry.isDir) {
      setState(() => _browsePath = entry.path);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
        stream: ResolvedStream(url: 'file://${entry.path}', kind: StreamKind.direct),
        title: entry.name,
        content: ContentRef(source: 'local', contentId: entry.path, kind: ContentKind.movie),
      )));
    }
  }

  Future<void> _addFolder() async {
    // TODO: on Android use SAF picker; on desktop use FilePicker.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Folder picker not yet connected (T3.5)')));
  }
}

class _LocationsList extends StatelessWidget {
  final List<LibraryLocation> locations;
  final void Function(String) onBrowse;
  final WidgetRef ref;
  const _LocationsList({required this.locations, required this.onBrowse, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (_, i) {
        final loc = locations[i];
        return ListTile(
          leading: const Icon(Icons.folder, color: Colors.amber),
          title: Text(loc.label ?? loc.path, style: const TextStyle(color: Colors.white)),
          subtitle: Text(loc.path, style: const TextStyle(color: Colors.white38, fontSize: 12), overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white38),
                onPressed: () async {
                  await TheatreApi.instance.removeLocation(loc.id);
                  ref.invalidate(libraryLocationsProvider);
                },
              ),
              const Icon(Icons.chevron_right, color: Colors.white30),
            ],
          ),
          onTap: () => onBrowse(loc.path),
        );
      },
    );
  }
}

class _FolderView extends ConsumerWidget {
  final String path;
  final void Function(MediaEntry) onTap;
  const _FolderView({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(browseFolderProvider(path));
    return entries.when(
      data: (items) => items.isEmpty
          ? const Center(child: Text('Empty folder', style: TextStyle(color: Colors.white38)))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final e = items[i];
                return ListTile(
                  leading: Icon(e.isDir ? Icons.folder : Icons.movie, color: e.isDir ? Colors.amber : Colors.white54),
                  title: Text(e.name, style: const TextStyle(color: Colors.white)),
                  subtitle: e.sizeBytes != null && !e.isDir
                      ? Text(_fmt(e.sizeBytes!), style: const TextStyle(color: Colors.white38, fontSize: 11))
                      : null,
                  onTap: () => onTap(e),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
      error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white70))),
    );
  }

  String _fmt(int b) {
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    if (b < 1024 * 1024 * 1024) return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _EmptyLibrary extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyLibrary({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.folder_open, color: Colors.white24, size: 72),
        const SizedBox(height: 16),
        const Text('No library folders yet', style: TextStyle(color: Colors.white38, fontSize: 18)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          icon: const Icon(Icons.add),
          label: const Text('Add Folder'),
          onPressed: onAdd,
        ),
      ],
    ),
  );
}
