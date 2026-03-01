# Live Feature

Clean Architecture implementation for live streaming functionality.

## Overview

This feature handles live streaming operations including:
- Sending danmaku (chat messages) to live rooms
- Getting live room playback information
- Getting live room details (H5 version)
- Prefetching danmaku messages

## Architecture

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### Domain Layer

**Repository Interface:**
- `LiveRepository` - Abstract contract for live streaming operations

**Use Cases:**
- `SendLiveDanmaku` - Send danmaku message to live room
- `GetLiveRoomInfo` - Get live room playback info

### Data Layer

**Data Sources:**
- `LiveRemoteDataSource` - HTTP client for live streaming API endpoints with WBI signing

**Repositories:**
- `LiveRepositoryImpl` - Concrete implementation handling errors and converting to LoadingState

### Presentation Layer

**Controllers:**
- `LiveRoomController` - Manages live room information state
- `LiveDanmakuController` - Manages danmaku sending state

**Pages:**
- `LiveRoomPage` - Displays live room information
- `LiveDanmakuPage` - Test page for sending danmaku

## Usage

```dart
import 'package:PiliPlus/features/live/live.dart';

// Using controllers with Riverpod
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(liveRoomControllerProvider);

    // Fetch live room info
    ref.read(liveRoomControllerProvider.notifier).fetchRoomInfo(
          roomId: 123456,
          qn: 10000,
        );

    // Send danmaku
    ref.read(liveDanmakuControllerProvider.notifier).sendDanmaku(
          roomId: 123456,
          msg: 'Hello live room!',
        );

    return LiveRoomPage(roomId: 123456);
  }
}
```

## API Operations

The `LiveRemoteDataSource` provides the following methods:

| Method | Description |
|--------|-------------|
| `sendLiveMsg` | Send danmaku message to live room |
| `liveRoomInfo` | Get live room playback info with quality options |
| `liveRoomInfoH5` | Get live room info (H5 version) |
| `liveRoomDmPrefetch` | Get danmaku prefetch for room |

## Error Handling

The repository catches `ServerException` and general `Exception`, converting them to `LoadingState` for consistent error handling in the presentation layer.

## WBI Signing

All live streaming API requests use WBI (Web Browser Interface) signing for authentication and rate limiting protection.

## Migration Status

- ✅ Domain Layer Complete
- ✅ Data Layer Complete
- ✅ Presentation Layer Complete (New)
- ⏳ Tests (Pending)
- ✅ Documentation Complete

## Code Quality

- ✅ `flutter analyze` No errors found (only warnings in existing data layer)
- ✅ `dart format` Formatted
- ✅ Riverpod code generation verified
- ✅ Clean architecture compliance verified
