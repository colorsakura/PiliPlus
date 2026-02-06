# Task 49: Video API Migration Plan

## Overview

This document provides a detailed migration plan for integrating the Rust-based video API via the `VideoApiFacade` into the existing Flutter application.

## Current Implementation Analysis

### 1. Current Code Pattern

**File:** `/home/iFlygo/Projects/PiliPlus/lib/http/video.dart` (lines 278-291)

```dart
// Current implementation in VideoHttp.videoIntro()
static Future<LoadingState<VideoDetailData>> videoIntro({
  required String bvid,
}) async {
  final res = await Request().get(
    Api.videoIntro,
    queryParameters: {'bvid': bvid},
  );
  VideoDetailResponse data = VideoDetailResponse.fromJson(res.data);
  if (data.code == 0) {
    return Success(data.data!);
  } else {
    return Error(data.message);
  }
}
```

### 2. Current Call Chain

```
┌─────────────────────────────────────────────┐
│  Controller Layer                           │
│  (UgcIntroController.queryVideoIntro())     │
└──────────────────┬──────────────────────────┘
                   │ calls
┌──────────────────▼──────────────────────────┐
│  HTTP Layer                                 │
│  (VideoHttp.videoIntro())                   │
└──────────────────┬──────────────────────────┘
                   │ makes HTTP request
┌──────────────────▼──────────────────────────┐
│  Request Singleton                          │
│  (Request().get(Api.videoIntro, ...))       │
└──────────────────┬──────────────────────────┘
                   │ HTTP GET
┌──────────────────▼──────────────────────────┐
│  Bilibili API                               │
│  (https://api.bilibili.com/x/web-interface/ │
│   view?bvid=...)                            │
└─────────────────────────────────────────────┘
```

### 3. Controller Usage Pattern

**File:** `/home/iFlygo/Projects/PiliPlus/lib/pages/video/introduction/ugc/controller.dart` (lines 87-135)

```dart
// Controller code that calls VideoHttp.videoIntro()
@override
Future<void> queryVideoIntro() async {
  queryVideoTags();
  final res = await VideoHttp.videoIntro(bvid: bvid);
  if (res case Success(:final response)) {
    videoPlayerServiceHandler?.onVideoDetailChange(
      response,
      cid.value,
      heroTag,
    );
    // ... more processing
    videoDetail.value = response;
    // ... more processing
  } else {
    res.toast();  // Show error to user
    status.value = false;
  }
  // ... more logic
}
```

**Key observations:**
- Controller expects `LoadingState<VideoDetailData>` return type
- Uses pattern matching: `if (res case Success(:final response))`
- Accesses `VideoDetailData` directly from `response`
- Calls `.toast()` on error to show user feedback
- No controller changes needed - works with existing pattern

## Target Implementation

### 1. New Code Pattern

**File:** `/home/iFlygo/Projects/PiliPlus/lib/http/video.dart` (modified)

```dart
// New implementation using VideoApiFacade
static Future<LoadingState<VideoDetailData>> videoIntro({
  required String bvid,
}) async {
  try {
    // Use facade instead of direct Request().get()
    VideoDetailResponse data = await VideoApiFacade.getVideoInfo(bvid);
    if (data.code == 0) {
      return Success(data.data!);
    } else {
      return Error(data.message);
    }
  } catch (e) {
    // Handle any unexpected errors
    return Error(e.toString());
  }
}
```

### 2. New Call Chain

```
┌─────────────────────────────────────────────┐
│  Controller Layer                           │
│  (UgcIntroController.queryVideoIntro())     │
│  ✅ NO CHANGE                               │
└──────────────────┬──────────────────────────┘
                   │ calls
┌──────────────────▼──────────────────────────┐
│  HTTP Layer                                 │
│  (VideoHttp.videoIntro())                   │
│  ⚠️  UPDATED - now calls facade            │
└──────────────────┬──────────────────────────┘
                   │ routes based on feature flag
┌──────────────────▼──────────────────────────┐
│  VideoApiFacade                             │
│  (getVideoInfo(bvid))                       │
│  - Checks Pref.useRustVideoApi              │
│  - Routes to Rust or Flutter                │
└───────┬─────────────────────┬───────────────┘
        │                     │
        │ Rust path           │ Flutter path
        │ (if enabled)        │ (fallback)
┌───────▼──────────┐  ┌───────▼───────────────┐
│  Rust Bridge     │  │  Flutter Impl        │
│  (rust.getVideo  │  │  (_flutterGetVideo)  │
│   Info())        │  │  - Request().get()   │
└───────┬──────────┘  └───────┬───────────────┘
        │                     │
        │ FFI call            │ HTTP GET
┌───────▼──────────┐  ┌───────▼───────────────┐
│  Rust Native     │  │  Bilibili API        │
│  Code            │  │  (same as before)    │
└──────────────────┘  └───────────────────────┘
```

### 3. Facade Implementation

**File:** `/home/iFlygo/Projects/PiliPlus/lib/http/video_api_facade.dart`

```dart
/// Facade routes between Rust and Flutter implementations
class VideoApiFacade {
  /// Get video information from Bilibili API
  /// Routes to Rust or Flutter based on Pref.useRustVideoApi
  static Future<VideoDetailResponse> getVideoInfo(String bvid) async {
    if (Pref.useRustVideoApi) {
      try {
        return await _rustGetVideoInfo(bvid);
      } catch (e, stack) {
        if (kDebugMode) {
          debugPrint('Rust video API failed for $bvid: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return await _flutterGetVideoInfo(bvid);
      }
    } else {
      return await _flutterGetVideoInfo(bvid);
    }
  }

  /// Flutter implementation - same as original
  static Future<VideoDetailResponse> _flutterGetVideoInfo(String bvid) async {
    try {
      final response = await Request().get(
        Api.videoIntro,
        queryParameters: {'bvid': bvid},
      );
      return VideoDetailResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Flutter video API failed: $e');
      }
      rethrow;
    }
  }

  /// Rust implementation - uses FFI bridge
  static Future<VideoDetailResponse> _rustGetVideoInfo(String bvid) async {
    try {
      final result = await rust.getVideoInfo(bvid: bvid);
      final videoDetail = VideoAdapter.fromRust(result);
      return VideoDetailResponse(
        code: 0,
        data: videoDetail,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Rust video API failed: $e');
      }
      rethrow;
    }
  }
}
```

## Compatibility Analysis

### What Stays The Same

✅ **Controller Layer:**
- No changes needed in `UgcIntroController`
- No changes needed in any other controllers
- Same method signature: `Future<LoadingState<VideoDetailData>>`
- Same return type: `LoadingState<VideoDetailData>`

✅ **Error Handling:**
- Same error handling pattern in controllers
- Same `LoadingState` sealed class usage
- Same `Success/Error` return values
- Same `.toast()` error display

✅ **Data Models:**
- Same `VideoDetailData` model
- Same `VideoDetailResponse` wrapper
- Same JSON parsing (in Flutter path)

✅ **API Endpoint:**
- Same Bilibili API endpoint
- Same query parameters
- Same response format

### What Changes

⚠️ **HTTP Layer Only:**
- `VideoHttp.videoIntro()` implementation changes
- Adds `try-catch` wrapper
- Calls `VideoApiFacade.getVideoInfo()` instead of `Request().get()`

⚠️ **Routing Logic:**
- Adds feature flag check: `Pref.useRustVideoApi`
- Adds Rust implementation path
- Adds automatic fallback mechanism

⚠️ **Error Handling:**
- Adds catch-all exception handler
- Converts exceptions to `LoadingState Error`
- Maintains same error interface

### Migration Safety

✅ **Zero Controller Changes:**
- All controllers continue to work without modification
- Same method signatures
- Same return types
- Same error handling patterns

✅ **Gradual Rollout:**
- Feature flag defaults to `false` (Flutter implementation)
- Can enable Rust for specific users via A/B testing
- Automatic fallback on errors

✅ **Backward Compatibility:**
- Existing Flutter implementation remains unchanged
- Same data structures
- Same API calls
- Can disable Rust at any time

## Migration Steps

### Step 1: Update VideoHttp.videoIntro() (Task 50)

**File:** `/home/iFlygo/Projects/PiliPlus/lib/http/video.dart`

**Before:**
```dart
static Future<LoadingState<VideoDetailData>> videoIntro({
  required String bvid,
}) async {
  final res = await Request().get(
    Api.videoIntro,
    queryParameters: {'bvid': bvid},
  );
  VideoDetailResponse data = VideoDetailResponse.fromJson(res.data);
  if (data.code == 0) {
    return Success(data.data!);
  } else {
    return Error(data.message);
  }
}
```

**After:**
```dart
static Future<LoadingState<VideoDetailData>> videoIntro({
  required String bvid,
}) async {
  try {
    VideoDetailResponse data = await VideoApiFacade.getVideoInfo(bvid);
    if (data.code == 0) {
      return Success(data.data!);
    } else {
      return Error(data.message);
    }
  } catch (e) {
    return Error(e.toString());
  }
}
```

**Changes:**
1. Wrap entire method in try-catch
2. Replace `Request().get()` with `VideoApiFacade.getVideoInfo()`
3. Remove `VideoDetailResponse.fromJson()` (handled by facade)
4. Add catch-all error handler

### Step 2: Test with Rust Disabled (Task 51)

1. Ensure `Pref.useRustVideoApi = false` (default)
2. Run app and navigate to video detail page
3. Verify video information loads correctly
4. Test error cases (invalid bvid, network errors)
5. Verify error messages display correctly
6. Test on all platforms (Android, iOS, Windows, macOS, Linux)

**Expected behavior:**
- Flutter implementation is used (same as before)
- No behavioral changes
- All features work as before

### Step 3: Enable and Test with Rust (Task 52)

1. Set `Pref.useRustVideoApi = true`
2. Restart app
3. Navigate to video detail page
4. Verify video information loads correctly
5. Compare performance with Flutter implementation
6. Test error handling and automatic fallback
7. Verify debug logs show implementation choice

**Expected behavior:**
- Rust implementation is used
- Same data returned as Flutter
- Potential performance improvement
- Automatic fallback to Flutter on errors

## Testing Checklist

### Unit Tests (Recommended but Optional)

- [ ] Test facade returns correct response format
- [ ] Test feature flag routing
- [ ] Test error handling in both paths
- [ ] Test fallback mechanism

### Integration Tests (Required)

- [ ] Test with valid bvid (Rust disabled)
- [ ] Test with valid bvid (Rust enabled)
- [ ] Test with invalid bvid (404 error)
- [ ] Test with network error (no internet)
- [ ] Test with malformed response
- [ ] Test automatic fallback on Rust error

### Manual Tests (Required)

- [ ] Open video detail page
- [ ] Verify video title displays
- [ ] Verify video description displays
- [ ] Verify uploader info displays
- [ ] Verify view count displays
- [ ] Test error handling with invalid bvid
- [ ] Test offline scenario
- [ ] Compare performance (Rust vs Flutter)

## Rollback Plan

If issues are discovered:

### Immediate Rollback
1. Set `Pref.useRustVideoApi = false`
2. Restart app
3. Verify Flutter implementation works

### Code Rollback
If code changes need to be reverted:

```dart
// Revert to original implementation
static Future<LoadingState<VideoDetailData>> videoIntro({
  required String bvid,
}) async {
  final res = await Request().get(
    Api.videoIntro,
    queryParameters: {'bvid': bvid},
  );
  VideoDetailResponse data = VideoDetailResponse.fromJson(res.data);
  if (data.code == 0) {
    return Success(data.data!);
  } else {
    return Error(data.message);
  }
}
```

### Safe Deployment Strategy

1. **Phase 1:** Deploy with `Pref.useRustVideoApi = false` (default)
   - No behavioral changes
   - Verify stability

2. **Phase 2:** Enable for beta testers
   - Set `Pref.useRustVideoApi = true` for specific users
   - Monitor error rates
   - Collect performance data

3. **Phase 3:** Gradual rollout
   - Enable for 10% of users
   - Monitor metrics
   - Increase to 50%, then 100%

4. **Phase 4:** Full deployment
   - Make Rust implementation default
   - Keep Flutter as fallback

## Performance Considerations

### Rust Implementation
- **Pros:**
  - Faster JSON parsing (serde vs dart:convert)
  - Lower memory footprint
  - Better for large responses

- **Cons:**
  - FFI overhead (~0.1-0.5ms)
  - Different error handling patterns
  - Potential subtle behavioral differences

### Flutter Implementation
- **Pros:**
  - No FFI overhead
  - Stable and well-tested
  - Same error handling as existing code

- **Cons:**
  - Slower JSON parsing
  - Higher memory usage
  - Less efficient for large responses

### Expected Performance Impact

For typical video info response (~50KB JSON):
- **Flutter:** ~5-10ms parsing time
- **Rust:** ~1-2ms parsing time + ~0.2ms FFI overhead
- **Net improvement:** ~3-7ms per request

For high-traffic scenarios:
- 1000 requests/day saves ~3-7 seconds total
- User-perceivable improvement: minimal
- Server load reduction: minimal

## Conclusion

This migration plan provides a safe, gradual path to integrate Rust-based video API processing:

✅ **No controller changes required**
✅ **Backward compatible**
✅ **Feature flag controlled**
✅ **Automatic fallback**
✅ **Easy rollback**
✅ **Performance improvement** (modest)

The key insight is that the facade pattern allows us to change the implementation behind the scenes without affecting any controllers. The `LoadingState<T>` wrapper provides a consistent interface that works with both implementations.

---

**Next Steps:**
- Task 50: Implement the code changes
- Task 51: Test with Rust disabled
- Task 52: Enable and test with Rust
