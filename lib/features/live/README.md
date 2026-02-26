# Live Feature

Clean Architecture implementation for live streaming functionality.

## Overview

This feature handles live streaming operations including:
- Sending danmaku (chat messages) to live rooms
- Getting live room playback information
- Getting live room details (H5 version)
- Prefetching danmaku messages

## Architecture

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

## Usage

```dart
import 'package:PiliPlus/features/live/live.dart';

// Initialize repository and use cases
final repository = LiveRepositoryImpl(
  remoteDataSource: LiveRemoteDataSource(),
);

final sendDanmaku = SendLiveDanmaku(repository);
final getRoomInfo = GetLiveRoomInfo(repository);

// Send danmaku to live room
final result = await sendDanmaku(
  roomId: 123456,
  msg: 'Hello live room!',
);

if (result case Success()) {
  print('Danmaku sent successfully');
} else if (result case Error(:final errorMsg)) {
  print('Failed to send: $errorMsg');
}

// Get live room info
final roomInfoResult = await getRoomInfo(
  roomId: 123456,
  qn: 10000, // Quality level
  onlyAudio: false,
);

if (roomInfoResult case Success(:final data)) {
  print('Room quality: ${data['playurl_info']}');
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
