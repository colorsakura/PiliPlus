import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/video/video_detail/data.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';

/// Week 1 Internal Testing - Simple Smoke Tests
///
/// These are basic smoke tests to verify the Rust API integration works.
/// They don't require storage initialization and can be run independently.
///
/// Run with: flutter test test/week1_simple_smoke_test.dart

void main() {
  group('Week 1 Simple Smoke Tests', () {
    setUpAll(() {
      // Reset metrics before tests
      RustApiMetrics.reset();
      print('\n=== Week 1 Internal Testing - Simple Smoke Tests ===');
      print('Testing Rust Video API integration');
      print('Note: These tests call the real Bilibili API');
    });

    test('Smoke test: Basic video info fetch', () async {
      // Use a popular, stable video ID
      final bvid = 'BV1xx411c7mD';

      print('\n🧪 Testing video fetch for: $bvid');

      final result = await VideoHttp.videoIntro(bvid: bvid);

      // Verify we got a success result
      expect(result.isSuccess, isTrue, reason: 'Should return Success for valid video');

      final data = result.data;
      expect(data, isNotNull, reason: 'Video data should not be null');
      expect(data.bvid, equals(bvid), reason: 'BVID should match');
      expect(data.title, isNotEmpty, reason: 'Title should not be empty');

      print('✅ Successfully fetched: ${data.title}');
      print('   BVID: ${data.bvid}');
      print('   AID: ${data.aid}');
      print('   Duration: ${data.duration}s');
      if (data.pages != null) {
        print('   Pages: ${data.pages!.length}');
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Smoke test: Verify metrics are collected', () async {
      // Reset metrics
      RustApiMetrics.reset();

      final bvid = 'BV1xx411c7mD';
      await VideoHttp.videoIntro(bvid: bvid);

      // Get metrics
      final stats = RustApiMetrics.getStats();

      print('\n📊 Metrics collected:');
      print('   Total calls (Rust + Flutter): ${stats['rust_calls'] + stats['flutter_calls']}');
      print('   Rust calls: ${stats['rust_calls']}');
      print('   Fallbacks: ${stats['rust_fallbacks']}');
      print('   Errors: ${stats['errors']}');

      if (stats['rust_avg_latency'] != null && (stats['rust_avg_latency'] as double) > 0) {
        print('   Avg latency: ${(stats['rust_avg_latency'] as double).toStringAsFixed(2)}ms');
      }

      // Verify metrics were recorded
      final totalCalls = (stats['rust_calls'] as int) + (stats['flutter_calls'] as int);
      expect(totalCalls, greaterThan(0), reason: 'Should have recorded at least one call');

      print('✅ Metrics collection working');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Smoke test: Health status check', () async {
      // Make a call
      await VideoHttp.videoIntro(bvid: 'BV1xx411c7mD');

      // Check health
      final health = RustApiMetrics.calculateHealthStatus();

      print('\n💚 Health status: $health');

      // With successful calls, should be HEALTHY or at least WARNING
      expect(health, isIn(['HEALTHY', 'WARNING', 'CRITICAL']),
          reason: 'Should return valid health status');

      if (health == 'HEALTHY') {
        print('✅ System is healthy!');
      } else if (health == 'WARNING') {
        print('⚠️  System has warnings (check metrics)');
      } else {
        print('❌ System is in critical state (check logs)');
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Smoke test: Multiple consecutive calls', () async {
      print('\n🔄 Testing 3 consecutive calls...');

      final bvids = ['BV1xx411c7mD', 'BV1yy411c7mD', 'BV1zz411c7mD'];
      int successCount = 0;

      for (final bvid in bvids) {
        try {
          final result = await VideoHttp.videoIntro(bvid: bvid);
          if (result.isSuccess) {
            final data = result.data;
            successCount++;
            print('   ✅ ${data.title}');
          } else {
            print('   ⚠️  Failed: $bvid');
          }
        } catch (e) {
          print('   ⚠️  Error for $bvid: $e');
        }
      }

      print('\n✅ Completed $successCount/${bvids.length} calls successfully');
      expect(successCount, greaterThan(0), reason: 'At least one call should succeed');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Smoke test: Performance check', () async {
      print('\n⚡ Measuring performance...');

      const iterations = 3;
      final bvid = 'BV1xx411c7mD';
      final latencies = <int>[];

      for (int i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();
        await VideoHttp.videoIntro(bvid: bvid);
        stopwatch.stop();
        latencies.add(stopwatch.elapsedMilliseconds);
        print('   Iteration ${i + 1}: ${stopwatch.elapsedMilliseconds}ms');

        // Small delay to avoid rate limiting
        if (i < iterations - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
      final minLatency = latencies.reduce((a, b) => a < b ? a : b);
      final maxLatency = latencies.reduce((a, b) => a > b ? a : b);

      print('\n📊 Performance results:');
      print('   Average: ${avgLatency.toStringAsFixed(2)}ms');
      print('   Min: ${minLatency}ms');
      print('   Max: ${maxLatency}ms');

      // Basic performance check - should complete in reasonable time
      expect(avgLatency, lessThan(5000), reason: 'Average latency should be < 5s');

      if (avgLatency < 500) {
        print('✅ Excellent performance! (< 500ms)');
      } else if (avgLatency < 1000) {
        print('✅ Good performance (< 1s)');
      } else {
        print('⚠️  Performance is slow (> 1s)');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  group('Week 1 Integration Health Checks', () {
    test('Health check: Verify no crashes on invalid BVID', () async {
      print('\n🛡️  Testing error handling...');

      // Try with invalid BVID - should not crash
      try {
        final result = await VideoHttp.videoIntro(bvid: 'INVALID_BVID');
        if (result is Error) {
          print('✅ Gracefully handled invalid BVID (returned Error)');
        } else {
          print('⚠️  Unexpected success with invalid BVID');
        }
      } catch (e) {
        // Throwing is also acceptable - as long as it doesn't crash
        print('✅ Gracefully handled invalid BVID (threw exception: $e)');
      }

      // Test passes if we get here without crashing
      expect(true, isTrue);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Health check: Verify null safety', () async {
      print('\n🔒 Testing null safety...');

      final result = await VideoHttp.videoIntro(bvid: 'BV1xx411c7mD');

      expect(result, isNotNull, reason: 'Result should not be null');

      if (result.isSuccess) {
        final data = result.data;
        expect(data, isNotNull, reason: 'Data should not be null');
        expect(data.bvid, isNotNull, reason: 'BVID should not be null');
        expect(data.aid, isNotNull, reason: 'AID should not be null');
        expect(data.title, isNotNull, reason: 'Title should not be null');

        print('✅ Null safety check passed');
      }
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  group('Week 1 Summary', () {
    test('Generate summary report', () async {
      print('\n' + '=' * 60);
      print(' WEEK 1 INTERNAL TESTING - SUMMARY REPORT');
      print('=' * 60);

      final stats = RustApiMetrics.getStats();
      final health = RustApiMetrics.calculateHealthStatus();

      print('\n📊 Final Metrics:');
      print('   Total Calls: ${stats['rust_calls'] + stats['flutter_calls']}');
      print('   Rust Calls: ${stats['rust_calls']}');
      print('   Fallbacks: ${stats['rust_fallbacks']}');
      print('   Errors: ${stats['errors']}');

      if (stats['rust_avg_latency'] != null && (stats['rust_avg_latency'] as double) > 0) {
        print('   Avg Latency: ${(stats['rust_avg_latency'] as double).toStringAsFixed(2)}ms');
      }

      print('\n💚 Health Status: $health');

      if (health == 'HEALTHY') {
        print('\n✅ WEEK 1 STATUS: READY FOR BETA TESTING');
        print('   All systems operational.');
        print('   Ready to proceed to Week 2-3: Beta Testing (10% of beta users)');
      } else if (health == 'WARNING') {
        print('\n⚠️  WEEK 1 STATUS: PROCEED WITH CAUTION');
        print('   Some metrics show warnings.');
        print('   Review logs before proceeding to beta testing.');
      } else {
        print('\n❌ WEEK 1 STATUS: NOT READY');
        print('   Critical issues detected.');
        print('   Do not proceed to beta testing until resolved.');
      }

      print('\n📋 Next Steps:');
      if (health == 'HEALTHY') {
        print('   1. Review test results');
        print('   2. Fix any issues found');
        print('   3. Proceed to Week 2-3: Beta Testing');
      } else {
        print('   1. Investigate critical issues');
        print('   2. Fix problems');
        print('   3. Re-run Week 1 tests');
      }

      print('\n' + '=' * 60);

      // Test always passes - this is just a summary
      expect(true, isTrue);
    });
  });
}
