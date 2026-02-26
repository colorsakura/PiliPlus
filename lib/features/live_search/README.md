# Live Search Feature

Clean Architecture implementation for live streaming search functionality.

## Overview

This feature handles searching for live streaming rooms and users. It supports both room search (finding live streams by keyword) and user search (finding streamers by username).

## Architecture

### Domain Layer

**Entities:**
- `LiveSearchParams` - Encapsulates search parameters including keyword, type, and page

**Repository Interface:**
- `LiveSearchRepository` - Abstract contract for live search operations

**Use Cases:**
- `SearchLive` - Search live rooms or users by keyword

### Data Layer

**Data Sources:**
- `LiveSearchRemoteDataSource` - Interface for live search data source
- `LiveSearchRemoteDataSourceImpl` - Implementation using LiveHttp

**Repositories:**
- `LiveSearchRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Search Live Rooms

```dart
import 'package:PiliPlus/features/live_search/live_search.dart';
import 'package:PiliPlus/models/common/live/live_search_type.dart';

// Initialize repository and use case
final remoteDataSource = LiveSearchRemoteDataSourceImpl();
final repository = LiveSearchRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final searchLive = SearchLive(repository);

// Prepare parameters
final params = LiveSearchParams(
  keyword: 'gaming',
  type: LiveSearchType.room,
  page: 1,
);

// Search live rooms
final result = await searchLive(params);

if (result case Success(:final response)) {
  final rooms = response.room?.list ?? [];
  final total = response.room?.totalRoom ?? 0;
  print('Found $total rooms');

  for (final room in rooms) {
    print('${room.title}: ${room.userName}');
  }
} else if (result case Error(:final errorMsg)) {
  print('Search failed: $errorMsg');
}
```

### Search Users

```dart
final userParams = LiveSearchParams(
  keyword: 'gamer',
  type: LiveSearchType.user,
  page: 1,
);

final result = await searchLive(userParams);

if (result case Success(:final response)) {
  final users = response.user?.list ?? [];
  final total = response.user?.totalUser ?? 0;
  print('Found $total users');
}
```

### Pagination

```dart
// Load next page
final nextPageParams = params.nextPage();
final nextResult = await searchLive(nextPageParams);
```

## Search Types

Live search is categorized by `LiveSearchType`:
- **ROOM** (LiveSearchType.room) - Search live streaming rooms
- **USER** (LiveSearchType.user) - Search live streamers

## Architecture Note

This feature uses `LiveHttp.liveSearch` API endpoint for searching live content. The repository implementation wraps this HTTP call, providing a clean abstraction layer for the application logic.

## State Management

The presentation layer uses Riverpod state management:
- `LiveSearchControllerV2` - Main controller managing search state
- `LiveSearchChildControllerV2` - Child controllers for each search type
- Both extend `CommonListControllerV2` for list management

## Search Coordination

The feature coordinates two types of searches:
1. Room search - Shows live streaming rooms matching the keyword
2. User search - Shows live streamers matching the keyword

Both searches can be active simultaneously, with their results displayed in tabs.
