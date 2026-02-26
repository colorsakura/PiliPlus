# History Feature

Clean Architecture implementation for viewing history functionality.

## Overview

This feature handles displaying and managing the user's watch history. Users can view all watched videos, filter by type, delete entries, and control history recording.

## Architecture

### Domain Layer

**Entities:**
- `HistoryItemEntity` - Represents a single history entry
- `HistoryTabEntity` - Represents a history filter tab/category
- `HistoryResultEntity` - Contains history items with pagination and tabs

**Repository Interface:**
- `HistoryRepository` - Abstract contract for history operations

**Use Cases:**
- `GetHistoryListUseCase` - Retrieve watch history with filters
- `DeleteHistoryUseCase` - Remove history entries
- `GetHistoryStatusUseCase` - Check if history recording is paused

### Data Layer

**Data Sources:**
- `HistoryRemoteDataSource` - Remote API data source

**Models:**
- Various history data models

**Repositories:**
- `HistoryRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `HistoryPage` - Legacy history page
- `HistoryPageV2` - Current history page

**Providers:**
- `HistoryController` - Controller for managing history state
- `HistoryProvider` - Riverpod provider for history data

## Usage

```dart
import 'package:PiliPlus/features/history/history.dart';

// Initialize repository and use cases
final repository = HistoryRepositoryImpl(
  remoteDataSource: HistoryRemoteDataSourceImpl(),
);
final getHistoryList = GetHistoryListUseCase(repository);
final deleteHistory = DeleteHistoryUseCase(repository);
final getHistoryStatus = GetHistoryStatusUseCase(repository);

// Get history list
final result = await getHistoryList(
  type: 'archive',  // Filter by type
  max: null,        // Pagination max ID
  viewAt: null,     // Pagination view time
);

print('History items: ${result.items.length}');
print('Has more: ${result.hasMore}');
print('Tabs: ${result.tabs.length}');

for (var item in result.items) {
  print('${item.title} - watched at ${item.viewAt}');
  print('Progress: ${item.progress}%');
  print('Duration: ${item.duration}s');
}

// Delete history entries
final deleteResult = await deleteHistory([
  'archive_123456',
  'video_789012',
]);

// Check history recording status
final isPaused = await getHistoryStatus();
print('History paused: $isPaused');
```

## Data Flow

1. User opens history page
2. Presentation layer calls `GetHistoryListUseCase`
3. Use case invokes repository method with optional filters
4. Repository fetches data from remote API
5. Data is transformed to domain entities
6. Results are displayed with tabs and items
7. User can delete entries via `DeleteHistoryUseCase`
8. User can check recording status via `GetHistoryStatusUseCase`

## Entity Structure

**HistoryResultEntity** contains:
- `items` - List of watched videos
- `tabs` - Filter categories (all, archive, pgc, live, etc.)
- `hasMore` - Whether more items exist
- `maxId` - Max ID for pagination
- `viewAt` - Latest view time for pagination

**HistoryItemEntity** contains:
- `oid` - Content ID
- `business` - Content type (archive, pgc, live, etc.)
- `title` - Content title
- `cover` - Cover image URL
- `duration` - Content length
- `progress` - Watch progress percentage
- `viewAt` - When it was watched
- `kid` - Unique identifier
- And other metadata

**HistoryTabEntity** contains:
- `id` - Tab identifier (e.g., 'all', 'archive')
- `name` - Display name
- `count` - Number of items in this category

## History Types

Different content types are tracked:
- `archive` - Regular videos
- `pgc` - Professional content (anime, drama)
- `live` - Live streams
- `article` - Articles

## Pagination

Uses cursor-based pagination:
- `max` - Maximum ID seen so far
- `viewAt` - Latest view timestamp
- Both values returned for next page request

## Delete History

History entries are identified by keys:
- Format: `business_kid`
- Example: `archive_123456789`
- Batch delete supported

## History Status

Users can pause history recording:
- `true` - Recording paused
- `false` - Recording active
- `null` - Status unknown

## Use Cases

Users use history to:
- Re-watch previously viewed content
- Resume partially watched videos
- Clear viewing history
- Filter by content type
- Manage privacy by deletion
