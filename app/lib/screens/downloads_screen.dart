import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/download_provider.dart';
import '../api/theatre_api.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Downloads', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: state.when(
        data: (jobs) => jobs.isEmpty
            ? const _EmptyDownloads()
            : ListView.builder(
                itemCount: jobs.length,
                itemBuilder: (ctx, i) => _DownloadTile(job: jobs[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white70))),
      ),
    );
  }
}

class _EmptyDownloads extends StatelessWidget {
  const _EmptyDownloads();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.download_done, color: Colors.white24, size: 72),
        SizedBox(height: 16),
        Text('No downloads yet', style: TextStyle(color: Colors.white38, fontSize: 18)),
      ],
    ),
  );
}

class _DownloadTile extends ConsumerWidget {
  final DownloadJob job;
  const _DownloadTile({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(downloadProvider.notifier);
    final progress = _progress();
    final statusColor = _statusColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(job.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
              _JobActions(job: job, notifier: notifier),
            ],
          ),
          const SizedBox(height: 8),
          if (progress != null) LinearProgressIndicator(value: progress, color: statusColor, backgroundColor: Colors.white12, minHeight: 4),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(_statusLabel(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Text(_sizeLabel(), style: const TextStyle(color: Colors.white38, fontSize: 11)),
              if (job.status == JobStatus.running && job.totalSegments != null) ...
                [const SizedBox(width: 8), Text('${job.segmentsDone}/${job.totalSegments} segs', style: const TextStyle(color: Colors.white38, fontSize: 11))],
            ],
          ),
          if (job.errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(job.errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  double? _progress() {
    if (job.status == JobStatus.done) return 1.0;
    if (job.kind == JobKind.hls && job.totalSegments != null && job.totalSegments! > 0) {
      return job.segmentsDone / job.totalSegments!;
    }
    if (job.totalBytes != null && job.totalBytes! > 0) {
      return job.bytesDone / job.totalBytes!;
    }
    return null;
  }

  Color _statusColor() => switch (job.status) {
    JobStatus.done      => Colors.green,
    JobStatus.failed    => Colors.red,
    JobStatus.paused    => Colors.amber,
    JobStatus.running   => Colors.blue,
    JobStatus.cancelled => Colors.grey,
    _                   => Colors.white54,
  };

  String _statusLabel() => switch (job.status) {
    JobStatus.queued    => 'Queued',
    JobStatus.preparing => 'Preparing…',
    JobStatus.running   => 'Downloading',
    JobStatus.paused    => 'Paused',
    JobStatus.failed    => 'Failed',
    JobStatus.done      => 'Done',
    JobStatus.cancelled => 'Cancelled',
  };

  String _sizeLabel() {
    String fmt(int b) {
      if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
      if (b < 1024 * 1024 * 1024) return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
      return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
    if (job.totalBytes != null) return '${fmt(job.bytesDone)} / ${fmt(job.totalBytes!)}';
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (job.status == JobStatus.running)
          IconButton(icon: const Icon(Icons.pause, color: Colors.white54, size: 20), onPressed: () => notifier.pause(job.id)),
        if (job.status == JobStatus.paused)
          IconButton(icon: const Icon(Icons.play_arrow, color: Colors.white54, size: 20), onPressed: () => notifier.resume(job.id)),
        if (job.status == JobStatus.failed)
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white54, size: 20), onPressed: () => notifier.resume(job.id)),
        if (!_isFinal)
          IconButton(icon: const Icon(Icons.close, color: Colors.white38, size: 20), onPressed: () => notifier.cancel(job.id)),
      ],
    );
  }

  bool get _isFinal => job.status == JobStatus.done || job.status == JobStatus.cancelled;
}
