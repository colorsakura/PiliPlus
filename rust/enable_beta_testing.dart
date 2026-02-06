/// Enable Week 2-3 Beta Testing for Rust Video API
/// Run with: dart enable_beta_testing.dart

import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';

Future<void> main() async {
  print('=== Enabling Beta Testing ===\n');

  // Initialize storage
  await GStorage.init();
  print('✓ Storage initialized');

  // Enable beta testing
  GStorage.setting.put(SettingBoxKey.betaTestingEnabled, true);
  print('✓ Beta testing enabled');

  // Set rollout percentage to 10%
  GStorage.setting.put(SettingBoxKey.betaRolloutPercentage, 10);
  print('✓ Rollout percentage set to 10%');

  // Verify settings
  final enabled = GStorage.setting.get(
    SettingBoxKey.betaTestingEnabled,
    defaultValue: false,
  );
  final rollout = GStorage.setting.get(
    SettingBoxKey.betaRolloutPercentage,
    defaultValue: 0,
  );

  print('\n=== Current Settings ===');
  print('Beta Testing: ${enabled ? "ENABLED ✅" : "DISABLED ❌"}');
  print('Rollout: $rollout%');

  // Check if current user is in beta cohort
  print('\n=== User Allocation Check ===');
  
  // Get device ID (used for hash-based allocation)
  final deviceId = GStorage.localCache.get('beta_device_id');
  if (deviceId != null) {
    print('Device ID: $deviceId');
    
    // Simple hash check (same logic as BetaTestingManager)
    final hash = deviceId.toString().hashCode.abs();
    final userPercent = hash % 100;
    final isInCohort = userPercent < rollout;
    
    print('User hash value: $userPercent%');
    print('Rollout threshold: $rollout%');
    print('In beta cohort: ${isInCohort ? "YES ✅" : "NO ❌"}');
    
    if (isInCohort) {
      print('\n🎉 This device IS in the beta cohort!');
      print('   Rust Video API will be ENABLED for this device.');
    } else {
      print('\n⚠️  This device is NOT in the beta cohort.');
      print('   Rust Video API will use Flutter implementation.');
      print('   Try increasing rollout percentage if needed.');
    }
  } else {
    print('⚠️  No device ID found yet.');
    print('   Device ID will be generated on next app launch.');
  }

  print('\n=== Beta Testing Enabled ===');
  print('Next steps:');
  print('1. Restart the app');
  print('2. Check for "Week 2-3 Beta Testing Initialization" message');
  print('3. Look for Rust API calls in logs: [RustMetrics] Rust call');
  print('\nTo disable: GStorage.setting.put(SettingBoxKey.betaTestingEnabled, false);');
}
