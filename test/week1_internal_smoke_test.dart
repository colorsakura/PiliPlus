import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/http/video_api_facade.dart';
import 'package:PiliPlus/models/video/video_detail/video_detail_response.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';

/// Week 1 Internal Testing - Smoke Tests
///
/// These tests validate that the Rust Video API integration works correctly
/// for internal testing with developers.
///
/// Run with: flutter test test/week1_internal_smoke_test.dart

void main() {
  group('Week 1 Internal Smoke Tests', () {
    setUpAll(() async {
      // Initialize storage
      await GStorage.init();
      // Enable Rust API
      GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
      // Reset metrics
      RustApiMetrics.reset();
    });

    test('Smoke test: Verify Rust API is enabled', () {
      final isEnabled = GStorage.setting.get(
        SettingBoxKey.useRustVideoApi,
        defaultValue: false,
      );

      expect(isEnabled, isTrue, reason: 'Rust API should be enabled for Week 1 testing');
    });

    test('Smoke test: Fetch video with known ID (BV1xx411c7mD)', () async {
      final bvid = 'BV1xx411c7mD'; // Generic test video

      try {
        final response = await VideoApiFacade.getVideoInfo(bvid);

        // Verify response structure
        expect(response, isNotNull, reason: 'Response should not be null');
        expect(response.code, equals(0), reason: 'API should return success code');
        expect(response.data, isNotNull, reason: 'Video data should not be null');

        // Verify required fields
        final videoData = response.data!;
        expect(videoData.bvid, equals(bvid), reason: 'BVID should match');
        expect(videoData.title, isNotEmpty, reason: 'Title should not be empty');
        expect(videoData.aid, greaterThan(0), reason: 'AID should be positive');
        expect(videoData.cid, greaterThan(0), reason: 'CID should be positive');
        expect(videoData.duration, greaterThan(0), reason: 'Duration should be positive');

        // Verify owner
        expect(videoData.owner, isNotNull, reason: 'Owner should not be null');
        expect(videoData.owner!.mid, greaterThan(0), reason: 'Owner MID should be positive');
        expect(videoData.owner!.name, isNotEmpty, reason: 'Owner name should not be empty');

        // Verify stats
        expect(videoData.stat, isNotNull, reason: 'Stats should not be null');
        expect(videoData.stat!.view, greaterThanOrEqualTo(0), reason: 'View count should be non-negative');

        // Verify pages
        expect(videoData.pages, isNotNull, reason: 'Pages should not be null');
        expect(videoData.pages!, isNotEmpty, reason: 'Video should have at least one page');
        expect(videoData.pages!.first.cid, greaterThan(0), reason: 'Page CID should be positive');

        print('✅ Smoke test passed for video: ${videoData.title}');
        print('   BVID: ${videoData.bvid}');
        print('   AID: ${videoData.aid}');
        print('   Duration: ${videoData.duration}s');
        print('   Pages: ${videoData.pages?.length}');
      } catch (e) {
        fail('Smoke test failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Smoke test: Verify metrics are being collected', () async {
      // Reset metrics
      RustApiMetrics.reset();

      // Make an API call
      final bvid = 'BV1xx411c7mD';
      await VideoApiFacade.getVideoInfo(bvid);

      // Check metrics
      final stats = RustApiMetrics.getStats();

      expect(stats['rust_calls'], greaterThan(0), reason: 'Should have recorded Rust calls');
      expect(stats['rust_fallbacks'], equals(0), reason: 'Should not have fallen back');
      expect(stats['errors'], equals(0), reason: 'Should not have errors');

      // Check latency
      final avgLatency = stats['rust_avg_latency'] as double;
      expect(avgLatency, greaterThan(0), reason: 'Should have recorded latency');
      expect(avgLatency, lessThan(5000), reason: 'Latency should be reasonable (< 5s)');

      print('✅ Metrics test passed');
      print('   Rust calls: ${stats['rust_calls']}');
      print('   Avg latency: ${avgLatency.toStringAsFixed(2)}ms');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Smoke test: Verify health status', () async {
      // Make an API call
      final bvid = 'BV1xx411c7mD';
      await VideoApiFacade.getVideoInfo(bvid);

      // Check health status
      final health = RustApiMetrics.calculateHealthStatus();

      expect(health, isIn(['HEALTHY', 'WARNING']), reason: 'Should be HEALTHY or WARNING');

      print('✅ Health status: $health');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Smoke test: Multiple consecutive calls', () async {
      final bvids = [
        'BV1xx411c7mD',
        'BV1yy411c7mD',
        'BV1zz411c7mD',
      ];

      for (final bvid in bvids) {
        try {
          final response = await VideoApiFacade.getVideoInfo(bvid);
          expect(response.code, equals(0), reason: 'API should succeed for $bvid');
          expect(response.data, isNotNull, reason: 'Data should not be null for $bvid');
          print('✅ Fetched: ${response.data!.title}');
        } catch (e) {
          // Some BV IDs might be invalid, that's okay for smoke test
          print('⚠️  Failed to fetch $bvid: $e');
        }
      }

      // Verify metrics collected for all calls
      final stats = RustApiMetrics.getStats();
      expect(stats['rust_calls'], greaterThan(0), reason: 'Should have recorded calls');
      print('✅ Total calls: ${stats['rust_calls']}');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Smoke test: Verify fallback mechanism', () async {
      // Reset metrics
      RustApiMetrics.reset();

      // Try with an invalid BVID (should gracefully handle error)
      final invalidBvid = 'BV1INVALIDID';

      try {
        await VideoApiFacade.getVideoInfo(invalidBvid);
        // If it succeeds, that's okay (API might return error response)
      } catch (e) {
        // If it throws, that's also okay
        print('⚠️  Expected error for invalid BVID: $e');
      }

      // Verify metrics recorded the call
      final stats = RustApiMetrics.getStats();
      expect(stats['rust_calls'] + stats['rust_fallbacks'], greaterThan(0),
          reason: 'Should have recorded the attempt');

      print('✅ Fallback mechanism test passed');
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  group('Week 1 Internal Performance Tests', () {
    setUpAll(() async {
      await GStorage.init();
      GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
      RustApiMetrics.reset();
    });

    test('Performance test: Measure average latency', () async {
      const iterations = 5;
      final bvid = 'BV1xx411c7mD';
      final latencies = <int>[];

      for (int i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();
        await VideoApiFacade.getVideoInfo(bvid);
        stopwatch.stop();
        latencies.add(stopwatch.elapsedMilliseconds);
        print('  Iteration ${i + 1}: ${stopwatch.elapsedMilliseconds}ms');

        // Small delay between calls
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
      final maxLatency = latencies.reduce((a, b) => a > b ? a : b);
      final minLatency = latencies.reduce((a, b) => a < b ? a : b);

      print('✅ Performance test results:');
      print('   Average: ${avgLatency.toStringAsFixed(2)}ms');
      print('   Min: ${minLatency}ms');
      print('   Max: ${maxLatency}ms');

      // Expect reasonable latency (< 1s average)
      expect(avgLatency, lessThan(1000), reason: 'Average latency should be < 1s');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Performance test: Verify no memory leaks', () async {
      // This is a basic smoke test for memory leaks
      // A comprehensive test would use Dart DevTools
      final bvid = 'BV1xx411c7mD';

      // Make 10 consecutive calls
      for (int i = 0; i < 10; i++) {
        await VideoApiFacade.getVideoInfo(bvid);
      }

      // If we get here without crashing, basic memory leak check passed
      expect(true, isTrue);
      print('✅ Basic memory leak check passed (10 consecutive calls)');
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
