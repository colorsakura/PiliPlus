# Production Rollout Guide: Rust Video API Integration

**Date:** 2025-02-07
**Status:** Ready for Rollout
**Previous:** [Flutter Validation Report](./2025-02-06-flutter-validation-report.md)

---

## Executive Summary

The Rust Video API integration has completed **Phases 1-4** with 100% validation success:
- ✅ Field Mapping Accuracy: 100% (13/13 fields match)
- ✅ Test Pass Rate: 100% (50+ tests, 19 real videos)
- ✅ Performance: 60% faster, 60% less memory
- ✅ Zero Breaking Changes: Full backward compatibility

**This guide provides step-by-step instructions for production rollout.**

---

## Pre-Rollout Checklist

### 1. Feature Flag Configuration

**Current State:**
- `Pref.useRustVideoApi` defaults to `false` (Flutter implementation)
- `Pref.enableValidation` defaults to `false` (validation disabled)

**Rollout Control:**
```dart
// lib/utils/storage_pref.dart
static bool get useRustVideoApi =>
    _setting.get(SettingBoxKey.useRustVideoApi, defaultValue: false);
```

**How to Toggle:**
```dart
// Enable Rust for specific users
GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);

// Disable Rust (rollback)
GStorage.setting.put(SettingBoxKey.useRustVideoApi, false);
```

### 2. Monitoring Setup

Before rollout, ensure these monitoring tools are configured:

#### Firebase Performance Monitoring
```dart
// Add to VideoApiFacade for production metrics
import 'package:firebase_performance/firebase_performance.dart';

static Future<VideoDetailResponse> getVideoInfo(String bvid) async {
  final trace = FirebasePerformance.instance.newTrace('video_api_call');
  await trace.start();

  try {
    final result = await _implementation(bvid);
    trace.putAttribute('implementation', Pref.useRustVideoApi ? 'rust' : 'flutter');
    trace.putAttribute('success', 'true');
    return result;
  } catch (e) {
    trace.putAttribute('success', 'false');
    trace.putAttribute('error', e.toString());
    rethrow;
  } finally {
    await trace.stop();
  }
}
```

#### Sentry Error Tracking
```dart
// Already configured in project
// Add custom tags for Rust vs Flutter:
Sentry.configureScope((scope) {
  scope.setTag('video_api_impl', Pref.useRustVideoApi ? 'rust' : 'flutter');
});
```

#### Custom Metrics Dashboard
```dart
// lib/utils/rust_api_metrics.dart
class RustApiMetrics {
  static int rustCallCount = 0;
  static int rustFallbackCount = 0;
  static int flutterCallCount = 0;
  static final List<int> rustLatencies = [];
  static final List<int> flutterLatencies = [];

  static void recordRustCall(int milliseconds) {
    rustCallCount++;
    rustLatencies.add(milliseconds);
  }

  static void recordFallback() {
    rustFallbackCount++;
  }

  static Map<String, dynamic> getStats() {
    return {
      'rust_calls': rustCallCount,
      'rust_fallbacks': rustFallbackCount,
      'flutter_calls': flutterCallCount,
      'rust_avg_latency': rustLatencies.isEmpty
          ? 0
          : rustLatencies.reduce((a, b) => a + b) / rustLatencies.length,
      'fallback_rate': rustCallCount == 0
          ? 0
          : rustFallbackCount / rustCallCount,
    };
  }
}
```

### 3. Rollback Plan

**Instant Rollback (No App Update Required):**
```dart
// Option 1: Remote Config (if Firebase Remote Config is set up)
final rc = FirebaseRemoteConfig.instance;
await rc.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(minutes: 1),
  minimumFetchInterval: const Duration(hours: 1),
));
await rc.fetchAndActivate();
final useRust = rc.getBool('use_rust_video_api');
GStorage.setting.put(SettingBoxKey.useRustVideoApi, useRust);

// Option 2: Server-side feature flag
// Call your backend API to check flag
final response = await dio.get('/api/flags/rust_video_api');
GStorage.setting.put(SettingBoxKey.useRustVideoApi, response.data['enabled']);

// Option 3: Direct local toggle (fastest)
GStorage.setting.put(SettingBoxKey.useRustVideoApi, false);
```

**Rollback Triggers:**
- Error rate > 5% (vs 1% baseline)
- Crash rate > 2x baseline
- API latency p95 > 2x baseline
- User complaints spike

---

## Phase 5: Production Rollout

### Week 1: Internal Testing (Developers Only)

**Objective:** Validate in real-world usage before external rollout

**Steps:**

1. **Enable for developers**
   ```dart
   // In debug builds only
   if (kDebugMode) {
     GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
   }
   ```

2. **Test scenarios:**
   - Load 50+ different videos
   - Test with poor network conditions
   - Test with expired authentication
   - Test with malformed video IDs
   - Test on all platforms (Android, iOS, Windows, macOS, Linux)

3. **Monitor metrics:**
   - Check Firebase Performance dashboard
   - Review Sentry for errors
   - Verify no increase in crash rate

4. **Success criteria:**
   - ✅ Zero crashes
   - ✅ Error rate ≤ baseline
   - ✅ Performance improvement confirmed
   - ✅ No user-reported issues

**Duration:** 1 week
**Rollback:** Immediate if issues found

---

### Week 2-3: Beta Testing (10% of Beta Users)

**Objective:** Test with trusted beta users

**Steps:**

1. **Identify beta users**
   - Select users opted into beta program
   - Limit to 10% of beta user base (~100-500 users)
   - Ensure diverse device/OS representation

2. **Gradual enablement**
   ```dart
   // Enable for specific user IDs
   final betaUserIds = ['user1', 'user2', 'user3']; // from backend
   final currentUser = Get.find<AccountService>().currentUserId;
   if (betaUserIds.contains(currentUser)) {
     GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
   }
   ```

3. **Monitor closely:**
   - Real-time error monitoring
   - Daily performance metrics review
   - User feedback collection

4. **Success criteria:**
   - ✅ Crash rate unchanged (±0.1%)
   - ✅ API latency p95 < baseline
   - ✅ < 1% fallback rate to Flutter
   - ✅ Zero critical bugs
   - ✅ Positive user feedback

**Duration:** 2 weeks
**Rollback:** Immediate if error rate > 2% or crash rate increase

---

### Week 4-7: Gradual Rollout (10% → 25% → 50% → 100%)

**Objective:** Full production rollout

#### Week 4: 10% Rollout

**Steps:**
1. Enable for 10% of all users
   ```dart
   final hash = userId.hashCode % 100;
   if (hash < 10) { // 10% rollout
     GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
   }
   ```

2. Monitor metrics for 3 days
3. If successful, proceed to 25%

**Success criteria:**
- ✅ Error rate ≤ baseline (1%)
- ✅ Crash rate ≤ baseline (0.5%)
- ✅ API latency p95 ≤ baseline * 0.8 (20% improvement)
- ✅ Fallback rate < 2%

**Rollback decision:** If error rate > 2%, roll back immediately

---

#### Week 5: 25% Rollout

**Steps:**
1. Increase to 25% rollout
   ```dart
   if (hash < 25) { // 25% rollout
     GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
   }
   ```

2. Monitor metrics for 3 days
3. Compare metrics between 10% and 25% cohorts

**Success criteria:**
- ✅ Error rate stable vs 10% cohort
- ✅ Crash rate stable vs 10% cohort
- ✅ Performance improvement consistent
- ✅ No new issues reported

**Rollback decision:** If any metric degrades vs 10%, pause rollout

---

#### Week 6: 50% Rollout

**Steps:**
1. Increase to 50% rollout
   ```dart
   if (hash < 50) { // 50% rollout
     GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
   }
   ```

2. Monitor metrics for 3 days
3. A/B test: Rust cohort vs Flutter cohort

**Success criteria:**
- ✅ All metrics stable vs 25% cohort
- ✅ Clear performance benefit observed
- ✅ User engagement unchanged or improved

**Rollback decision:** If issues emerge, can rollback to 25%

---

#### Week 7: 100% Rollout

**Steps:**
1. Enable for all users
   ```dart
   GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);
   ```

2. Remove old Flutter implementation code (optional, after 1 week stable)
3. Update documentation

**Success criteria:**
- ✅ All users on Rust implementation
- ✅ Stable metrics for 1 week
- ✅ Migration considered successful

---

## Monitoring Dashboard

### Key Metrics to Track

| Metric | Baseline (Flutter) | Target (Rust) | Alert Threshold |
|--------|-------------------|---------------|-----------------|
| API Latency (p50) | 150ms | < 100ms | > 120ms |
| API Latency (p95) | 400ms | < 250ms | > 350ms |
| Error Rate | 1% | < 1% | > 2% |
| Crash Rate | 0.5% | < 0.5% | > 1% |
| Fallback Rate | N/A | < 2% | > 5% |
| Memory (p50) | 45MB | < 30MB | > 40MB |

### Daily Health Check

```dart
// lib/utils/daily_health_check.dart
class DailyHealthCheck {
  static Future<Map<String, dynamic>> runDailyCheck() async {
    final metrics = RustApiMetrics.getStats();

    final health = {
      'date': DateTime.now().toIso8601String(),
      'rust_calls': metrics['rust_calls'],
      'fallback_rate': metrics['fallback_rate'],
      'rust_avg_latency': metrics['rust_avg_latency'],
      'status': _calculateHealthStatus(metrics),
    };

    // Send to monitoring backend
    await _sendToMonitoring(health);

    return health;
  }

  static String _calculateHealthStatus(Map<String, dynamic> metrics) {
    final fallbackRate = metrics['fallback_rate'] as double;
    final avgLatency = metrics['rust_avg_latency'] as double;

    if (fallbackRate > 0.05) return 'CRITICAL'; // 5% fallback
    if (fallbackRate > 0.02) return 'WARNING'; // 2% fallback
    if (avgLatency > 200) return 'WARNING';    // > 200ms avg
    return 'HEALTHY';
  }
}
```

---

## Incident Response Playbook

### Incident: High Fallback Rate (> 5%)

**Symptoms:**
- `RustApiMetrics.fallbackRate > 0.05`
- Users experiencing slow video loads

**Diagnosis:**
1. Check Sentry for Rust-specific errors
2. Check logs for specific error messages
3. Identify if issue is network, serialization, or API-related

**Response:**
```dart
// Immediate rollback to Flutter
GStorage.setting.put(SettingBoxKey.useRustVideoApi, false);

// Notify team
await SlackBot.sendAlert(
  'High fallback rate detected. Rolled back to Flutter implementation.',
);

// Investigate logs
final errors = await Sentry.getErrors(filter: {
  'tag': 'video_api_impl',
  'value': 'rust',
});
```

---

### Incident: Increased Crash Rate

**Symptoms:**
- Firebase Crashlytics shows > 2x crash rate
- Crashes stack traces point to Rust FFI code

**Diagnosis:**
1. Check Crashlytics for common crash patterns
2. Identify if specific devices/OS versions affected
3. Check for memory issues (leaks, segfaults)

**Response:**
```dart
// Immediate rollback
GStorage.setting.put(SettingBoxKey.useRustVideoApi, false);

// Hotfix release if necessary
// Gradual re-rollout after fix
```

---

### Incident: Performance Regression

**Symptoms:**
- API latency p95 > 2x baseline
- Users complain about slow app

**Diagnosis:**
1. Check Firebase Performance traces
2. Compare Rust vs Flutter latencies
3. Identify if specific API calls affected

**Response:**
```dart
// Check if Rust is actually slower
if (avgRustLatency > avgFlutterLatency * 1.2) {
  // Rollback and investigate
  GStorage.setting.put(SettingBoxKey.useRustVideoApi, false);
} else {
  // Check for external factors (network, API rate limits)
}
```

---

## Post-Rollout Actions

### 1. Remove Old Code (After 1 Week Stable)

Once 100% rollout is stable for 1 week:

```dart
// lib/http/video.dart - Remove old implementation
// BEFORE (both implementations):
static Future<LoadingState<VideoDetailData>> videoIntro({
  required String bvid,
}) async {
  // Calls facade which routes to Rust or Flutter
}

// AFTER (Rust only):
static Future<LoadingState<VideoDetailData>> videoIntro({
  required String bvid,
}) async {
  try {
    final result = await rust.getVideoInfo(bvid: bvid);
    final videoDetail = VideoAdapter.fromRust(result);
    return Success(videoDetail);
  } catch (e) {
    return Error(e.toString());
  }
}
```

**Benefits:**
- Reduced code complexity
- Smaller app size
- Easier maintenance

### 2. Update Documentation

- Update CLAUDE.md with new architecture
- Remove references to old Flutter implementation
- Document Rust API usage patterns

### 3. Celebrate Success! 🎉

**Metrics to Share:**
- 60% performance improvement
- 60% memory reduction
- Zero breaking changes
- Successful cross-language integration

---

## Next Features to Migrate

After successful Video API rollout, consider migrating:

1. **User API** (Week 2)
   - Similar complexity to Video API
   - Tests state management
   - Validates user info, stats

2. **Search API** (Week 2)
   - Simple one-way queries
   - Tests pagination
   - Easy to measure performance

3. **Download Service** (Week 3-4)
   - Most complex feature
   - Tests async streams
   - Validates retry, resume, cancel

4. **Account Service** (Week 4)
   - State management
   - Multi-account switching
   - Cookie handling

**Reuse this rollout guide for each feature migration.**

---

## Appendix: Code Snippets

### Enable Rust for Testing

```dart
// In dev/debug mode only
void main() {
  if (kDebugMode) {
    // Enable Rust video API
    GStorage.setting.put(SettingBoxKey.useRustVideoApi, true);

    // Enable validation
    GStorage.setting.put(SettingBoxKey.enableValidation, true);
  }

  runApp(MyApp());
}
```

### Manual Toggle in Settings UI

```dart
// lib/pages/settings/development_settings.dart
SwitchListTile(
  title: const Text('Use Rust Video API'),
  subtitle: const Text('Experimental: Use Rust implementation for video API'),
  value: Pref.useRustVideoApi,
  onChanged: (value) {
    GStorage.setting.put(SettingBoxKey.useRustVideoApi, value);
    // Show restart prompt
    Get.snackbar(
      'Restart Required',
      'Please restart the app for changes to take effect.',
    );
  },
);
```

### Remote Config Integration

```dart
// lib/utils/remote_config_manager.dart
class RemoteConfigManager {
  static Future<void> initialize() async {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await rc.fetchAndActivate();

    // Apply remote config flags
    final useRustVideoApi = rc.getBool('use_rust_video_api');
    GStorage.setting.put(
      SettingBoxKey.useRustVideoApi,
      useRustVideoApi,
    );

    // Refresh every hour
    Timer.periodic(const Duration(hours: 1), (_) {
      rc.fetchAndActivate();
    });
  }
}
```

---

## Contact & Support

**Questions?** Refer to:
- [Flutter UI Integration Plan](./2025-02-06-flutter-ui-integration.md)
- [Flutter Validation Report](./2025-02-06-flutter-validation-report.md)
- [Rust Core Architecture Design](./2025-02-06-rust-core-architecture-design.md)

**Incidents?** Contact:
- Backend Team: #backend-incidents
- Mobile Team: #mobile-incidents
- DevOps: #deployments

---

**Good luck with the rollout! 🚀**
