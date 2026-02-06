/// Test script to verify Rust Video API is working after tokio runtime fix

import 'package:PiliPlus/src/rust/frb_generated.dart';
import 'package:PiliPlus/src/rust/api/video.dart' as rust;
import 'package:PiliPlus/src/rust/models/video.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage.dart';

Future<void> main() async {
  print('=== Rust Video API Test ===\n');

  // Initialize storage
  await GStorage.init();
  print('✓ Storage initialized');

  // Initialize Rust bridge
  try {
    await RustLib.init();
    print('✓ Rust bridge initialized successfully');
  } catch (e) {
    print('✗ Rust bridge initialization failed: $e');
    return;
  }

  // Enable Rust API for testing
  GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
  print('✓ Rust Video API enabled\n');

  // Test: Get video info
  print('Test: Getting video info for BV1xx411c7mD...');
  final testBvid = 'BV1xx411c7mD';

  try {
    final stopwatch = Stopwatch()..start();
    final videoInfo = await rust.getVideoInfo(bvid: testBvid);
    stopwatch.stop();

    print('✓ SUCCESS: Got video info in ${stopwatch.elapsedMilliseconds}ms');
    print('  Title: ${videoInfo.title}');
    print('  BV ID: ${videoInfo.bvid}');
    print('  Owner: ${videoInfo.owner.name}');
    print('  Views: ${videoInfo.stats.viewCount}');
  } catch (e) {
    print('✗ FAILED: $e');
  }

  print('\n=== Test Complete ===');
}
