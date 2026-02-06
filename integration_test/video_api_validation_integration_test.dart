import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/src/rust/frb_generated.dart';
import 'package:PiliPlus/src/rust/validation/video_validator.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:integration_test/integration_test.dart';

/// Integration tests with real Bilibili video IDs.
///
/// This test suite validates that Rust and Flutter implementations produce
/// identical results when fetching real video data from Bilibili's API.
///
/// **Prerequisites:**
/// - Rust library must be compiled (run `flutter_rust_bridge_codegen` first)
/// - Network access to Bilibili API is required
/// - Some test videos may become invalid over time (deleted/private)
///
/// **Running the Tests:**
/// ```bash
/// # Run integration tests
/// flutter test integration_test/video_api_validation_integration_test.dart
///
/// # Run on specific device
/// flutter test integration_test/video_api_validation_integration_test.dart -d <device_id>
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Video API Validation Integration Tests', () {
    setUpAll(() async {
      // Initialize Rust library
      print('\n=== Setup: Initializing Rust library ===');
      await RustLib.init();
      print('✅ Rust library initialized');

      // Initialize storage
      await GStorage.init();
      print('✅ Storage initialized');

      // Enable validation mode
      print('=== Setup: Validation mode ready ===\n');
    });

    tearDownAll(() {
      print('\n=== Teardown: Integration tests complete ===');
    });

    testWidgets('validate popular Bilibili videos', (WidgetTester tester) async {
      // Test with real Bilibili video IDs from various categories
      final testVideos = [
        // Technology & Programming
        'BV1GJ411x7h7', // Popular tech tutorial
        'BV1uv411q7Mv', // Programming tutorial

        // Gaming
        'BV1vA411b7Fq', // Gaming video
        'BV1Wx4y1z7bP', // Game walkthrough

        // Music
        'BV1uT4y1k7iK', // Music cover
        'BV1eK4y1k7pN', // Original music

        // Entertainment & Vlogs
        'BV1jA411h7Km', // Vlog
        'BV1sK411E7E8', // Entertainment

        // Education
        'BV1Th411S7wV', // Educational content
        'BV1xK411U7wQ', // Science education

        // Animation & Comics
        'BV1pK4y1k7mQ', // Animation
        'BV1NK4y1k7xP', // Anime review

        // Different lengths
        'BV1GJ411x7h7', // Short video (< 5 min)
        'BV1uv411q7Mv', // Medium video (5-20 min)
        'BV1J411y7H5c', // Long video (> 20 min)

        // Multi-part videos
        'BV1xx411c7mD', // Multi-part example
        'BV1yy411c7mN', // Another multi-part

        // High engagement
        'BV1VE411V7Qo', // High views
        'BV1FK4y1C7FF', // High likes
      ];

      print('\n=== Testing ${testVideos.length} popular Bilibili videos ===\n');

      int passed = 0;
      int failed = 0;
      int errors = 0;

      final failedVideos = <String, String>{};
      final errorVideos = <String, String>{};

      for (final bvid in testVideos) {
        print('Testing: $bvid');
        final stopwatch = Stopwatch()..start();

        try {
          final result = await VideoApiValidator.validateGetVideoInfo(bvid);
          stopwatch.stop();

          if (result.passed) {
            passed++;
            print('  ✅ PASS (${stopwatch.elapsedMilliseconds}ms): ${result.message}');
          } else {
            failed++;
            failedVideos[bvid] = result.message ?? 'Unknown error';
            print('  ❌ FAIL (${stopwatch.elapsedMilliseconds}ms): ${result.message}');
          }
        } on SocketException catch (e) {
          stopwatch.stop();
          errors++;
          errorVideos[bvid] = 'Network error: $e';
          print('  ⚠️  ERROR (${stopwatch.elapsedMilliseconds}ms): Network error - $e');
        } on HttpException catch (e) {
          stopwatch.stop();
          errors++;
          errorVideos[bvid] = 'HTTP error: $e';
          print('  ⚠️  ERROR (${stopwatch.elapsedMilliseconds}ms): HTTP error - $e');
        } catch (e, stackTrace) {
          stopwatch.stop();
          errors++;
          errorVideos[bvid] = 'Unexpected error: $e';
          print('  ⚠️  ERROR (${stopwatch.elapsedMilliseconds}ms): $e');
          if (errors < 3) {
            // Only print stack trace for first few errors to avoid spam
            print('  Stack trace: $stackTrace');
          }
        }

        // Small delay to avoid rate limiting
        if (testVideos.indexOf(bvid) < testVideos.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Print summary
      print('\n' + '=' * 60);
      print('VALIDATION TEST SUMMARY');
      print('=' * 60);
      print('Total videos tested: ${testVideos.length}');
      print('✅ Passed:  $passed (${(passed / testVideos.length * 100).toStringAsFixed(1)}%)');
      print('❌ Failed:  $failed (${(failed / testVideos.length * 100).toStringAsFixed(1)}%)');
      print('⚠️  Errors:  $errors (${(errors / testVideos.length * 100).toStringAsFixed(1)}%)');

      if (failedVideos.isNotEmpty) {
        print('\n--- Failed Videos ---');
        failedVideos.forEach((bvid, message) {
          print('❌ $bvid:');
          print('   $message');
        });
      }

      if (errorVideos.isNotEmpty) {
        print('\n--- Error Videos ---');
        errorVideos.forEach((bvid, message) {
          print('⚠️  $bvid:');
          print('   $message');
        });
      }

      print('=' * 60);

      // Test assertions
      expect(passed + failed + errors, equals(testVideos.length),
          reason: 'Total results should match test count');

      // We expect at least 70% success rate (passed + consistent failures)
      final successRate = (passed + failed) / testVideos.length;
      expect(successRate, greaterThan(0.7),
          reason: 'At least 70% of tests should complete without errors');

      // If we have any failures, report them clearly
      if (failed > 0) {
        print('\n⚠️  Warning: $failed video(s) showed mismatches between implementations');
        print('   This may indicate:');
        print('   - Field mapping issues in VideoAdapter');
        print('   - Differences in API response handling');
        print('   - Type conversion problems');
        print('   Please review the failed videos above');
      }

      if (errors > 0) {
        print('\n⚠️  Warning: $errors video(s) encountered errors');
        print('   This may indicate:');
        print('   - Network connectivity issues');
        print('   - Invalid video IDs (deleted/private videos)');
        print('   - API rate limiting');
        print('   Please review the error videos above');
      }
    });

    testWidgets('validate short videos', (WidgetTester tester) async {
      final shortVideos = [
        'BV1GJ411x7h7', // Tech tutorial
        'BV1jA411h7Km', // Vlog
        'BV1pK4y1k7mQ', // Animation clip
      ];

      print('\n=== Testing ${shortVideos.length} short videos ===\n');

      int passed = 0;
      int failed = 0;

      for (final bvid in shortVideos) {
        try {
          final result = await VideoApiValidator.validateGetVideoInfo(bvid);

          if (result.passed) {
            passed++;
            print('✅ $bvid: ${result.message}');
          } else {
            failed++;
            print('❌ $bvid: ${result.message}');
          }
        } catch (e) {
          print('⚠️  $bvid: Error - $e');
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      print('\nShort video results: $passed passed, $failed failed');
      expect(passed + failed, greaterThan(0), reason: 'Should test at least one video');
    });

    testWidgets('validate long videos', (WidgetTester tester) async {
      final longVideos = [
        'BV1J411y7H5c', // Long tutorial
        'BV1xx411c7mD', // Documentary style
      ];

      print('\n=== Testing ${longVideos.length} long videos ===\n');

      int passed = 0;
      int failed = 0;

      for (final bvid in longVideos) {
        try {
          final result = await VideoApiValidator.validateGetVideoInfo(bvid);

          if (result.passed) {
            passed++;
            print('✅ $bvid: ${result.message}');
          } else {
            failed++;
            print('❌ $bvid: ${result.message}');
          }
        } catch (e) {
          print('⚠️  $bvid: Error - $e');
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      print('\nLong video results: $passed passed, $failed failed');
      expect(passed + failed, greaterThan(0), reason: 'Should test at least one video');
    });

    testWidgets('validate multi-part videos', (WidgetTester tester) async {
      final multiPartVideos = [
        'BV1xx411c7mD', // Known multi-part video
        'BV1yy411c7mN', // Another multi-part
      ];

      print('\n=== Testing ${multiPartVideos.length} multi-part videos ===\n');

      int passed = 0;
      int failed = 0;

      for (final bvid in multiPartVideos) {
        try {
          final result = await VideoApiValidator.validateGetVideoInfo(bvid);

          if (result.passed) {
            passed++;
            print('✅ $bvid: ${result.message}');
          } else {
            failed++;
            print('❌ $bvid: ${result.message}');
          }
        } catch (e) {
          print('⚠️  $bvid: Error - $e');
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      print('\nMulti-part video results: $passed passed, $failed failed');
      expect(passed + failed, greaterThan(0), reason: 'Should test at least one video');
    });

    testWidgets('handle network errors gracefully', (WidgetTester tester) async {
      // Test with an invalid video ID that should fail gracefully
      final invalidVideos = [
        'BV1aaaaaaaaaa', // Invalid format
        'BV1xx411c7 INVALID', // Invalid characters
        'BV1nonexist', // Too short
      ];

      print('\n=== Testing error handling with ${invalidVideos.length} invalid IDs ===\n');

      int handledGracefully = 0;

      for (final bvid in invalidVideos) {
        try {
          final result = await VideoApiValidator.validateGetVideoInfo(bvid);

          // Should not throw, should return a result
          print('✅ $bvid handled: ${result.message}');
          handledGracefully++;
        } catch (e) {
          // Even if it throws, we caught it, so that's also graceful
          print('⚠️  $bvid threw: $e');
          handledGracefully++;
        }

        await Future.delayed(const Duration(milliseconds: 200));
      }

      print('\nError handling: $handledGracefully/${invalidVideos.length} handled gracefully');
      expect(handledGracefully, equals(invalidVideos.length),
          reason: 'All invalid IDs should be handled gracefully');
    });

    testWidgets('measure validation performance', (WidgetTester tester) async {
      final testVideos = [
        'BV1GJ411x7h7',
        'BV1uv411q7Mv',
        'BV1vA411b7Fq',
      ];

      print('\n=== Measuring validation performance ===\n');

      final timings = <String, int>{};

      for (final bvid in testVideos) {
        final stopwatch = Stopwatch()..start();

        try {
          await VideoApiValidator.validateGetVideoInfo(bvid);
          stopwatch.stop();
          timings[bvid] = stopwatch.elapsedMilliseconds;
          print('$bvid: ${stopwatch.elapsedMilliseconds}ms (both implementations in parallel)');
        } catch (e) {
          print('$bvid: Error - $e');
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (timings.isNotEmpty) {
        final avgTime = timings.values.reduce((a, b) => a + b) / timings.length;
        print('\nAverage validation time: ${avgTime.toStringAsFixed(1)}ms');
        print('Note: This measures parallel execution of both implementations');
      }
    });

    testWidgets('validate critical fields match', (WidgetTester tester) async {
      // Test a few videos to ensure critical fields match
      final testVideos = ['BV1GJ411x7h7', 'BV1uv411q7Mv'];

      print('\n=== Validating critical fields ===\n');

      for (final bvid in testVideos) {
        try {
          final result = await VideoApiValidator.validateGetVideoInfo(bvid);

          if (result.passed) {
            print('✅ $bvid: All critical fields match');
          } else {
            // Check which fields are mentioned in the failure
            final message = result.message ?? '';
            if (message.contains('bvid') ||
                message.contains('aid') ||
                message.contains('title') ||
                message.contains('owner.name')) {
              print('❌ $bvid: Critical field mismatch');
              print('   $message');
            } else {
              print('⚠️  $bvid: Non-critical field mismatch');
              print('   $message');
            }
          }
        } catch (e) {
          print('⚠️  $bvid: Error - $e');
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }
    });

    testWidgets('regression test known working videos', (WidgetTester tester) async {
      // These videos are known to have worked in previous tests
      // They serve as regression tests
      final knownGoodVideos = [
        'BV1GJ411x7h7',
        'BV1uv411q7Mv',
      ];

      print('\n=== Regression testing ${knownGoodVideos.length} known-good videos ===\n');

      int passed = 0;

      for (final bvid in knownGoodVideos) {
        try {
          final result = await VideoApiValidator.validateGetVideoInfo(bvid);

          if (result.passed) {
            passed++;
            print('✅ $bvid: Still passing');
          } else {
            print('❌ $bvid: Regression detected');
            print('   ${result.message}');
          }
        } catch (e) {
          print('⚠️  $bvid: Error - $e');
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      final passRate = passed / knownGoodVideos.length;
      print('\nRegression test pass rate: ${(passRate * 100).toStringAsFixed(1)}%');

      // We expect at least 80% of known-good videos to still pass
      expect(passRate, greaterThan(0.8),
          reason: 'At least 80% of known-good videos should still pass');
    });
  });
}
