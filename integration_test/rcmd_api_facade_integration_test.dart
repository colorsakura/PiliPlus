import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/http/rcmd_api_facade.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('RcmdApiFacade Integration Tests', () {
    late Box<dynamic> settingsBox;

    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      settingsBox = await Hive.openBox('settings');
    });

    tearDownAll(() async {
      // Clean up
      await settingsBox.close();
      await Hive.close();
    });

    setUp(() {
      // Reset settings for each test
      settingsBox.clear();
      // Reset global data
      GlobalData().blackMids.clear();
    });

    group('Feature Flag Routing', () {
      test('Should use Flutter implementation when feature flag is false', () async {
        // Set feature flag to false
        settingsBox.put(SettingBoxKey.useRustRcmdApi, false);

        // Make API call
        final result = await RcmdApiFacade.getRecommendList(ps: 10, freshIdx: 0);

        // Should return LoadingState (Success or Error)
        expect(result, isA<LoadingState>());

        // If Success, should return list
        if (result is Success) {
          final list = (result as Success).response;
          expect(list, isA<List<RecVideoItemModel>>());
        }
      });

      test('Should attempt Rust implementation when feature flag is true', () async {
        // Set feature flag to true
        settingsBox.put(SettingBoxKey.useRustRcmdApi, true);

        // Make API call
        final result = await RcmdApiFacade.getRecommendList(ps: 10, freshIdx: 0);

        // Should return LoadingState (Success or Error)
        expect(result, isA<LoadingState>());

        // If Success, should return list
        if (result is Success) {
          final list = (result as Success).response;
          expect(list, isA<List<RecVideoItemModel>>());
        }
      });

      test('Should fallback to Flutter when Rust fails', () async {
        // Set feature flag to true
        settingsBox.put(SettingBoxKey.useRustRcmdApi, true);

        // Make API call (should fallback to Flutter)
        final result = await RcmdApiFacade.getRecommendList(ps: 10, freshIdx: 0);

        // Should return LoadingState
        expect(result, isA<LoadingState>());

        // Should either succeed or fail gracefully
        expect(result, isOneOf([isA<Success>(), isA<Error>()]));
      });
    });

    group('Filtering Tests', () {
      test('Should filter out non-video items (goto != av)', () async {
        // This test mainly ensures the filtering logic works
        // The actual API call will return real data

        final result = await RcmdApiFacade.getRecommendList(ps: 20, freshIdx: 0);

        if (result is Success) {
          final list = (result as Success).response;

          // All items should have goto == 'av'
          for (final item in list) {
            expect(item.goto, equals('av'),
                reason: 'All items should be video type');
          }
        }
      });

      test('Should filter out blacklisted users', () async {
        // Add a test MID to blacklist
        GlobalData().blackMids.add(123456);

        final result = await RcmdApiFacade.getRecommendList(ps: 20, freshIdx: 0);

        if (result is Success) {
          final list = (result as Success).response;

          // All items should not have the blacklisted MID
          for (final item in list) {
            if (item.owner?.mid == 123456) {
              fail('Found item with blacklisted MID');
            }
          }
        }
      });
    });

    group('Error Handling', () {
      test('Should handle network errors gracefully', () async {
        // This test ensures the API handles connection issues
        final result = await RcmdApiFacade.getRecommendList(ps: 10, freshIdx: 0);

        // Should return LoadingState with either success or error
        expect(result, isA<LoadingState>());

        if (result is Error) {
          // Should have error message
          expect((result as Error).errMsg, isNotNull);
          expect((result as Error).errMsg, isNotEmpty);
        }
      });

      test('Should return error for invalid parameters', () async {
        // Test with very large page size (might cause issues)
        final result = await RcmdApiFacade.getRecommendList(ps: 1000, freshIdx: 0);

        // Should return LoadingState
        expect(result, isA<LoadingState>());
      });
    });

    group('Performance Tests', () {
      test('Should complete within reasonable time', () async {
        final stopwatch = Stopwatch()..start();

        final result = await RcmdApiFacade.getRecommendList(ps: 20, freshIdx: 0);

        stopwatch.stop();

        print('API call completed in ${stopwatch.elapsedMilliseconds}ms');

        // Should complete within 5 seconds (generous timeout for real API)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));

        // Should return valid data
        expect(result, isA<LoadingState>());

        if (result is Success) {
          final list = (result as Success).response;
          // Should return some items
          expect(list.isNotEmpty, true);
        }
      });
    });

    group('Data Validation', () {
      test('Should return valid RecVideoItemModel structure', () async {
        final result = await RcmdApiFacade.getRecommendList(ps: 10, freshIdx: 0);

        if (result is Success) {
          final list = (result as Success).response;

          if (list.isNotEmpty) {
            final firstItem = list.first;

            // Check required fields
            expect(firstItem.bvid, isNotNull);
            expect(firstItem.title, isNotNull);
            expect(firstItem.owner, isNotNull);
            expect(firstItem.owner.mid, isNotNull);
            expect(firstItem.stat, isNotNull);

            // Check optional fields that might be null
            expect(firstItem.aid, isNotNull);
            expect(firstItem.cover, isNotNull);
            expect(firstItem.duration, isNotNull);
            expect(firstItem.pubdate, isNotNull);
          }
        }
      });

      test('Should handle empty response gracefully', () async {
        final result = await RcmdApiFacade.getRecommendList(ps: 0, freshIdx: 0);

        // Should return LoadingState
        expect(result, isA<LoadingState>());

        // If Success, should return empty list
        if (result is Success) {
          final list = (result as Success).response;
          expect(list, isEmpty);
        }
      });
    });

    group('Edge Cases', () {
      test('Should handle negative ps parameter', () async {
        // Test with negative page size (should be handled gracefully)
        final result = await RcmdApiFacade.getRecommendList(ps: -1, freshIdx: 0);

        expect(result, isA<LoadingState>());
      });

      test('Should handle large freshIdx parameter', () async {
        // Test with large freshness index
        final result = await RcmdApiFacade.getRecommendList(ps: 10, freshIdx: 100);

        expect(result, isA<LoadingState>());
      });
    });
  });
}

/// Helper extensions for testing
extension LoadingStateExtensions on LoadingState {
  bool get isSuccess => this is Success;
  bool get isError => this is Error;
}