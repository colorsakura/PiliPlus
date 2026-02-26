# Whisper Secondary Feature

Clean Architecture implementation for secondary whisper (private message) sessions.

## Overview

This feature handles displaying filtered whisper conversations, such as sessions where the user was mentioned, sessions where the user's content was liked, etc. It supports fetching and paginating through these filtered session lists.

## Architecture

### Domain Layer

**Entities:**
- `FetchSecondarySessionsParams` - Parameters for fetching secondary sessions
- `SecondarySessionListResult` - Result containing sessions, pagination info, and menu items

**Repository Interface:**
- `SecondarySessionRepository` - Abstract contract for secondary session operations

**Use Cases:**
- `FetchSecondarySessions` - Fetch secondary session list (at me, like me, etc.)

### Data Layer

**Data Sources:**
- `SecondarySessionRemoteDataSource` - Interface for secondary session data source
- `SecondarySessionRemoteDataSourceImpl` - Implementation using ImGrpc

**Repositories:**
- `SecondarySessionRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Fetch Secondary Sessions

```dart
import 'package:PiliPlus/features/whisper_secondary/whisper_secondary.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show SessionPageType;

// Initialize repository and use case
final remoteDataSource = SecondarySessionRemoteDataSourceImpl();
final repository = SecondarySessionRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final fetchSecondarySessions = FetchSecondarySessions(repository);

// Prepare parameters
final params = FetchSecondarySessionsParams(
  sessionPageType: SessionPageType.SESSION_PAGE_TYPE_AT_ME,
  offset: null, // null for initial load
);

// Fetch sessions
final result = await fetchSecondarySessions(params);

if (result case Success(:final response)) {
  final sessions = response.sessions;
  final hasMore = response.paginationParams.hasMore;
  final threeDotItems = response.response.threeDotItems;
  print('Found ${sessions.length} sessions');
  print('Has more: $hasMore');
} else if (result case Error(:final errorMsg)) {
  print('Fetch failed: $errorMsg');
}
```

### Pagination

```dart
// Use offsets from previous result
final nextParams = FetchSecondarySessionsParams(
  sessionPageType: SessionPageType.SESSION_PAGE_TYPE_AT_ME,
  offset: previousOffsets, // From previous response.paginationParams.offsets
);

final nextResult = await fetchSecondarySessions(nextParams);
```

## Session Page Types

Secondary sessions are categorized by `SessionPageType`:
- **AT_ME** (SESSION_PAGE_TYPE_AT_ME) - Sessions where user was mentioned
- **LIKE_ME** (SESSION_PAGE_TYPE_LIKE_ME) - Sessions where user's content was liked
- And other types as defined in the gRPC schema

## Architecture Note

This feature uses `ImGrpc.sessionSecondary` gRPC endpoint for fetching filtered session lists. The repository implementation wraps this gRPC call, providing a clean abstraction layer for the application logic.

## State Management

The presentation layer uses GetX controller (`WhisperSecController`) that extends `CommonWhisperController`. The controller manages:
- Session list with pagination
- Three-dot menu items
- End-of-list detection
