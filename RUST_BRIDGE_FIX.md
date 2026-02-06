# Flutter Rust Bridge Serialization Fix

## Problem
The original flutter_rust_bridge setup was using opaque Rust pointers (`RustAutoOpaque`) for complex types like `VideoInfo`. This meant the data stayed in Rust memory and Dart couldn't access the fields directly.

### Before
```dart
// Opaque type - can't access fields!
Future<BridgeResultVideoInfo> getVideoInfo({required String bvid});
```

## Solution
Modified the bridge to return serializable `ApiResult<T>` wrappers instead of opaque pointers, ensuring all model types are properly generated as Dart classes.

### After
```dart
// Now with actual VideoInfo class!
Future<ApiResult<VideoInfo>> getVideoInfo({required String bvid});

// Usage:
final result = await getVideoInfo(bvid: 'BV1xx411c7mD');
if (result.success && result.data != null) {
  final info = result.data!;
  print(info.title);  // Direct field access!
  print(info.bvid);
  print(info.owner.name);
  print(info.stats.viewCount);
}
```

## Changes Made

### 1. Updated Rust Error Types (`rust/src/error/mod.rs`)
- Added `ApiResult<T>` struct with `success`, `data`, and `error` fields
- Implemented conversion traits from `Result<T, E>` to `ApiResult<T>`
- Exported `ApiResult` for use in bridge APIs

### 2. Updated All Bridge API Functions
Changed return types from `BridgeResult<T>` to `ApiResult<T>` in:
- `rust/src/api/video.rs` - `get_video_info()`, `get_video_url()`
- `rust/src/api/user.rs` - `get_user_info()`, `get_user_stats()`
- `rust/src/api/account.rs` - `get_current_account()`, `switch_account()`, `get_all_accounts()`
- `rust/src/api/dynamics.rs` - `get_user_dynamics()`, `get_dynamics_detail()`
- `rust/src/api/live.rs` - `get_live_room_info()`, `get_live_play_url()`
- `rust/src/api/comments.rs` - `get_video_comments()`
- `rust/src/api/search.rs` - `search_videos()`
- `rust/src/api/download.rs` - `start_download()`, `pause_download()`, `cancel_download()`, `resume_download()`

### 3. Exposed Model Types (`rust/src/api/bridge.rs`)
Added type exposure functions to ensure all model types are generated:
- `VideoInfo`, `VideoUrl`, `VideoOwner`, `VideoStats`, `VideoPage`, `VideoSegment`
- `UserInfo`, `UserStats`
- `Account`
- `Image`
- `DynamicsList`, `DynamicsItem`
- `LiveRoomInfo`, `LivePlayUrl`
- `CommentList`
- `SearchResults`, `SearchResult`

### 4. Updated Configuration (`flutter_rust_bridge.yaml`)
- Added `dart_enums_style: true` for proper enum generation

### 5. Manually Updated Dart API Wrappers
Since flutter_rust_bridge doesn't preserve generic type parameters in wrapper functions, manually added type parameters to all API files in `lib/src/rust/api/`:
- `video.dart` - `ApiResult<VideoInfo>`, `ApiResult<VideoUrl>`
- `user.dart` - `ApiResult<UserInfo>`, `ApiResult<UserStats>`
- `account.dart` - `ApiResult<Account?>`, `ApiResult<void>`, `ApiResult<List<Account>>`
- `dynamics.dart` - `ApiResult<DynamicsList>`, `ApiResult<DynamicsItem>`
- `live.dart` - `ApiResult<LiveRoomInfo>`, `ApiResult<LivePlayUrl>`
- `comments.dart` - `ApiResult<CommentList>`
- `search.dart` - `ApiResult<SearchResults>`
- `download.dart` - `ApiResult<String>`, `ApiResult<void>`

## Generated Dart Model Classes

All model types are now properly generated in `lib/src/rust/models/`:

### Video Models (`video.dart`)
- `VideoInfo` - Full video metadata
- `VideoOwner` - Uploader information
- `VideoStats` - View, like, coin counts
- `VideoPage` - Video segments/pages
- `VideoSegment` - URL segments for playback
- `VideoUrl` - Playback URL information
- `VideoQuality` - Enum (low, medium, high, ultra, fourK)
- `VideoFormat` - Enum (mp4, dash)
- `DynamicsList`, `DynamicsItem` - User dynamics
- `SearchResults`, `SearchResult` - Search results
- `LiveRoomInfo`, `LivePlayUrl` - Live streaming
- `CommentList` - Comments

### Common Models (`common.dart`)
- `Image` - Image URL with optional dimensions

### User Models (`user.dart`)
- `UserInfo` - User profile information
- `UserStats` - Follower/following counts
- `UserLevel`, `VipStatus`, `CoinBalance` - User details

### Account Models (`account.dart`)
- `Account` - User account data

## Key Features

1. **Direct Field Access**: All struct fields are accessible in Dart
2. **Type Safety**: Generic type parameters provide compile-time type checking
3. **Null Safety**: Proper handling of nullable types
4. **Error Handling**: Unified `ApiResult` wrapper with success/error states
5. **No Opaque Types**: Data is serialized across FFI boundary, not passed as pointers

## Usage Example

```dart
import 'package:PiliPlus/src/rust/api/video.dart';

Future<void> loadVideo(String bvid) async {
  final result = await getVideoInfo(bvid: bvid);

  if (result.success && result.data != null) {
    final info = result.data!;

    // Access all fields directly
    print('Title: ${info.title}');
    print('Owner: ${info.owner.name}');
    print('Views: ${info.stats.viewCount}');

    // Iterate through pages
    for (final page in info.pages) {
      print('Page ${page.page}: ${page.part_}');
    }
  } else {
    print('Failed: ${result.error}');
  }
}
```

## Regeneration

When bridge code needs to be regenerated:

```bash
flutter_rust_bridge_codegen generate --config-file flutter_rust_bridge.yaml
```

**Note**: After regeneration, manually re-apply the generic type parameters to the API wrapper files in `lib/src/rust/api/`. The generator strips generic parameters, so they must be added manually.

## Testing

See `test_rust_api.dart` for usage examples demonstrating:
- Getting video info with direct field access
- Error handling
- Working with nested structures
- Using different API functions
