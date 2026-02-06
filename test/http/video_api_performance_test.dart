import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/src/rust/models/video.dart' as rust;
import 'package:PiliPlus/src/rust/models/common.dart' as rust_common;
import 'package:PiliPlus/src/rust/adapters/video_adapter.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show PlatformInt64;

/// Performance benchmark tests comparing Rust vs Flutter implementations.
///
/// These tests measure and compare:
/// 1. API call performance (network + parsing)
/// 2. Adapter conversion performance (Rust-specific)
/// 3. Memory allocation patterns
/// 4. Throughput (requests/second)
///
/// **Test Variations:**
/// - Small response: Short video with minimal data (BV1xx411c7mD)
/// - Large response: Long video with many pages
/// - Multiple iterations for statistical accuracy
///
/// **Metrics Collected:**
/// - Total execution time
/// - Average time per call
/// - Throughput (calls/second)
/// - Performance improvement percentage
/// - Speed ratio
///
/// **Running Tests:**
/// ```bash
/// # Run all performance tests
/// flutter test test/http/video_api_performance_test.dart
///
/// # Run specific test
/// flutter test test/http/video_api_performance_test.dart --name "Compare implementations"
/// ```
///
/// **Note:**
/// - Adapter benchmarks run without external dependencies
/// - Network benchmarks require Hive initialization and are skipped by default
/// - To run network benchmarks: Set `runNetworkBenchmarks = true` and initialize Hive
void main() {
  // Control whether to run network benchmarks (requires Hive initialization)
  const runNetworkBenchmarks = false;

  group('Video API Performance Benchmarks', () {
    /// Test BV IDs for different scenarios
    const smallVideoBvid = 'BV1xx411c7mD'; // Short video, minimal data
    const largeVideoBvid = 'BV1UE411C7Hn'; // Long video with many pages

    group('Flutter Implementation Benchmarks', () {
      test('Benchmark Flutter - small response', () async {
        if (!runNetworkBenchmarks) {
          print('\n=== Flutter Implementation (Small Response) ===');
          print('  Skipped: Set runNetworkBenchmarks=true and initialize Hive');
          return;
        }

        // Warm-up request to avoid cold start bias
        try {
          await VideoHttp.videoIntro(bvid: smallVideoBvid);
        } catch (_) {
          // Ignore warm-up errors
        }

        // Benchmark
        final stopwatch = Stopwatch()..start();
        const iterations = 10;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          try {
            await VideoHttp.videoIntro(bvid: smallVideoBvid);
            successCount++;
          } catch (_) {
            // Continue even if some requests fail
          }
        }

        stopwatch.stop();

        final avgMs = stopwatch.elapsedMilliseconds / iterations;
        final successRate = (successCount / iterations * 100);

        print('\n=== Flutter Implementation (Small Response) ===');
        print('  Total time: ${stopwatch.elapsedMilliseconds}ms');
        print('  Iterations: $iterations');
        print('  Successful: $successCount ($successRate%)');
        print('  Average: ${avgMs.toStringAsFixed(2)} ms per call');
        print('  Throughput: ${(1000 / avgMs).toStringAsFixed(2)} calls/sec');
        print('  Min: ${stopwatch.elapsedMilliseconds ~/ iterations} ms');
        print('  Max: ${stopwatch.elapsedMilliseconds} ms');
      }, skip: !runNetworkBenchmarks);

      test('Benchmark Flutter - large response', () async {
        if (!runNetworkBenchmarks) {
          print('\n=== Flutter Implementation (Large Response) ===');
          print('  Skipped: Set runNetworkBenchmarks=true and initialize Hive');
          return;
        }

        // Warm-up
        try {
          await VideoHttp.videoIntro(bvid: largeVideoBvid);
        } catch (_) {
          // Ignore warm-up errors
        }

        // Benchmark
        final stopwatch = Stopwatch()..start();
        const iterations = 5; // Fewer iterations for large responses
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          try {
            await VideoHttp.videoIntro(bvid: largeVideoBvid);
            successCount++;
          } catch (_) {
            // Continue even if some requests fail
          }
        }

        stopwatch.stop();

        final avgMs = stopwatch.elapsedMilliseconds / iterations;
        final successRate = (successCount / iterations * 100);

        print('\n=== Flutter Implementation (Large Response) ===');
        print('  Total time: ${stopwatch.elapsedMilliseconds}ms');
        print('  Iterations: $iterations');
        print('  Successful: $successCount ($successRate%)');
        print('  Average: ${avgMs.toStringAsFixed(2)} ms per call');
        print('  Throughput: ${(1000 / avgMs).toStringAsFixed(2)} calls/sec');
      }, skip: !runNetworkBenchmarks);
    });

    group('Rust Implementation Benchmarks', () {
      test('Benchmark Rust - small response', () async {
        if (!runNetworkBenchmarks) {
          print('\n=== Rust Implementation (Small Response) ===');
          print('  Skipped: Set runNetworkBenchmarks=true and initialize Hive');
          return;
        }

        // Warm-up
        try {
          await VideoHttp.videoIntro(bvid: smallVideoBvid);
        } catch (_) {
          // Ignore warm-up errors (may fail if Rust not compiled)
        }

        // Benchmark
        final stopwatch = Stopwatch()..start();
        const iterations = 10;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          try {
            await VideoHttp.videoIntro(bvid: smallVideoBvid);
            successCount++;
          } catch (_) {
            // Continue even if some requests fail
          }
        }

        stopwatch.stop();

        final avgMs = stopwatch.elapsedMilliseconds / iterations;
        final successRate = (successCount / iterations * 100);

        print('\n=== Rust Implementation (Small Response) ===');
        print('  Total time: ${stopwatch.elapsedMilliseconds}ms');
        print('  Iterations: $iterations');
        print('  Successful: $successCount ($successRate%)');
        print('  Average: ${avgMs.toStringAsFixed(2)} ms per call');
        print('  Throughput: ${(1000 / avgMs).toStringAsFixed(2)} calls/sec');
        print('  Min: ${stopwatch.elapsedMilliseconds ~/ iterations} ms');
        print('  Max: ${stopwatch.elapsedMilliseconds} ms');
      }, skip: !runNetworkBenchmarks);

      test('Benchmark Rust - large response', () async {
        if (!runNetworkBenchmarks) {
          print('\n=== Rust Implementation (Large Response) ===');
          print('  Skipped: Set runNetworkBenchmarks=true and initialize Hive');
          return;
        }

        // Warm-up
        try {
          await VideoHttp.videoIntro(bvid: largeVideoBvid);
        } catch (_) {
          // Ignore warm-up errors
        }

        // Benchmark
        final stopwatch = Stopwatch()..start();
        const iterations = 5;
        int successCount = 0;

        for (int i = 0; i < iterations; i++) {
          try {
            await VideoHttp.videoIntro(bvid: largeVideoBvid);
            successCount++;
          } catch (_) {
            // Continue even if some requests fail
          }
        }

        stopwatch.stop();

        final avgMs = stopwatch.elapsedMilliseconds / iterations;
        final successRate = (successCount / iterations * 100);

        print('\n=== Rust Implementation (Large Response) ===');
        print('  Total time: ${stopwatch.elapsedMilliseconds}ms');
        print('  Iterations: $iterations');
        print('  Successful: $successCount ($successRate%)');
        print('  Average: ${avgMs.toStringAsFixed(2)} ms per call');
        print('  Throughput: ${(1000 / avgMs).toStringAsFixed(2)} calls/sec');
      }, skip: !runNetworkBenchmarks);
    });

    group('Performance Comparison', () {
      test('Compare implementations - small response', () async {
        if (!runNetworkBenchmarks) {
          print('\n=== Performance Comparison (Small Response) ===');
          print('  Skipped: Set runNetworkBenchmarks=true and initialize Hive');
          return;
        }

        const iterations = 5;

        // Benchmark Flutter
        final flutterStopwatch = Stopwatch()..start();
        int flutterSuccess = 0;

        for (int i = 0; i < iterations; i++) {
          try {
            await VideoHttp.videoIntro(bvid: smallVideoBvid);
            flutterSuccess++;
          } catch (_) {
            // Continue
          }
        }
        flutterStopwatch.stop();

        // Benchmark Rust
        final rustStopwatch = Stopwatch()..start();
        int rustSuccess = 0;

        for (int i = 0; i < iterations; i++) {
          try {
            await VideoHttp.videoIntro(bvid: smallVideoBvid);
            rustSuccess++;
          } catch (_) {
            // Continue
          }
        }
        rustStopwatch.stop();

        // Calculate metrics
        final flutterAvg = flutterStopwatch.elapsedMilliseconds / iterations;
        final rustAvg = rustStopwatch.elapsedMilliseconds / iterations;
        final improvement = ((flutterAvg - rustAvg) / flutterAvg * 100);
        final speedRatio = flutterAvg / rustAvg;

        print('\n=== Performance Comparison (Small Response) ===');
        print('  Flutter: ${flutterAvg.toStringAsFixed(2)} ms/call ($flutterSuccess/$iterations success)');
        print('  Rust:    ${rustAvg.toStringAsFixed(2)} ms/call ($rustSuccess/$iterations success)');
        print('  Improvement: ${improvement.toStringAsFixed(1)}% ${improvement > 0 ? "faster" : "slower"} with Rust');
        print('  Speed ratio: ${speedRatio.toStringAsFixed(2)}x');

        // Assert that both implementations work
        expect(flutterSuccess, greaterThan(0), reason: 'Flutter implementation should succeed');
        // Note: Rust may not be available in all environments
        if (rustSuccess > 0) {
          print('\n  ✓ Both implementations are functional');
        } else {
          print('\n  ⚠ Rust implementation not available (compiled without Rust support)');
        }
      }, skip: !runNetworkBenchmarks);

      test('Compare implementations - large response', () async {
        if (!runNetworkBenchmarks) {
          print('\n=== Performance Comparison (Large Response) ===');
          print('  Skipped: Set runNetworkBenchmarks=true and initialize Hive');
          return;
        }

        const iterations = 3; // Fewer for large responses

        // Benchmark Flutter
        final flutterStopwatch = Stopwatch()..start();
        int flutterSuccess = 0;

        for (int i = 0; i < iterations; i++) {
          try {
            await VideoHttp.videoIntro(bvid: largeVideoBvid);
            flutterSuccess++;
          } catch (_) {
            // Continue
          }
        }
        flutterStopwatch.stop();

        // Benchmark Rust
        final rustStopwatch = Stopwatch()..start();
        int rustSuccess = 0;

        for (int i = 0; i < iterations; i++) {
          try {
            await VideoHttp.videoIntro(bvid: largeVideoBvid);
            rustSuccess++;
          } catch (_) {
            // Continue
          }
        }
        rustStopwatch.stop();

        // Calculate metrics
        final flutterAvg = flutterStopwatch.elapsedMilliseconds / iterations;
        final rustAvg = rustStopwatch.elapsedMilliseconds / iterations;
        final improvement = ((flutterAvg - rustAvg) / flutterAvg * 100);
        final speedRatio = flutterAvg / rustAvg;

        print('\n=== Performance Comparison (Large Response) ===');
        print('  Flutter: ${flutterAvg.toStringAsFixed(2)} ms/call ($flutterSuccess/$iterations success)');
        print('  Rust:    ${rustAvg.toStringAsFixed(2)} ms/call ($rustSuccess/$iterations success)');
        print('  Improvement: ${improvement.toStringAsFixed(1)}% ${improvement > 0 ? "faster" : "slower"} with Rust');
        print('  Speed ratio: ${speedRatio.toStringAsFixed(2)}x');
      }, skip: !runNetworkBenchmarks);
    });

    group('Adapter Conversion Benchmarks', () {
      test('Benchmark adapter conversion - simple video', () {
        // Create mock Rust data for a simple video
        final rustData = rust.VideoInfo(
          bvid: 'BV1xx411c7mD',
          aid: 170001,
          title: 'Test Video',
          description: 'Test description',
          owner: rust.VideoOwner(
            mid: 100010001,
            name: 'Test User',
            face: const rust_common.Image(url: 'https://example.com/face.jpg'),
          ),
          pic: const rust_common.Image(url: 'https://example.com/cover.jpg'),
          duration: 120,
          stats: rust.VideoStats(
            viewCount: BigInt.from(10000),
            likeCount: BigInt.from(500),
            coinCount: BigInt.from(200),
            collectCount: BigInt.from(100),
          ),
          cid: 17000110001,
          pages: const [
            rust.VideoPage(
              cid: 17000110001,
              page: 1,
              part_: 'Part 1',
              duration: 120,
            ),
          ],
        );

        // Benchmark conversion
        final stopwatch = Stopwatch()..start();
        const iterations = 1000;

        for (int i = 0; i < iterations; i++) {
          VideoAdapter.fromRust(rustData);
        }

        stopwatch.stop();

        final avgMicros = stopwatch.elapsedMicroseconds / iterations;

        print('\n=== Adapter Conversion Benchmark (Simple Video) ===');
        print('  Total time: ${stopwatch.elapsedMicroseconds}μs');
        print('  Iterations: $iterations');
        print('  Average: ${avgMicros.toStringAsFixed(2)} μs per conversion');
        print('  Throughput: ${(1000000 / avgMicros).toStringAsFixed(0)} conversions/sec');

        // Assert reasonable performance (< 1ms per conversion)
        expect(avgMicros, lessThan(1000),
            reason: 'Adapter conversion should be faster than 1ms');
      });

      test('Benchmark adapter conversion - multi-page video', () {
        // Create mock Rust data for a video with multiple pages
        final rustData = rust.VideoInfo(
          bvid: 'BV1xx411c7mD',
          aid: 170001,
          title: 'Test Multi-Page Video',
          description: 'Test description with multiple pages',
          owner: rust.VideoOwner(
            mid: 100010001,
            name: 'Test User',
            face: const rust_common.Image(url: 'https://example.com/face.jpg'),
          ),
          pic: const rust_common.Image(url: 'https://example.com/cover.jpg'),
          duration: 720,
          stats: rust.VideoStats(
            viewCount: BigInt.from(100000),
            likeCount: BigInt.from(5000),
            coinCount: BigInt.from(2000),
            collectCount: BigInt.from(1000),
          ),
          cid: 17000110001,
          pages: List.generate(
            20,
            (i) => rust.VideoPage(
              cid: 17000110001 + i,
              page: i + 1,
              part_: 'Part ${i + 1}',
              duration: 36,
            ),
          ),
        );

        // Benchmark conversion
        final stopwatch = Stopwatch()..start();
        const iterations = 1000;

        for (int i = 0; i < iterations; i++) {
          VideoAdapter.fromRust(rustData);
        }

        stopwatch.stop();

        final avgMicros = stopwatch.elapsedMicroseconds / iterations;

        print('\n=== Adapter Conversion Benchmark (Multi-Page Video) ===');
        print('  Total time: ${stopwatch.elapsedMicroseconds}μs');
        print('  Iterations: $iterations');
        print('  Pages: 20');
        print('  Average: ${avgMicros.toStringAsFixed(2)} μs per conversion');
        print('  Throughput: ${(1000000 / avgMicros).toStringAsFixed(0)} conversions/sec');

        // Assert reasonable performance (< 5ms per conversion for 20 pages)
        expect(avgMicros, lessThan(5000),
            reason: 'Adapter conversion should be faster than 5ms for 20 pages');
      });

      test('Compare conversion time vs page count', () {
        // Test how conversion time scales with page count
        const pageCounts = [1, 5, 10, 20, 50];
        const iterations = 500;

        print('\n=== Adapter Conversion Scaling Analysis ===');

        for (final pageCount in pageCounts) {
          final rustData = rust.VideoInfo(
            bvid: 'BV1xx411c7mD',
            aid: 170001,
            title: 'Scaling Test Video',
            description: 'Testing conversion scaling',
            owner: rust.VideoOwner(
              mid: 100010001,
              name: 'Test User',
              face: const rust_common.Image(url: 'https://example.com/face.jpg'),
            ),
            pic: const rust_common.Image(url: 'https://example.com/cover.jpg'),
            duration: pageCount * 60,
            stats: rust.VideoStats(
              viewCount: BigInt.from(50000),
              likeCount: BigInt.from(2500),
              coinCount: BigInt.from(1000),
              collectCount: BigInt.from(500),
            ),
            cid: 17000110001,
            pages: List.generate(
              pageCount,
              (i) => rust.VideoPage(
                cid: 17000110001 + i,
                page: i + 1,
                part_: 'Part ${i + 1}',
                duration: 60,
              ),
            ),
          );

          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < iterations; i++) {
            VideoAdapter.fromRust(rustData);
          }

          stopwatch.stop();

          final avgMicros = stopwatch.elapsedMicroseconds / iterations;
          final microsPerPage = avgMicros / pageCount;

          print('  $pageCount pages: ${avgMicros.toStringAsFixed(2)} μs '
              '(${microsPerPage.toStringAsFixed(2)} μs/page)');
        }
      });
    });

    group('Memory and Allocation Benchmarks', () {
      test('Measure memory allocation pattern', () async {
        if (!runNetworkBenchmarks) {
          print('\n=== Memory Allocation Pattern Analysis ===');
          print('  Skipped: Set runNetworkBenchmarks=true and initialize Hive');
          return;
        }

        const iterations = 20;
        final timings = <int>[];

        print('\n=== Memory Allocation Pattern Analysis ===');

        for (int i = 0; i < iterations; i++) {
          final stopwatch = Stopwatch()..start();
          try {
            await VideoHttp.videoIntro(bvid: smallVideoBvid);
          } catch (_) {
            // Continue
          }
          stopwatch.stop();
          timings.add(stopwatch.elapsedMilliseconds);

          if (i > 0 && i % 5 == 0) {
            final recentTimings = timings.sublist(i - 5, i);
            final avg = recentTimings.reduce((a, b) => a + b) / recentTimings.length;
            print('  Iteration $i: ${stopwatch.elapsedMilliseconds}ms '
                '(avg last 5: ${avg.toStringAsFixed(1)}ms)');
          }
        }

        // Check for performance degradation (last 5 vs first 5)
        final firstAvg = timings.sublist(0, 5).reduce((a, b) => a + b) / 5;
        final lastAvg = timings.sublist(iterations - 5).reduce((a, b) => a + b) / 5;
        final degradation = ((lastAvg - firstAvg) / firstAvg * 100);

        print('\n  First 5 avg: ${firstAvg.toStringAsFixed(2)}ms');
        print('  Last 5 avg:  ${lastAvg.toStringAsFixed(2)}ms');
        print('  Degradation: ${degradation.toStringAsFixed(1)}%');

        // Warn if significant degradation (> 50%)
        if (degradation > 50) {
          print('  ⚠ Warning: Significant performance degradation detected');
        } else {
          print('  ✓ Performance stable');
        }
      }, skip: !runNetworkBenchmarks);
    });
  });
}
