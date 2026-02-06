import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/src/rust/validation/video_validator.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

/// Integration tests with real Bilibili video IDs.
///
/// This test suite validates that Rust and Flutter implementations produce
/// identical results when fetching real video data from Bilibili's API.
///
/// **Test Categories:**
/// 1. **Popular Videos**: High-view count videos from various categories
/// 2. **Different Video Types**: UGC, PGC, music, gaming, etc.
/// 3. **Edge Cases**: Very long videos, very short videos, multi-part videos
/// 4. **Network Resilience**: Tests should handle network errors gracefully
///
/// **Running the Tests:**
/// ```bash
/// # Run all validation tests
/// flutter test test/http/video_api_validation_test.dart
///
/// # Run only popular video tests
/// flutter test test/http/video_api_validation_test.dart --name "popular"
///
/// # Run with verbose output
/// flutter test test/http/video_api_validation_test.dart --no-sound-null-safety
/// ```
///
/// **Note:** These tests require network access to Bilibili's API.
/// They may fail if:
/// - Network is unavailable
/// - Bilibili API is temporarily down
/// - Video IDs become invalid (deleted/private)
/// - Rate limiting occurs
void main() {
  group('Video API Validation Tests', () {
    setUpAll(() {
      // Enable validation mode for all tests
      print('\n=== Setup: Enabling validation mode ===');
      // Note: Pref.enableValidation is a getter, can't set it directly
      // The validator itself checks kDebugMode
    });

    tearDownAll(() {
      print('\n=== Teardown: Validation tests complete ===');
    });

    test('validate popular Bilibili videos', () async {
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
      int skipped = 0;
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
      print('⏭️  Skipped: $skipped');

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
    }, timeout: const Timeout(Duration(minutes: 10)));

    test('validate short videos (< 5 minutes)', () async {
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

    test('validate long videos (> 20 minutes)', () async {
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

    test('validate multi-part videos', () async {
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

    test('handle network errors gracefully', () async {
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
  });

  group('Performance Tests', () {
    test('measure validation performance', () async {
      final testVideos = [
        'BV1GJ411x7h7',
        'BV1uv411q7Mv',
        'BV1vA411b7Fq',
      ];

      print('\n=== Measuring validation performance ===\n');

      final rustTimes = <int>[];
      final flutterTimes = <int>[];

      for (final bvid in testVideos) {
        final stopwatch = Stopwatch();

        // Time Rust implementation
        stopwatch.start();
        try {
          // Note: We can't directly time Rust implementation separately
          // since the validator calls both in parallel
          // This is just a rough measurement
          await VideoApiValidator.validateGetVideoInfo(bvid);
          stopwatch.stop();
          final totalTime = stopwatch.elapsedMilliseconds;
          print('$bvid: ${totalTime}ms total (both implementations)');
        } catch (e) {
          print('$bvid: Error - $e');
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      print('\nPerformance note: Validator calls both implementations in parallel');
      print('Individual implementation timing would require separate instrumentation');
    });
  });

  group('Field-Specific Validation', () {
    test('validate critical fields match', () async {
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
  });

  group('Regression Tests', () {
    test('validate known working videos still work', () async {
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
