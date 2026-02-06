import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';

/// Manager for Week 2-3 Beta Testing of Rust Video API.
///
/// This class handles:
/// - Beta user identification and allocation
/// - Hash-based rollout percentage
/// - Metrics tracking specific to beta testing
/// - Rollback safety mechanisms
///
/// **Usage:**
/// ```dart
/// // In main.dart, after GStorage.init()
/// await BetaTestingManager.initialize();
/// ```
class BetaTestingManager {
  BetaTestingManager._();

  static bool _initialized = false;
  static Timer? _metricsPersistTimer;

  /// Initialize beta testing manager.
  ///
  /// Should be called once during app startup, after GStorage.init().
  /// This will:
  /// 1. Check if user is in beta cohort
  /// 2. Enable Rust API if eligible
  /// 3. Set up periodic metrics persistence
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('[BetaTesting] Already initialized');
      return;
    }

    debugPrint('\n=== Week 2-3 Beta Testing Initialization ===');

    // Check if beta testing is enabled
    final betaTestingEnabled = GStorage.setting.get(
      SettingBoxKey.betaTestingEnabled,
      defaultValue: false,
    );

    if (!betaTestingEnabled) {
      debugPrint('[BetaTesting] Beta testing not enabled');
      _initialized = true;
      return;
    }

    // Get rollout percentage
    final rolloutPercentage = GStorage.setting.get(
      SettingBoxKey.betaRolloutPercentage,
      defaultValue: 10, // Start with 10%
    );

    // Check if user should be included
    final isInBeta = _isUserInBetaCohort(rolloutPercentage);

    if (isInBeta) {
      // Enable Rust API for this user
      GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);

      final currentUserId = _getCurrentUserId();
      debugPrint('[BetaTesting] ✅ User $currentUserId included in beta cohort ($rolloutPercentage% rollout)');
      debugPrint('[BetaTesting] Rust Video API enabled');

      // Start periodic metrics persistence (every hour)
      _startPeriodicMetricsPersistence();

    } else {
      debugPrint('[BetaTesting] ❌ User not in beta cohort ($rolloutPercentage% rollout)');
      debugPrint('[BetaTesting] Rust Video API disabled (using Flutter)');
    }

    _initialized = true;
    debugPrint('=== Beta Testing Initialization Complete ===\n');
  }

  /// Check if current user is in beta cohort based on hash of user ID.
  ///
  /// Uses consistent hashing to ensure the same user always gets the same result.
  ///
  /// **Parameters:**
  /// - [rolloutPercentage]: Percentage of users to include (0-100)
  ///
  /// **Returns:**
  /// - `true` if user should be in beta cohort
  /// - `false` otherwise
  static bool _isUserInBetaCohort(int rolloutPercentage) {
    // Ensure rollout percentage is valid
    final validPercentage = rolloutPercentage.clamp(0, 100);

    // Get current user ID
    final userId = _getCurrentUserId();

    if (userId.isEmpty) {
      // No user ID, don't include in beta
      debugPrint('[BetaTesting] No user ID available, excluding from beta');
      return false;
    }

    // Hash the user ID and map to 0-100 range
    final hash = userId.hashCode.abs();
    final userPercent = hash % 100;

    // Check if user falls within rollout percentage
    final isInCohort = userPercent < validPercentage;

    if (kDebugMode) {
      debugPrint('[BetaTesting] User ID hash: $hash → $userPercent%');
      debugPrint('[BetaTesting] Rollout threshold: $validPercentage%');
      debugPrint('[BetaTesting] In cohort: $isInCohort');
    }

    return isInCohort;
  }

  /// Get current user ID for beta cohort allocation.
  ///
  /// Priority:
  /// 1. Logged-in user ID from AccountService
  /// 2. Device ID from storage
  /// 3. Generated random UUID (persisted)
  static String _getCurrentUserId() {
    // Try to get logged-in user ID
    try {
      // This would typically come from your AccountService
      // For now, use a device-specific ID
      final deviceId = GStorage.localCache.get('beta_device_id');
      if (deviceId != null && deviceId is String) {
        return deviceId;
      }

      // Generate and store device ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecondsSinceEpoch % 10000;
      final newDeviceId = 'device_${timestamp}_$random';
      GStorage.localCache.put('beta_device_id', newDeviceId);
      return newDeviceId;
    } catch (e) {
      debugPrint('[BetaTesting] Error getting user ID: $e');
      return '';
    }
  }

  /// Get current beta testing status.
  static Map<String, dynamic> getStatus() {
    final betaTestingEnabled = GStorage.setting.get(
      SettingBoxKey.betaTestingEnabled,
      defaultValue: false,
    );

    final rolloutPercentage = GStorage.setting.get(
      SettingBoxKey.betaRolloutPercentage,
      defaultValue: 10,
    );

    final isInBeta = betaTestingEnabled && _isUserInBetaCohort(rolloutPercentage);

    final rustApiEnabled = GStorage.setting.get(
      SettingBoxKey.useRustVideoApi,
      defaultValue: false,
    );

    return {
      'beta_testing_enabled': betaTestingEnabled,
      'rollout_percentage': rolloutPercentage,
      'is_in_beta_cohort': isInBeta,
      'rust_api_enabled': rustApiEnabled,
      'user_id': _getCurrentUserId(),
    };
  }

  /// Start periodic metrics persistence.
  ///
  /// Persists metrics to local storage every hour for analysis.
  static void _startPeriodicMetricsPersistence() {
    _metricsPersistTimer?.cancel();
    _metricsPersistTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _persistMetrics();
    });
  }

  /// Persist current metrics to local storage.
  static Future<void> _persistMetrics() async {
    try {
      final stats = RustApiMetrics.getStats();
      final status = getStatus();

      final metricsSnapshot = {
        'timestamp': DateTime.now().toIso8601String(),
        'beta_status': status,
        'metrics': stats,
        'health': RustApiMetrics.calculateHealthStatus(),
      };

      final key = 'beta_metrics_${DateTime.now().millisecondsSinceEpoch}';
      await GStorage.localCache.put(key, metricsSnapshot);

      if (kDebugMode) {
        debugPrint('[BetaTesting] Metrics persisted: $key');
      }
    } catch (e) {
      debugPrint('[BetaTesting] Error persisting metrics: $e');
    }
  }

  /// Force immediate rollback to Flutter implementation.
  ///
  /// Use this if critical issues are detected during beta testing.
  ///
  /// **Parameters:**
  /// - [reason]: Reason for rollback (logged)
  static Future<void> emergencyRollout({String? reason}) async {
    debugPrint('\n❌ EMERGENCY ROLLOUT TRIGGERED');
    if (reason != null) {
      debugPrint('Reason: $reason');
    }

    // Disable Rust API
    GStorage.setting.put(SettingBoxKey.useRustVideoApi, false);

    // Disable beta testing
    GStorage.setting.put(SettingBoxKey.betaTestingEnabled, false);

    // Log metrics before rollback
    await _persistMetrics();

    debugPrint('Rust Video API disabled');
    debugPrint('Beta testing disabled');
    debugPrint('Users reverted to Flutter implementation');
    debugPrint('EMERGENCY ROLLOUT COMPLETE\n');
  }

  /// Gradually increase rollout percentage.
  ///
  /// Use this to safely increase beta cohort size.
  ///
  /// **Parameters:**
  /// - [newPercentage]: New rollout percentage (0-100)
  ///
  /// **Returns:**
  /// - `true` if percentage was updated
  /// - `false` if invalid percentage
  static bool increaseRolloutPercentage(int newPercentage) {
    if (newPercentage < 0 || newPercentage > 100) {
      debugPrint('[BetaTesting] Invalid rollout percentage: $newPercentage');
      return false;
    }

    final currentPercentage = GStorage.setting.get(
      SettingBoxKey.betaRolloutPercentage,
      defaultValue: 10,
    );

    if (newPercentage <= currentPercentage) {
      debugPrint('[BetaTesting] New percentage ($newPercentage%) must be greater than current ($currentPercentage%)');
      return false;
    }

    GStorage.setting.put(SettingBoxKey.betaRolloutPercentage, newPercentage);

    debugPrint('\n📈 Rollout percentage increased: $currentPercentage% → $newPercentage%');

    // Re-initialize to apply new percentage
    final isInBeta = _isUserInBetaCohort(newPercentage);
    if (isInBeta) {
      GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
      debugPrint('[BetaTesting] Rust API enabled for user at new percentage');
    } else {
      GStorage.setting.put(SettingBoxKey.useRustVideoApi, false);
      debugPrint('[BetaTesting] Rust API disabled for user at new percentage');
    }

    debugPrint('Rollout increase complete\n');
    return true;
  }

  /// Get beta testing summary report.
  static String getSummaryReport() {
    final status = getStatus();
    final stats = RustApiMetrics.getStats();
    final health = RustApiMetrics.calculateHealthStatus();

    final buffer = StringBuffer();

    buffer.writeln('╔════════════════════════════════════════════════════════╗');
    buffer.writeln('║     Week 2-3 Beta Testing - Status Report             ║');
    buffer.writeln('╚════════════════════════════════════════════════════════╝');
    buffer.writeln('');

    buffer.writeln('📊 Beta Testing Status:');
    buffer.writeln('   Enabled: ${status['beta_testing_enabled']}');
    buffer.writeln('   Rollout: ${status['rollout_percentage']}%');
    buffer.writeln('   In Cohort: ${status['is_in_beta_cohort']}');
    buffer.writeln('   Rust API: ${status['rust_api_enabled']}');
    buffer.writeln('   User ID: ${status['user_id']}');
    buffer.writeln('');

    buffer.writeln('📈 Performance Metrics:');
    buffer.writeln('   Rust Calls: ${stats['rust_calls']}');
    buffer.writeln('   Flutter Calls: ${stats['flutter_calls']}');
    buffer.writeln('   Fallbacks: ${stats['rust_fallbacks']}');
    buffer.writeln('   Errors: ${stats['errors']}');

    if (stats['rust_avg_latency'] != null && (stats['rust_avg_latency'] as double) > 0) {
      buffer.writeln('   Avg Latency: ${(stats['rust_avg_latency'] as double).toStringAsFixed(2)}ms');
      buffer.writeln('   P50 Latency: ${(stats['rust_p50_latency'] as double).toStringAsFixed(2)}ms');
      buffer.writeln('   P95 Latency: ${(stats['rust_p95_latency'] as double).toStringAsFixed(2)}ms');
    }

    final fallbackRate = stats['rust_fallbacks'] == 0
        ? 0.0
        : (stats['rust_fallbacks'] as int) / (stats['rust_calls'] as int);
    buffer.writeln('   Fallback Rate: ${(fallbackRate * 100).toStringAsFixed(2)}%');
    buffer.writeln('');

    buffer.writeln('💚 Health Status: $health');
    buffer.writeln('');

    if (health == 'HEALTHY') {
      buffer.writeln('✅ Beta Testing Status: OPERATIONAL');
      buffer.writeln('   No issues detected. Continue monitoring.');
    } else if (health == 'WARNING') {
      buffer.writeln('⚠️  Beta Testing Status: ATTENTION NEEDED');
      buffer.writeln('   Some metrics show warnings. Review logs.');
    } else {
      buffer.writeln('❌ Beta Testing Status: CRITICAL');
      buffer.writeln('   Consider emergency rollout. Check logs immediately.');
    }

    buffer.writeln('');
    buffer.writeln('╔════════════════════════════════════════════════════════╗');

    return buffer.toString();
  }

  /// Cleanup resources when app is shutting down.
  static void dispose() {
    _metricsPersistTimer?.cancel();
    _metricsPersistTimer = null;
    _initialized = false;
    debugPrint('[BetaTesting] Disposed');
  }
}
