import 'package:test/test.dart';
import 'package:theatre/api/types.dart';

void main() {
  group('API contract types', () {
    test('InitConfig JSON round-trip', () {
      const c = InitConfig(
        dataDir: '/tmp/test',
        appVersion: '0.1.0',
        proxyEnabled: true,
      );
      final json = c.toJson();
      final c2 = InitConfig.fromJson(json);
      expect(c2.dataDir, '/tmp/test');
      expect(c2.proxyEnabled, isTrue);
    });

    test('SearchResult JSON round-trip', () {
      const r = SearchResult(
        content: ContentRef(
          source: 'moviebox',
          contentId: 'id1',
          kind: ContentKind.movie,
        ),
        title: 'Inception',
        year: 2010,
        posterUrl: 'https://example.com/poster.jpg',
        qualityBadges: ['1080p'],
      );
      final r2 = SearchResult.fromJson(r.toJson());
      expect(r2.title, 'Inception');
      expect(r2.year, 2010);
      expect(r2.qualityBadges.first, '1080p');
    });

    test('ResolvedStream JSON round-trip', () {
      const s = ResolvedStream(
        url: 'https://example.com/stream.m3u8',
        headers: {'X-Auth': 'token'},
        kind: StreamKind.hls,
        variants: [Variant(id: 'v1', label: '1080p', bitrateKbps: 4000)],
      );
      final s2 = ResolvedStream.fromJson(s.toJson());
      expect(s2.kind, StreamKind.hls);
      expect(s2.headers['X-Auth'], 'token');
      expect(s2.variants.first.label, '1080p');
    });

    test('HistoryEntry JSON round-trip', () {
      const e = HistoryEntry(
        id: 'local-abc',
        title: 'Test Movie',
        positionSeconds: 300,
        lastWatched: 1735000000,
        completed: false,
      );
      final e2 = HistoryEntry.fromJson(e.toJson());
      expect(e2.positionSeconds, 300);
      expect(e2.completed, isFalse);
    });
  });
}
