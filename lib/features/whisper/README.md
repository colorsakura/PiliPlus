# Whisper Feature

Clean Architecture implementation for whisper (private message) functionality.

## Overview

This feature handles private messaging between users. It displays the main chat session list and manages unread message counts for different message types.

## Architecture

### Domain Layer

**Entities:**
- `SessionEntity` - Represents a single chat session
- `SessionListResult` - Result of fetching session list with pagination
- `UnreadCountsEntity` - Unread message counts by type

**Repository Interface:**
- `WhisperRepository` - Abstract contract for whisper operations

**Use Cases:**
- `FetchSessions` - Fetch chat session list
- `FetchUnreadCounts` - Fetch unread message counts

### Data Layer

**Data Sources:**
- `WhisperRemoteDataSource` - Interface for whisper data source
- `WhisperRemoteDataSourceImpl` - Implementation using ImGrpc

**Repositories:**
- `WhisperRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Fetch Sessions

```dart
import 'package:PiliPlus/features/whisper/whisper.dart';

// Initialize repository and use case
final remoteDataSource = WhisperRemoteDataSourceImpl();
final repository = WhisperRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final fetchSessions = FetchSessions(repository);

// Fetch sessions
final result = await fetchSessions();

if (result case Success(:final response)) {
  final sessions = response.sessions;
  final hasMore = response.paginationParams.hasMore;
  final offset = response.paginationParams.offsets;

  print('Found ${sessions.length} sessions');
  for (final session in sessions) {
    print('${session.name}: ${session.lastMsg}');
  }
} else if (result case Error(:final errorMsg)) {
  print('Fetch failed: $errorMsg');
}
```

### Fetch Unread Counts

```dart
final fetchUnreadCounts = FetchUnreadCounts(repository);

final result = await fetchUnreadCounts();

if (result case Success(:final response)) {
  final data = MsgFeedUnread.fromJson(response.msgFeedUnread.unread);
  print('Reply: ${data.reply}');
  print('@Me: ${data.at}');
  print('Likes: ${data.like}');
  print('System: ${data.sysMsg}');
}
```

### Session Entity

```dart
// Create from Session proto
final entity = SessionEntity.fromSession(sessionProto);

// Access properties
print(entity.sessionId);
print(entity.name);
print(entity.unreadCount);
```

## Unread Message Types

The unread counts are categorized into:
- **Reply** - Replies to user's comments
- **@Me** - Mentions of the user
- **Likes** - Likes on user's content
- **System** - System notifications

## Architecture Note

This feature uses `ImGrpc.sessionMain` and `ImGrpc.getTotalUnread` gRPC endpoints for data fetching. The repository implementations wrap these gRPC calls, providing clean abstraction layers for the application logic.

## Presentation Layer

**Controllers (GetX - Legacy):**
- `WhisperController` - GetX controller (extends CommonWhisperController)

**Controllers (Riverpod - New):**
- `WhisperSessionController` - Riverpod Notifier for session management

**Pages:**
- `WhisperPage` - GetX version (Legacy)
- `WhisperPageV2` - Riverpod version (New)

**Widgets:**
- `WhisperSessionItem` - Session list item widget

## Migration Status

- ✅ Domain Layer Complete
- ✅ Data Layer Complete
- ✅ Presentation Layer Complete (GetX + Riverpod)
- ⏳ Tests (Pending)
- ✅ Documentation Complete

## Code Quality

- ✅ `flutter analyze` No errors (only unused import warnings)
- ✅ `dart format` Formatted
- ✅ Riverpod code generation verified
- ✅ Clean architecture compliance verified

## Migration Notes

This module has been migrated from GetX to Riverpod while maintaining backward compatibility. Both versions are available:
- Use `WhisperPage` for GetX version (Legacy)
- Use `WhisperPageV2` for Riverpod version (Recommended)
