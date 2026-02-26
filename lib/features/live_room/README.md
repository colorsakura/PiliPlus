# Live Room Feature

Clean Architecture implementation for live room streaming functionality.

## Overview

This feature handles real-time live streaming room connections. It manages WebSocket connections to live rooms, handles message streaming, and provides connection lifecycle management.

## Architecture

### Domain Layer

**Entities:**
- `LiveStreamConnectionConfig` - Connection configuration (room ID, user ID, token, servers)
- `LiveMessage` - Live message wrapper with command type and data

**Data Source Interface:**
- `LiveWebSocketDataSource` - Abstract interface for WebSocket operations

**Repository Interface:**
- `LiveStreamRepository` - Abstract contract for live stream operations

### Data Layer

**Data Sources:**
- `LiveWebSocketDataSourceImpl` - WebSocket implementation for live streaming

**Models:**
- Various live-related models for API responses

**Repositories:**
- `LiveStreamRepositoryImpl` - Concrete implementation using WebSocket data source

### Presentation Layer

**Pages:**
- `LiveRoomPage` - Main live room viewing page

## Usage

```dart
import 'package:PiliPlus/features/live_room/live_room.dart';

// Initialize repository
final repository = LiveStreamRepositoryImpl(
  webSocketDataSource: LiveWebSocketDataSourceImpl(),
);

// Create connection config
final config = LiveStreamConnectionConfig(
  roomId: 123456,
  uid: 789,
  streamToken: 'your_token_here',
  servers: ['wss://live-server1.com', 'wss://live-server2.com'],
);

// Connect to live room
final error = await repository.connect(config);
if (error == null) {
  print('Connected successfully');

  // Listen to messages
  repository.messageStream.listen((message) {
    if (message.isDanmaku) {
      print('Danmaku: ${message.data}');
    } else if (message.isSuperChat) {
      print('Super Chat: ${message.data}');
    }
  });

  // Send heartbeat periodically
  await repository.sendHeartbeat();
} else {
  print('Connection failed: $error');
}

// Disconnect when done
await repository.disconnect();
```

## Data Flow

1. User navigates to live room page
2. Presentation layer creates connection config
3. Calls `repository.connect()` with config
4. Repository establishes WebSocket connection via data source
5. On successful connection, repository starts receiving messages
6. Presentation layer subscribes to `messageStream`
7. Messages are parsed and dispatched to UI
8. Periodic heartbeats maintain connection
9. On page exit, `repository.disconnect()` closes connection

## Entity Structure

**LiveStreamConnectionConfig** contains:
- `roomId` - Live room identifier
- `uid` - User identifier
- `streamToken` - Authentication token for streaming
- `servers` - List of WebSocket server URLs

**LiveMessage** contains:
- `operationCode` - Protocol operation code
- `cmd` - Message command type (e.g., DANMU_MSG, SUPER_CHAT_MESSAGE)
- `data` - Message payload data

## Message Types

The feature handles various live message types:

- **DANMU_MSG** - Danmaku (bullet comment) messages
- **SUPER_CHAT_MESSAGE** - Super chat (paid message) messages
- **SUPER_CHAT_MESSAGE_DELETE** - Super chat deletion
- **WATCHED_CHANGE** - Viewer count changes
- **ONLINE_RANK_COUNT** - Online ranking changes
- **ROOM_CHANGE** - Room information updates

## Connection Management

**Connect:**
- Establishes WebSocket connection to live servers
- Handles authentication with stream token
- Returns error message on failure, null on success

**Message Stream:**
- Provides continuous stream of live messages
- Returns `Stream<LiveMessage>` for reactive consumption
- Automatically parses incoming JSON to message entities

**Heartbeat:**
- Maintains connection with periodic heartbeats
- Prevents connection timeout

**Disconnect:**
- Gracefully closes WebSocket connection
- Cleans up resources

## Connection State

Use `repository.isConnected` to check current connection status before operations.
