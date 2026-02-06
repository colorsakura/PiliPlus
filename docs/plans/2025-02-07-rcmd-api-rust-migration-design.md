# Web推荐API Rust迁移设计文档

**Date:** 2025-02-07
**Status:** Approved
**Type:** API Migration Design
**Related:** Flutter UI Integration Plan

---

## Overview

将B站首页推荐API从Flutter/Dart实现迁移到Rust实现，使用与Video API相同的Facade模式，实现完整的WBI签名、网络请求和数据解析功能。

**目标：** 在保持功能完整性的同时，提升推荐API的性能和可靠性。

---

## Architecture Overview

### Component Architecture

```
┌─────────────────────────────────────────────────────┐
│         Flutter UI Layer (RcmdController)           │
│  - No changes to UI code                            │
│  - Controller calls VideoHttp.rcmdVideoList()       │
└───────────────────┬─────────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────────┐
│         VideoHttp (Modified)                        │
│  - Routes to RcmdApiFacade.getRecommendList()       │
└───────────────────┬─────────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────────┐
│         RcmdApiFacade (NEW - determines route)      │
│  - Checks feature flag: Pref.useRustRcmdApi         │
│  - Routes to Rust or Flutter implementation         │
│  - Handles errors and fallback                      │
└─────────┬───────────────────────────┬───────────────┘
          │                           │
┌─────────┴───────────┐   ┌───────────┴───────────────┐
│   Rust Bridge       │   │   Flutter/Dio (existing)  │
│   via pilicore      │   │   - Request().get()       │
│   - get_recommend_list│   │   - Api.recommendListWeb │
│   - WBI signing     │   │   - WbiSign.makSign()     │
└─────────────────────┘   └───────────────────────────┘
```

### Key Components

1. **Rust API Layer** - Complete WBI signing + HTTP request implementation
2. **RcmdApiFacade** - Wrapper with same interface as existing API
3. **Feature Flag** - `Pref.useRustRcmdApi` boolean in preferences
4. **Model Adapter** - Convert Rust models to Dart models
5. **Beta Testing** - Integrated into existing BetaTestingManager

---

## Data Model Design

### Rust Models

**1. RcmdVideoInfo** - Recommended video item
```rust
pub struct RcmdVideoInfo {
    pub id: Option<i64>,           // Corresponds to aid
    pub bvid: String,
    pub cid: Option<i64>,
    pub goto: Option<String>,      // 'av', 'bangumi', etc.
    pub uri: Option<String>,
    pub pic: Option<String>,       // Cover URL
    pub title: String,
    pub duration: i32,
    pub pubdate: Option<i64>,
    pub owner: RcmdOwner,
    pub stat: RcmdStat,
    pub is_followed: bool,
    pub rcmd_reason: Option<String>, // Recommendation reason content
}
```

**2. RcmdOwner** - UP owner information
```rust
pub struct RcmdOwner {
    pub mid: i64,
    pub name: String,
    pub face: Option<String>,      // Avatar URL
}
```

**3. RcmdStat** - Statistics
```rust
pub struct RcmdStat {
    pub view: Option<i64>,
    pub like: Option<i64>,
    pub danmaku: Option<i64>,
}
```

### Flutter Models (Existing)

```dart
// lib/models/model_rec_video_item.dart
class RecVideoItemModel extends BaseRecVideoItemModel {
  int? aid;
  String? bvid;
  int? cid;
  String? goto;
  String? uri;
  String? cover;
  String? title;
  int? duration;
  int? pubdate;
  Owner owner;
  Stat stat;
  bool isFollowed;
  String? rcmdReason;
}
```

---

## WBI Signature Implementation

### WBI Signing Components

Complete WBI signature implementation in Rust (independent from Dart):

**1. Get WBI Keys**
```rust
pub async fn get_wbi_keys() -> Result<String, Error> {
    // Call user info API to get wbi_img
    // Extract img_url and sub_url filenames
    // Call get_mixin_key() to generate mixed key
    // Cache locally (same expiry: daily refresh)
}
```

**2. Mixin Key Generation**
```rust
fn get_mixin_key(orig: &str) -> String {
    // Use 32-element shuffle table (identical to Dart)
    // Shuffle character order of imgKey + subKey
    // Return 32-character mixed key
}
```

**Shuffle Table** (identical to Dart):
```rust
const MIXIN_KEY_ENC_TAB: [usize; 32] = [
    46, 47, 18, 2, 53, 8, 23, 27, 32, 15, 50, 10, 31, 58, 3, 45,
    35, 27, 43, 5, 49, 33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13
];
```

**3. Parameter Signing**
```rust
fn enc_wbi(params: &mut HashMap<String, String>, mixin_key: &str) {
    // Add wts timestamp
    // Sort parameters by key
    // URL encode and concatenate
    // Filter special characters: !'()*
    // Calculate MD5 hash → w_rid
}
```

**4. Caching Strategy**
- Use `once_cell` or `lazy_static` for global cache
- Timestamp consistent with Dart (daily expiry)
- Support manual refresh

---

## Rust API Implementation

### API Function

**File:** `rust/src/api/rcmd.rs`

```rust
#[frb]
pub async fn get_recommend_list(
    ps: i32,           // Page size (usually 20)
    fresh_idx: i32,    // Refresh index (0, 1, 2...)
) -> Result<Vec<RcmdVideoInfo>, ApiError> {
    // 1. Build request parameters
    // 2. Get WBI keys (with caching)
    // 3. Sign parameters
    // 4. Make HTTP request
    // 5. Parse JSON response
    // 6. Filter data (only goto='av', non-blocked users)
    // 7. Return recommendation list
}
```

### HTTP Client Integration

- Reuse existing `reqwest` client configuration
- Automatic cookie handling (via AccountManager)
- HTTP/2 support
- Error handling converted to `ApiError`

### Request Parameters

```rust
let mut params = HashMap::new();
params.insert("version".to_string(), "1".to_string());
params.insert("feed_version".to_string(), "V8".to_string());
params.insert("homepage_ver".to_string(), "1".to_string());
params.insert("ps".to_string(), ps.to_string());
params.insert("fresh_idx".to_string(), fresh_idx.to_string());
params.insert("brush".to_string(), fresh_idx.to_string());
params.insert("fresh_type".to_string(), "4".to_string());
```

### Response Filtering

```rust
// Only keep video type (goto='av')
// Filter blocked UP owners (passed via blacklist param or skip in Dart layer)
// Consistent with VideoHttp.rcmdVideoList()
```

### API Endpoint

- URL: `/x/web-interface/wbi/index/top/feed/rcmd`
- Full URL: `https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd`

---

## Dart Adapter Design

### Adapter Implementation

**File:** `lib/src/rust/adapters/rcmd_adapter.dart`

```dart
class RcmdAdapter {
  /// Convert single Rust recommended video to Flutter model
  static RecVideoItemModel fromRust(rust.RcmdVideoInfo rustVideo) {
    return RecVideoItemModel()
      ..aid = rustVideo.id?.toInt()
      ..bvid = rustVideo.bvid
      ..cid = rustVideo.cid?.toInt()
      ..goto = rustVideo.goto
      ..uri = rustVideo.uri
      ..cover = rustVideo.pic
      ..title = rustVideo.title
      ..duration = rustVideo.duration
      ..pubdate = rustVideo.pubdate?.toInt()
      ..owner = Owner(
        mid: rustVideo.owner.mid.toInt(),
        name: rustVideo.owner.name,
        face: rustVideo.owner.face?.url,
      )
      ..stat = Stat(
        view: rustVideo.stat.view?.toInt(),
        like: rustVideo.stat.like?.toInt(),
        danmaku: rustVideo.stat.danmaku?.toInt(),
      )
      ..isFollowed = rustVideo.isFollowed
      ..rcmdReason = rustVideo.rcmdReason;
  }

  /// Convert recommendation list
  static List<RecVideoItemModel> fromRustList(
    List<rust.RcmdVideoInfo> rustList
  ) {
    return rustList.map((item) => fromRust(item)).toList();
  }
}
```

### Field Mapping Notes

- `id` (Rust) → `aid` (Flutter)
- `pic` (Rust) → `cover` (Flutter)
- `is_followed` (Rust) → `isFollowed` (Flutter, bool)
- `rcmd_reason` directly mapped, not an object

---

## Facade Design

### RcmdApiFacade Implementation

**File:** `lib/http/rcmd_api_facade.dart`

```dart
class RcmdApiFacade {
  static Future<LoadingState<List<RecVideoItemModel>>> getRecommendList({
    required int ps,
    required int freshIdx,
  }) async {
    if (Pref.useRustRcmdApi) {
      final stopwatch = RustMetricsStopwatch('rust_rcmd_call');
      try {
        // Call Rust implementation
        final rustList = await rust.getRecommendList(
          ps: ps,
          freshIdx: freshIdx,
        );

        stopwatch.stop();
        final adapted = RcmdAdapter.fromRustList(rustList);
        return Success(adapted);

      } catch (e, stack) {
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustRcmdFallback');

        if (kDebugMode) {
          debugPrint('Rust rcmd API failed: $e\n$stack');
          debugPrint('Falling back to Flutter');
        }
        return await _flutterGetRecommendList(ps, freshIdx);
      }
    } else {
      return await _flutterGetRecommendList(ps, freshIdx);
    }
  }
}
```

### Flutter Implementation (Existing Logic)

```dart
static Future<LoadingState<List<RecVideoItemModel>>> _flutterGetRecommendList(
  int ps, int freshIdx
) async {
  final stopwatch = RustMetricsStopwatch('flutter_rcmd_call');
  try {
    final res = await Request().get(
      Api.recommendListWeb,
      queryParameters: await WbiSign.makSign({
        'version': 1,
        'feed_version': 'V8',
        'homepage_ver': 1,
        'ps': ps,
        'fresh_idx': freshIdx,
        'brush': freshIdx,
        'fresh_type': 4,
      }),
    );

    stopwatch.stop();

    // Reuse existing filter and conversion logic
    if (res.data['code'] == 0) {
      List<RecVideoItemModel> list = [];
      for (final i in res.data['data']['item']) {
        if (i['goto'] == 'av' &&
            (i['owner'] != null &&
                !GlobalData().blackMids.contains(i['owner']['mid']))) {
          RecVideoItemModel item = RecVideoItemModel.fromJson(i);
          if (!RecommendFilter.filter(item)) {
            list.add(item);
          }
        }
      }
      return Success(list);
    } else {
      return Error(res.data['message']);
    }
  } catch (e) {
    stopwatch.stopAsError('FlutterRcmdError');
    return Error(e.toString());
  }
}
```

### Integration to VideoHttp

```dart
// Modify lib/http/video.dart
static Future<LoadingState<List<RecVideoItemModel>>> rcmdVideoList({
  required int ps,
  required int freshIdx,
}) async {
  // Direct call to facade
  return RcmdApiFacade.getRecommendList(ps: ps, freshIdx: freshIdx);
}
```

---

## Feature Flags and Storage

### Storage Keys

**File:** `lib/utils/storage_key.dart`

```dart
abstract final class SettingBoxKey {
  // ... existing keys ...

  /// Use Rust implementation for recommendation API
  static const String useRustRcmdApi = 'useRustRcmdApi';
}
```

### Pref Accessor

**File:** `lib/utils/storage_pref.dart`

```dart
abstract final class Pref {
  // ... existing properties ...

  /// Whether to use Rust implementation for recommendation API
  static bool get useRustRcmdApi =>
      _setting.get(SettingBoxKey.useRustRcmdApi, defaultValue: false);
}
```

### Beta Testing Manager Integration

Recommendation API will be included in existing beta testing system:

```dart
// lib/utils/beta_testing_manager.dart
class BetaTestingManager {
  static Future<void> initialize() async {
    // Existing: Video API
    final useRustVideo = _isUserInCohort();
    GStorage.setting.put(SettingBoxKey.useRustVideoApi, useRustVideo);

    // New: Recommendation API (same cohort allocation)
    GStorage.setting.put(SettingBoxKey.useRustRcmdApi, useRustVideo);
  }
}
```

### Independent Control Switch (Debug Only)

```dart
// lib/main.dart (debug mode only)
if (kDebugMode) {
  // Independent control for recommendation API
  // GStorage.setting.put(SettingBoxKey.useRustRcmdApi, true);
}
```

### Default Behavior

- **Debug mode**: Default false, manual enable required
- **Release mode**: Controlled by beta testing manager
- **Emergency rollback**: Set both flags to false

### Metrics Tracking

Independent metrics keys:
```dart
RustMetricsStopwatch('rust_rcmd_call');
RustMetricsStopwatch('flutter_rcmd_call');
```

---

## Testing Strategy

### Unit Tests

```dart
// test/rcmd_adapter_test.dart
test('RcmdAdapter.fromRust converts correctly', () {
  final rust = rust.RcmdVideoInfo(
    id: Some(123456),
    bvid: 'BV1xx411c7mD',
    title: 'Test Video',
    // ... other fields
  );
  final flutter = RcmdAdapter.fromRust(rust);

  expect(flutter.aid, equals(123456));
  expect(flutter.bvid, equals('BV1xx411c7mD'));
  expect(flutter.title, equals('Test Video'));
});
```

### Integration Tests

```dart
// integration_test/rcmd_api_integration_test.dart
testWidgets('Rcmd API returns valid data', (tester) async {
  // Enable Rust implementation
  GStorage.setting.put(SettingBoxKey.useRustRcmdApi, true);

  final result = await VideoHttp.rcmdVideoList(ps: 20, freshIdx: 0);

  expect(result, isA<Success>());
  final list = (result as Success).response as List<RecVideoItemModel>;
  expect(list, isNotEmpty);

  // Verify field completeness
  final first = list.first;
  expect(first.bvid, isNotEmpty);
  expect(first.title, isNotEmpty);
  expect(first.owner.mid, isNotNull);
});
```

### A/B Comparison Tests

```dart
// test/rcmd_validation_test.dart
test('Rust and Flutter return equivalent data', () async {
  // Call both implementations
  GStorage.setting.put(SettingBoxKey.useRustRcmdApi, false);
  final flutterResult = await VideoHttp.rcmdVideoList(ps: 10, freshIdx: 0);

  GStorage.setting.put(SettingBoxKey.useRustRcmdApi, true);
  final rustResult = await VideoHttp.rcmdVideoList(ps: 10, freshIdx: 0);

  // Compare result count
  expect((rustResult as Success).response.length,
         equals((flutterResult as Success).response.length));

  // Random spot check 3 videos for field equivalence
  // ...
});
```

### Performance Benchmark Tests

```dart
test('Performance: Rust should be faster', () async {
  final sw = Stopwatch();

  // Measure Flutter implementation
  sw.start();
  await VideoHttp.rcmdVideoList(ps: 20, freshIdx: 0);
  final flutterTime = sw.elapsedMilliseconds;

  // Measure Rust implementation
  GStorage.setting.put(SettingBoxKey.useRustRcmdApi, true);
  sw.reset();
  sw.start();
  await VideoHttp.rcmdVideoList(ps: 20, freshIdx: 0);
  final rustTime = sw.elapsedMilliseconds;

  print('Flutter: ${flutterTime}ms, Rust: ${rustTime}ms');
  expect(rustTime, lessThan(flutterTime));
});
```

### WBI Signature Validation Tests

```rust
// rust/src/api/wbi_test.rs
#[test]
fn test_mixin_key_encoding() {
    // Verify shuffle table results match Dart implementation
}
```

---

## Implementation Plan

### Phase 1: Rust Implementation (1-2 days)

**Tasks:**
1. Create `rust/src/api/rcmd.rs`
2. Implement WBI signing functions (3 functions)
   - `get_wbi_keys()`
   - `get_mixin_key()`
   - `enc_wbi()`
3. Implement `get_recommend_list()` API
4. Add to `mod.rs` and `bridge.rs`
5. Generate Dart bindings with flutter_rust_bridge_codegen

**Deliverables:**
- Working Rust API
- Generated Dart bindings
- Unit tests for WBI signing

### Phase 2: Dart Adapter Layer (1 day)

**Tasks:**
1. Create `lib/src/rust/adapters/rcmd_adapter.dart`
2. Create `lib/http/rcmd_api_facade.dart`
3. Add feature flag (`useRustRcmdApi`) to storage
4. Integrate into `VideoHttp.rcmdVideoList()`
5. Add to `Pref` accessor

**Deliverables:**
- Working adapter with full field mapping
- Facade with routing logic
- Feature flag functional

### Phase 3: Testing (1 day)

**Tasks:**
1. Write unit tests (adapter tests)
2. Write integration tests (API tests)
3. Write A/B comparison tests
4. Performance benchmark tests
5. Fix discovered issues

**Deliverables:**
- All tests passing
- Performance metrics collected
- Bug fixes applied

### Phase 4: Beta Testing Integration (0.5 day)

**Tasks:**
1. Integrate into `BetaTestingManager`
2. Add metrics tracking
3. Test fallback mechanism
4. Prepare monitoring dashboard

**Deliverables:**
- Beta testing enabled
- Metrics dashboard ready
- Rollback procedures tested

### Phase 5: Validation and Deployment (0.5 day)

**Tasks:**
1. Code review
2. Documentation update
3. Enable beta testing (10% rollout)
4. Monitor metrics
5. Gradually increase rollout

**Deliverables:**
- Successful beta rollout
- Monitoring dashboards in place
- Rollback plan tested
- Ready for production

### Timeline Summary

| Phase | Duration | Key Deliverable |
|-------|----------|-----------------|
| Rust Implementation | 1-2 days | Working Rust API |
| Dart Adapter | 1 day | Facade and adapter |
| Testing | 1 day | Tests passing |
| Beta Integration | 0.5 day | Beta enabled |
| Validation | 0.5 day | Production ready |

**Total:** 3-4 days

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| WBI signature implementation complexity | High | Reuse Dart logic, thorough testing |
| Recommendation algorithm changes | Medium | Keep fallback to Flutter |
| Data filtering inconsistency | Medium | Don't filter in Rust, handle in Dart layer |
| Performance below expectations | Low | Validate JSON parsing performance first |
| User-reported regressions | Medium | Gradual rollout, monitor feedback |

---

## Success Criteria

### Technical Criteria

- ✅ All recommendation API calls work via Rust
- ✅ Performance comparable or better than Flutter (< 200ms p50)
- ✅ Zero crash increase
- ✅ 100% feature parity (all fields mapped)
- ✅ Easy toggle on/off via feature flag
- ✅ Validation tests pass (50+ requests)
- ✅ WBI signature generates valid signatures

### Process Criteria

- ✅ Code review completed
- ✅ Documentation updated
- ✅ Rollback plan tested
- ✅ Monitoring in place
- ✅ Team aligned on approach

---

## Consistency with Video API Migration

This design maintains consistency with the existing Video API migration:

1. **Same Architecture Pattern** - Facade pattern with routing
2. **Same Error Handling** - Automatic fallback to Flutter
3. **Same Metrics Tracking** - RustMetricsStopwatch
4. **Same Feature Flag Pattern** - Pref.useRustXxxApi
5. **Same Beta Testing** - Integrated into BetaTestingManager
6. **Same Adapter Pattern** - Static methods with type conversion

---

## Next Steps

1. Review and approve this design
2. Set up isolated development workspace
3. Begin Phase 1: Rust Implementation
4. Track progress with daily check-ins

**Related Documents:**
- Flutter UI Integration Plan: `docs/plans/2025-02-06-flutter-ui-integration.md`
- Rust Core Architecture Design: `docs/plans/2025-02-06-rust-core-architecture-design.md`
