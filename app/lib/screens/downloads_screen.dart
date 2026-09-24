import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/src/theme.dart';
import '../providers/download_provider.dart';
import '../ffi/bridge.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Downloads'),
      ),
      body: state.when(
        data: (jobs) => jobs.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(TSpace.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_done,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 72,
                      ),
                      const SizedBox(height: TSpace.lg),
                      Text(
                        'No downloads yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: TSpace.sm),
                      Text(
                        'Pick a quality on any title, then download for offline watching.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: jobs.length,
                itemBuilder: (ctx, i) => _DownloadTile(job: jobs[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(height: TSpace.sm),
              const Text("Couldn't load the download queue."),
              const SizedBox(height: TSpace.md),
              FilledButton(
                onPressed: () => ref.invalidate(downloadProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  final DownloadJob job;
  const _DownloadTile({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(downloadProvider.notifier);
    final progress = _progress();
    final statusColor = _statusColor(theme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TSpace.md, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _JobActions(job: job, notifier: notifier),
            ],
          ),
          const SizedBox(height: TSpace.sm),
          if (progress != null)
            LinearProgressIndicator(
              value: progress,
              color: statusColor,
              minHeight: 4,
            ),
          const SizedBox(height: TSpace.xs),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: TSpace.sm),
              Text(
                _sizeLabel(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (job.status == JobStatus.running &&
                  job.totalSegments != null) ...[
                const SizedBox(width: TSpace.sm),
                Text(
                  '${job.segmentsDone}/${job.totalSegments} parts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (job.errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                job.errorMsg!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  double? _progress() {
    if (job.status == JobStatus.done) return 1.0;
    if (job.kind == JobKind.hls &&
        job.totalSegments != null &&
        job.totalSegments! > 0) {
      return job.segmentsDone / job.totalSegments!;
    }
    if (job.totalBytes != null && job.totalBytes! > 0) {
      return job.bytesDone / job.totalBytes!;
    }
    return null;
  }

  /// State vocabulary: primary = working, amber = waiting, error = failed.
  /// Red means failure and nothing else (docs/design.md: The One Voice Rule).
  Color _statusColor(ThemeData theme) => switch (job.status) {
    JobStatus.done => Colors.green,
    JobStatus.failed => theme.colorScheme.error,
    JobStatus.paused => Colors.amber,
    JobStatus.running => theme.colorScheme.primary,
    JobStatus.cancelled => theme.colorScheme.onSurfaceVariant,
    _ => theme.colorScheme.onSurfaceVariant,
  };

  String _statusLabel() => switch (job.status) {
    JobStatus.queued => 'Queued',
    JobStatus.preparing => 'Preparing…',
    JobStatus.running => 'Downloading',
    JobStatus.paused => 'Paused',
    JobStatus.failed => 'Failed',
    JobStatus.done => 'Done',
    JobStatus.cancelled => 'Cancelled',
  };

  String _sizeLabel() {
    String fmt(int b) {
      if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
      if (b < 1024 * 1024 * 1024) {
        return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }

    if (job.totalBytes != null) {
      return '${fmt(job.bytesDone)} / ${fmt(job.totalBytes!)}';
    }
    if (job.bytesDone > 0) return fmt(job.bytesDone);
    return '';
  }
}

class _JobActions extends StatelessWidget {
  final DownloadJob job;
  final DownloadNotifier notifier;
  const _JobActions({required this.job, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (job.status == JobStatus.running)
          IconButton(
            icon: const Icon(Icons.pause, size: 24),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: 'Pause download',
            onPressed: () => notifier.pause(job.id),
          ),
        if (job.status == JobStatus.paused)
          IconButton(
            icon: const Icon(Icons.play_arrow, size: 24),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: 'Resume download',
            onPressed: () => notifier.resume(job.id),
          ),
        if (job.status == JobStatus.failed)
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: 'Retry download',
            onPressed: () => notifier.resume(job.id),
          ),
        if (!_isFinal)
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: 'Cancel download',
            onPressed: () => notifier.cancel(job.id),
          ),
      ],
    );
  }

  bool get _isFinal =>
      job.status == JobStatus.done || job.status == JobStatus.cancelled;
}
