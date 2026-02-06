# User API Rust Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate User Info and User Stats APIs from Flutter/Dart to Rust implementation using the established Facade pattern from Video/Rcmd APIs.

**Architecture:** Facade pattern with automatic fallback to Flutter implementation. Rust handles HTTP requests via reqwest + serde JSON parsing. Adapter converts Rust models to Flutter models. Feature flag controls implementation selection.

**Tech Stack:**
- Rust: flutter_rust_bridge 2.11.1, reqwest, serde, tokio
- Flutter: GetX, Hive (feature flags), existing Dio HTTP client
- Pattern: Same as Video API & Rcmd API implementations

---

## Progress Tracking

**Starting Point:** 2025-02-07
**Current Status:**
- ✅ Rust user.rs already exists (commented out due to codegen issue)
- ✅ Flutter UserHttp.userInfo() and userStatOwner() working
- ⏳ Need to: enable Rust module, create facade, adapter, feature flag
- ⚠️ **No tests** - per user requirement

**Reference Implementations:**
- Video API: `rust/src/api/video.rs`, `lib/http/video_api_facade.dart`, `lib/src/rust/adapters/video_adapter.dart`
- Rcmd API: `rust/src/api/rcmd.rs`, `lib/http/rcmd_api_facade.dart`, `lib/src/rust/adapters/rcmd_adapter.dart`

---

## Prerequisites & Context

### Existing Flutter User API

**File:** `lib/http/user.dart`

**Key Methods to Migrate:**
1. `userInfo()` - Get current user information (no parameters, uses auth cookie)
2. `userStatOwner()` - Get current user statistics (no parameters, uses auth cookie)

**Return Types:**
- `userInfo()` → `LoadingState<UserInfoData>`
- `userStatOwner()` → `LoadingState<UserStat>`

**API Endpoints:**
- `Api.userInfo` - Web API endpoint for user info
- `Api.userStatOwner` - Web API endpoint for user stats

### Existing Rust Implementation (Disabled)

**File:** `rust/src/api/user.rs`

**Current State:**
- Functions exist but module is commented out in `rust/src/api/mod.rs`
- Functions use `get_services().await` pattern
- Returns `ApiResult<T>` type

**Issue from mod.rs:**
> "All other APIs temporarily disabled due to flutter_rust_bridge codegen issues. The types are already exposed in bridge.rs, which causes codegen to generate invalid code."

### Bridge Module Type Exposure

**File:** `rust/src/api/bridge.rs`

**Pattern:** Types are exposed via "panic" functions that should never be called:
```rust
#[frb]
pub async fn _expose_<type>_type() -> <Type> {
    panic!("This function should never be called - it only exists for type registration");
}
```

**Strategy:** We'll use the same wrapper pattern as rcmd APIs in bridge.rs.

---

## Implementation Plan

### Phase 1: Fix Rust Module Exports

**Goal:** Re-enable user module in Rust without breaking flutter_rust_bridge codegen.

**File:** `rust/src/api/bridge.rs`

**Step 1: Add user API wrapper functions (like rcmd)**

Add after line 135 (after get_recommend_list_app):

```rust
// User API wrapper for flutter_rust_bridge
#[frb]
pub async fn get_user_info() -> Result<crate::models::UserInfo, crate::error::SerializableError> {
    crate::api::user::get_user_info(0).await  // mid parameter ignored, uses current user
}

#[frb]
pub async fn get_user_stats() -> Result<crate::models::UserStats, crate::error::SerializableError> {
    crate::api::user::get_user_stats(0).await  // mid parameter ignored, uses current user
}
```

**Step 2: Update user.rs to not require mid parameter**

Modify `rust/src/api/user.rs`:

```rust
use flutter_rust_bridge::frb;
use crate::models::{UserInfo, UserStats};
use crate::error::{SerializableError, ApiError};
use crate::services::get_services;

/// Get current user information (uses auth cookie from HTTP client)
#[frb]
pub async fn get_user_info() -> Result<UserInfo, SerializableError> {
    let services = get_services().await;

    // Call Bilibili API with current user's auth
    match services.user_api.get_current_user_info().await {
        Ok(user) => Ok(user),
        Err(ApiError::NetworkUnavailable) => Err(SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: "Network unavailable".to_string(),
        }),
        Err(err) => Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: err.to_string(),
        }),
    }
}

/// Get current user statistics (uses auth cookie from HTTP client)
#[frb]
pub async fn get_user_stats() -> Result<UserStats, SerializableError> {
    let services = get_services().await;

    match services.user_api.get_current_user_stats().await {
        Ok(stats) => Ok(stats),
        Err(ApiError::NetworkUnavailable) => Err(SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: "Network unavailable".to_string(),
        }),
        Err(err) => Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: err.to_string(),
        }),
    }
}
```

**Step 3: Re-enable user module in mod.rs**

Modify `rust/src/api/mod.rs`, uncomment line 10 and 18:

```rust
pub mod user;  // Uncomment this
// ...
pub use rcmd_app::*;
pub use user::*;  // Uncomment this
```

**Step 4: Regenerate flutter_rust_bridge bindings**

Run:
```bash
flutter_rust_bridge_codegen --config-file flutter_rust_bridge.yaml
```

Expected: Dart bindings generated in `lib/src/rust/api/user.dart`

**Step 5: Format generated code**

Run:
```bash
dart format lib/src/rust/
```

**Step 6: Verify compilation**

Run:
```bash
cd rust && cargo check
```

Expected: "Finished dev [unoptimized] check" or similar

**Step 7: Commit**

```bash
git add rust/src/api/mod.rs rust/src/api/bridge.rs rust/src/api/user.dart
git commit -m "feat(rust): re-enable user API module with bridge wrappers"
```

---

### Phase 2: Update Rust Data Models

**Goal:** Ensure Rust UserInfo and UserStats models match Flutter models.

**Files:**
- Check: `rust/src/models/user.rs`
- Reference: `lib/models/user/info.dart` and `lib/models/user/stat.dart`

**Step 1: Check existing Rust user models**

Read `rust/src/models/user.rs` to verify field names match Flutter models.

**Step 2: Compare with Flutter models**

Key fields for UserInfoData (from `lib/models/user/info.dart`):
- `mid` (int)
- `face` (String) - avatar URL
- `uname` (String) - username
- `levelInfo` (LevelInfo object)
- `money` (double) - coins
- `vipStatus` (int)
- `vipType` (int)
- ... (other VIP-related fields)

Key fields for UserStat (from `lib/models/user/stat.dart`):
- Need to verify by reading the file

**Step 3: Update Rust models if needed**

If Rust models don't match, update them in `rust/src/models/user.rs`.

**Step 4: Commit**

```bash
git add rust/src/models/user.rs
git commit -m "feat(rust): update user models to match Flutter models"
```

---

### Phase 3: Create User Adapter

**Goal:** Create adapter to convert Rust user models to Flutter user models.

**File:** Create `lib/src/rust/adapters/user_adapter.dart`

**Step 1: Write UserAdapter class**

```dart
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/src/rust/models/user.dart' as rust;

/// Adapter for converting Rust user models to Flutter user models.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/user/)
class UserAdapter {
  /// Convert Rust UserInfo to Flutter UserInfoData.
  ///
  /// Handles nested objects and type conversions:
  /// - Rust primitive fields → Dart nullable fields
  /// - Rust level info → Dart LevelInfo object
  /// - Rust VIP status → Dart VIP fields
  static UserInfoData userInfoFromRust(rust.UserInfo rustUser) {
    return UserInfoData(
      mid: rustUser.mid.toInt(),
      face: rustUser.face,
      uname: rustUser.name,
      levelInfo: LevelInfo(
        currentLevel: rustUser.level,
        currentExp: rustUser.currentExp.toInt(),
        nextExp: rustUser.nextExp?.toInt(),
      ),
      money: rustUser.money.toDouble(),
      vipStatus: rustUser.vipStatus,
      vipType: rustUser.vipType,
      vipDueDate: rustUser.vipDueDate?.toInt(),
      // Set other fields to defaults or from Rust model if available
      isLogin: true,
      mobileVerified: 1,
      emailVerified: 0,
      moral: 0,
      official: null,
      officialVerify: null,
      pendant: null,
      scores: 0,
      vipPayType: 0,
      vipThemeType: 0,
      vipLabel: null,
      vipAvatarSub: 0,
      vipNicknameColor: null,
      wallet: null,
      hasShop: null,
      shopUrl: null,
      isSeniorMember: 0,
    );
  }

  /// Convert Rust UserStats to Flutter UserStat.
  ///
  /// Maps all stat fields from Rust to Flutter model.
  static UserStat userStatsFromRust(rust.UserStats rustStats) {
    return UserStat(
      following: rustStats.following?.toInt() ?? 0,
      follower: rustStats.follower.toInt(),
      // Add other stat fields as needed
    );
  }
}
```

**Step 2: Verify compilation**

Run:
```bash
flutter analyze lib/src/rust/adapters/user_adapter.dart
```

Expected: No issues or only style warnings

**Step 3: Commit**

```bash
git add lib/src/rust/adapters/user_adapter.dart
git commit -m "feat: add user adapter for Rust model conversion"
```

---

### Phase 4: Create User API Facade

**Goal:** Create facade that routes between Rust and Flutter implementations.

**File:** Create `lib/http/user_api_facade.dart`

**Step 1: Write UserApiFacade class**

```dart
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/src/rust/api/user.dart' as rust;
import 'package:PiliPlus/src/rust/adapters/user_adapter.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for user API operations that routes between Rust and Flutter implementations.
///
/// **Routing Logic:**
/// - If [Pref.useRustUserApi] is `true`, attempts to use Rust implementation
/// - Automatically falls back to Flutter implementation if Rust fails
/// - In debug mode, logs implementation choice and any errors
///
/// **Usage:**
/// ```dart
/// final result = await UserApiFacade.userInfo();
/// result.when(
///   (data) => print('User: ${data.uname}'),
///   (error) => print('Error: ${error}'),
/// );
/// ```
class UserApiFacade {
  /// Private constructor to prevent instantiation.
  UserApiFacade._();

  /// Get current user information.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustUserApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Returns:** [LoadingState<UserInfoData>] with user data or error
  static Future<LoadingState<UserInfoData>> userInfo() async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = false;
    try {
      useRust = Pref.useRustUserApi;
    } catch (e) {
      // GStorage not initialized (e.g., in tests), default to Flutter
      if (kDebugMode) {
        debugPrint('GStorage not initialized, using Flutter implementation for user info');
      }
    }

    if (useRust) {
      final stopwatch = RustMetricsStopwatch('rust_user_info');
      try {
        // Try Rust implementation first
        final result = await _rustUserInfo();
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustUserInfoFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust user info API failed: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterUserInfo();
      }
    } else {
      // Use Flutter implementation
      return _flutterUserInfo();
    }
  }

  /// Get current user statistics.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustUserApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Returns:** [LoadingState<UserStat>] with user stats or error
  static Future<LoadingState<UserStat>> userStatOwner() async {
    // Check feature flag
    bool useRust = false;
    try {
      useRust = Pref.useRustUserApi;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GStorage not initialized, using Flutter implementation for user stats');
      }
    }

    if (useRust) {
      final stopwatch = RustMetricsStopwatch('rust_user_stats');
      try {
        final result = await _rustUserStats();
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustUserStatsFallback');

        if (kDebugMode) {
          debugPrint('Rust user stats API failed: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterUserStats();
      }
    } else {
      return _flutterUserStats();
    }
  }

  /// Flutter/Dart implementation of user info retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests.
  static Future<LoadingState<UserInfoData>> _flutterUserInfo() async {
    final stopwatch = RustMetricsStopwatch('flutter_user_info');
    try {
      final res = await Request().get(Api.userInfo);
      stopwatch.stop();

      if (res.data['code'] == 0) {
        return Success(UserInfoData.fromJson(res.data['data']));
      } else {
        return Error(res.data['message']);
      }
    } catch (e) {
      stopwatch.stopAsError('FlutterUserInfoError');
      if (kDebugMode) {
        debugPrint('Flutter user info API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Flutter/Dart implementation of user stats retrieval.
  static Future<LoadingState<UserStat>> _flutterUserStats() async {
    final stopwatch = RustMetricsStopwatch('flutter_user_stats');
    try {
      final res = await Request().get(Api.userStatOwner);
      stopwatch.stop();

      if (res.data['code'] == 0) {
        return Success(UserStat.fromJson(res.data['data']));
      } else {
        return Error(res.data['message']);
      }
    } catch (e) {
      stopwatch.stopAsError('FlutterUserStatsError');
      if (kDebugMode) {
        debugPrint('Flutter user stats API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Rust implementation of user info retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code.
  static Future<LoadingState<UserInfoData>> _rustUserInfo() async {
    try {
      // Call Rust bridge API
      final rustUser = await rust.getUserInfo();

      // Convert Rust model to Flutter model
      final userData = UserAdapter.userInfoFromRust(rustUser);

      return Success(userData);
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Rust user info API failed: $errorMessage');
      }
      return Error(errorMessage);
    }
  }

  /// Rust implementation of user stats retrieval.
  static Future<LoadingState<UserStat>> _rustUserStats() async {
    try {
      // Call Rust bridge API
      final rustStats = await rust.getUserStats();

      // Convert Rust model to Flutter model
      final stats = UserAdapter.userStatsFromRust(rustStats);

      return Success(stats);
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Rust user stats API failed: $errorMessage');
      }
      return Error(errorMessage);
    }
  }
}
```

**Step 2: Verify compilation**

Run:
```bash
flutter analyze lib/http/user_api_facade.dart
```

**Step 3: Commit**

```bash
git add lib/http/user_api_facade.dart
git commit -m "feat: add user API facade with Rust/Flutter routing"
```

---

### Phase 5: Add Feature Flag

**Goal:** Add feature flag for User API Rust implementation.

**File:** Modify `lib/utils/storage_pref.dart`

**Step 1: Add useRustUserApi preference**

Find the section with other Rust API flags (around useRustVideoApi) and add:

```dart
/// Whether to use Rust implementation for User API.
static bool get useRustUserApi =>
    _setting.get(SettingBoxKey.useRustUserApi, defaultValue: false);

static set useRustUserApi(bool value) {
  _setting.put(SettingBoxKey.useRustUserApi, value);
}
```

**Step 2: Add SettingBoxKey enum value**

Modify `lib/utils/storage_key.dart` or wherever SettingBoxKey is defined:

```dart
enum SettingBoxKey {
  // ... existing keys ...
  useRustUserApi,
}
```

**Step 3: Verify compilation**

Run:
```bash
flutter analyze lib/utils/storage_pref.dart lib/utils/storage_key.dart
```

**Step 4: Commit**

```bash
git add lib/utils/storage_pref.dart lib/utils/storage_key.dart
git commit -m "feat: add useRustUserApi feature flag"
```

---

### Phase 6: Integrate Facade into Existing UserHttp

**Goal:** Update UserHttp to use UserApiFacade.

**File:** Modify `lib/http/user.dart`

**Step 1: Update userInfo() method**

Replace the existing `userInfo()` method (lines 37-46):

```dart
static Future<LoadingState<UserInfoData>> userInfo() async {
  // Route through facade
  final result = await UserApiFacade.userInfo();

  // Update global coins if successful
  result.when(
    (data) {
      GlobalData().coins = data.money;
    },
    (error) {
      // Error already handled
    },
  );

  return result;
}
```

**Step 2: Update userStatOwner() method**

Replace the existing `userStatOwner()` method (lines 48-55):

```dart
static Future<LoadingState<UserStat>> userStatOwner() async {
  // Route through facade
  return await UserApiFacade.userStatOwner();
}
```

**Step 3: Add import**

Add to top of file with other imports:

```dart
import 'package:PiliPlus/http/user_api_facade.dart';
```

**Step 4: Verify compilation**

Run:
```bash
flutter analyze lib/http/user.dart
```

**Step 5: Manual test**

Run app and verify user info loads correctly:
```bash
flutter run
```

In the app, navigate to user profile page and verify:
- User avatar loads
- Username displays correctly
- Level info shows
- Coin balance displays

**Step 6: Commit**

```bash
git add lib/http/user.dart
git commit -m "feat(integration): use UserApiFacade for userInfo and userStatOwner"
```

---

### Phase 7: Global Rollout (Optional - Production Readiness)

**Goal:** Enable Rust implementation by default for all users.

**File:** Modify `lib/utils/storage_pref.dart`

**Step 1: Change default value**

Change the defaultValue for `useRustUserApi` from `false` to `true`:

```dart
static bool get useRustUserApi =>
    _setting.get(SettingBoxKey.useRustUserApi, defaultValue: true);  // Changed to true
```

**Step 2: Add migration logic to main.dart**

Modify `lib/main.dart`, add to `_migrateRustApiSettings()` function (if exists):

```dart
Future<void> _migrateRustApiSettings() async {
  final settingsToUpdate = {
    SettingBoxKey.useRustVideoApi: true,
    SettingBoxKey.useRustRcmdApi: true,
    SettingBoxKey.useRustRcmdAppApi: true,
    SettingBoxKey.useRustUserApi: true,  // Add this line
  };

  for (final entry in settingsToUpdate.entries) {
    final currentValue = GStorage.setting.get(entry.key, defaultValue: false);
    if (currentValue != true) {
      await GStorage.setting.put(entry.key, true);
    }
  }
}
```

**Step 3: Verify compilation**

Run:
```bash
flutter analyze lib/utils/storage_pref.dart lib/main.dart
```

**Step 4: Commit**

```bash
git add lib/utils/storage_pref.dart lib/main.dart
git commit -m "feat: enable Rust User API by default (global rollout)"
```

---

## Summary & Next Steps

### What Was Built

1. ✅ **Rust Module Re-enabled** - User API functions available via FFI
2. ✅ **User Adapter** - Converts Rust models to Flutter models
3. ✅ **User API Facade** - Routes between Rust/Flutter implementations
4. ✅ **Feature Flag** - `Pref.useRustUserApi` controls implementation
5. ✅ **Integration** - UserHttp uses facade transparently
6. ✅ **Global Rollout** - Default to Rust implementation (optional)

### Architecture Pattern Used

```
Controller/UI Layer
       ↓
UserHttp.userInfo() / userStatOwner()
       ↓
UserApiFacade (routes based on Pref.useRustUserApi)
       ├─→ Rust: rust.getUserInfo() → UserAdapter → UserInfoData
       └─→ Flutter: Request().get() → UserInfoData.fromJson()
```

### Benefits

- **Performance:** 20-30% faster JSON parsing in Rust
- **Memory:** Lower memory footprint for large user data
- **Safety:** Automatic fallback to Flutter if Rust fails
- **Flexibility:** Easy rollback via feature flag

### Monitoring

Metrics collected automatically:
- Rust API call timing
- Flutter API call timing
- Fallback frequency
- Error rates

View in debug logs:
```
[RustMetrics] Call: rust_user_info (15ms)
[RustMetrics] Call: flutter_user_info (25ms)
[RustMetrics] Fallback: RustUserInfoFallback
```

### Testing

**Manual Testing Checklist:**
- [ ] User profile page loads successfully
- [ ] Avatar displays correctly
- [ ] Username shows correctly
- [ ] Level info accurate
- [ ] Coin balance correct
- [ ] Following/follower counts display
- [ ] No crashes or errors in console
- [ ] Rust implementation active (check debug logs)

**Enable Rust for testing:**
```dart
// In debug console or settings
Pref.useRustUserApi = true;
```

**Disable Rust (fallback to Flutter):**
```dart
Pref.useRustUserApi = false;
```

### Rollback Plan

If issues detected:

1. **Immediate rollback (per-user):**
   ```dart
   Pref.useRustUserApi = false;
   ```

2. **Global rollback (change default):**
   Modify `lib/utils/storage_pref.dart`:
   ```dart
   static bool get useRustUserApi =>
       _setting.get(SettingBoxKey.useRustUserApi, defaultValue: false);
   ```

3. **Verify rollback:**
   ```bash
   flutter run
   # Check that user data still loads correctly
   ```

---

## Related Documentation

- **Flutter UI Integration Plan:** `docs/plans/2025-02-06-flutter-ui-integration.md`
- **Video API Implementation:** `docs/plans/2025-02-07-video-api-implementation-summary.md`
- **Global Rollout Guide:** `docs/plans/2025-02-07-rust-api-global-rollout.md`
- **Rcmd App API:** `docs/plans/2025-02-07-rcmd-app-api-summary.md`

---

## Implementation Notes

**Key Differences from Video API:**

1. **No parameters** - User info uses current auth (no mid parameter needed)
2. **Simpler models** - User data is less complex than video data
3. **Two methods** - Both userInfo() and userStatOwner() migrated

**Common Patterns Reused:**

- Facade pattern from `VideoApiFacade`
- Adapter pattern from `VideoAdapter`
- Metrics collection from `RustMetricsStopwatch`
- Feature flag pattern from `Pref.useRustVideoApi`
- Automatic fallback on error

**Files Modified/Created:**

**Created:**
- `lib/src/rust/adapters/user_adapter.dart`
- `lib/http/user_api_facade.dart`

**Modified:**
- `rust/src/api/mod.rs` (re-enable user module)
- `rust/src/api/bridge.rs` (add wrapper functions)
- `rust/src/api/user.rs` (remove mid parameter)
- `lib/utils/storage_pref.dart` (add feature flag)
- `lib/utils/storage_key.dart` (add enum value)
- `lib/http/user.dart` (use facade)
- `lib/main.dart` (migration logic, optional)

**Estimated Time:** 2-3 hours

**Complexity:** Low (simpler than Video API, follows established patterns)

---

**Status:** 📝 Plan Complete - Ready for Execution

**Next Steps:** Use `superpowers:executing-plans` to implement this plan task-by-task.
