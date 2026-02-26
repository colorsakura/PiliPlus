# Later Feature

Clean Architecture implementation for "Watch Later" (稍后再看) functionality.

## Overview

This feature manages the user's "Watch Later" list - videos saved for viewing at a later time. Users can view, filter, and remove videos from this list.

## Architecture

### Domain Layer

**Entities:**
- `LaterItemEntity` - Represents a video in the watch later list
- `LaterResultEntity` - Contains watch later items with total count
- `LaterViewType` - Enum for filter types (all/unfinished)

**Repository Interface:**
- `LaterRepository` - Abstract contract for watch later operations

**Use Cases:**
- `FetchLaterUseCase` - Retrieve watch later list with filters
- `RemoveLaterItemUseCase` - Remove a video from the list
- `ClearLaterUseCase` - Clear all or filtered items from the list

### Data Layer

**Data Sources:**
- `LaterRemoteDataSource` - Remote API data source for watch later

**Models:**
- `LaterItemModel` - API response model for watch later items

**Repositories:**
- `LaterRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `LaterPage` - Main page for watch later list

**Providers:**
- `LaterController` - Controller for managing watch later state
- `LaterProvider` - Riverpod provider for watch later data

## Usage

```dart
import 'package:PiliPlus/features/later/later.dart';

// Initialize repository and use cases
final repository = LaterRepositoryImpl(
  remoteDataSource: LaterRemoteDataSourceImpl(),
);
final fetchLater = FetchLaterUseCase(repository);
final removeLaterItem = RemoveLaterItemUseCase(repository);
final clearLater = ClearLaterUseCase(repository);

// Fetch watch later list
final result = await fetchLater(
  page: 1,
  viewType: LaterViewType.all,
  keyword: '',
  asc: false,
);

print('Total: ${result.totalCount}');
for (var item in result.items) {
  print('${item.title} - ${item.progress}% watched');
}

// Remove a specific video
final success = await removeLaterItem('12345,67890');

// Clear all items
final cleared = await clearLater();
```

## Data Flow

1. User opens watch later page
2. Presentation layer calls `FetchLaterUseCase` with filters
3. Use case invokes repository method
4. Repository fetches data from remote data source
5. Data is transformed to domain entities
6. Result is returned to presentation layer for UI rendering
7. User can remove items via `RemoveLaterItemUseCase`
8. User can clear items via `ClearLaterUseCase`

## Entity Structure

**LaterItemEntity** contains:
- `aid` - Video AV ID
- `bvid` - Video BV ID
- `title` - Video title
- `pic` - Cover image URL
- `duration` - Video duration in seconds
- `progress` - Watch progress percentage
- `owner` - Video author information
- `stat` - Video statistics (views, likes, etc.)
- `pubdate` - Publication timestamp
- `isPgc` - Whether this is PGC content
- `isPugv` - Whether this is PUGV content
- `pages` - Video pages/parts
- `cid` - Video CID
- And other metadata

**LaterResultEntity** contains:
- `items` - List of watch later videos
- `totalCount` - Total count of videos in list

**LaterViewType** enum:
- `all` (0) - Show all videos
- `unfinished` (2) - Show only unwatched videos

## Filtering

The feature supports filtering by:
- **View Type** - All videos or only unfinished
- **Keyword** - Search in video titles
- **Sort Order** - Ascending or descending
- **Pagination** - Page-based loading

## Progress Tracking

Each video tracks watch progress:
- `progress` field shows percentage watched
- Videos are categorized as watched/unfinished based on progress
- Viewing a video updates its progress automatically

## Clear Options

`ClearLaterUseCase` supports different clean types:
- No parameter - Clear all items
- With parameter - Clear specific subset (e.g., only finished)

## Model Mapping

The entity maps to/from `LaterItemModel`:
- Each field is directly mapped
- `fromModel()` factory creates entity from model
- `toModel()` method converts entity back to model
- Unique `id` getter generates `'later_$aid'` identifier
