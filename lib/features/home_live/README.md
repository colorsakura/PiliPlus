# Home Live Feature

Clean Architecture implementation for live streaming content on home page.

## Overview

This feature handles fetching and displaying live streaming content on the home page. It provides both a personalized live feed and area-based live listings.

## Architecture

### Domain Layer

**Entities:**
- `LiveFeedResult` - Contains personalized live feed with modules
- `LiveAreaResult` - Contains area-based live listings

**Repository Interface:**
- `LiveRepository` - Abstract contract for live content operations

**Use Cases:**
- `GetLiveFeedUseCase` - Retrieve personalized live feed
- `GetLiveAreaListUseCase` - Retrieve live streams by area

### Data Layer

**Data Sources:**
- Remote API data source for live content

**Models:**
- Live stream response models

**Repositories:**
- `LiveRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Live section on home page

**Providers:**
- `LiveController` - Controller for managing live state
- `LiveProvider` - Riverpod provider for live data

## Usage

```dart
import 'package:PiliPlus/features/home_live/home_live.dart';

// Initialize repository and use cases
final repository = LiveRepositoryImpl(
  remoteDataSource: LiveRemoteDataSourceImpl(),
);
final getLiveFeed = GetLiveFeedUseCase(repository);
final getLiveAreaList = GetLiveAreaListUseCase(repository);

// Get personalized live feed
final feedResult = await getLiveFeed(
  pn: 1,
  moduleSelect: true,  // Include followed list and area entries
);

print('Live streams: ${feedResult.items.length}');
print('Modules: ${feedResult.modules?.length}');

// Get area-specific live list
final areaResult = await getLiveAreaList(
  pn: 1,
  areaId: 6,  // Gaming area
  parentAreaId: 1,
  sortType: 'online',
);

print('Area live streams: ${areaResult.items.length}');
```

## Data Flow

1. User navigates to home page
2. Live section loads
3. Presentation layer calls `GetLiveFeedUseCase` for personalized content
4. Or calls `GetLiveAreaListUseCase` for specific area
5. Use case invokes repository method
6. Repository fetches data from remote API
7. Data is transformed to domain entities
8. Results are displayed on home page

## Entity Structure

**LiveFeedResult** contains:
- `items` - List of recommended live streams
- `modules` - Optional module info (followed channels, area entries)

**LiveAreaResult** contains:
- `items` - List of live streams in the area
- Pagination metadata

## Live Feed

Personalized live feed includes:
- Live streams from followed users
- Recommended live streams
- Area/Category entry points
- Requires `moduleSelect: true` for full data

## Area Listing

Area-based listing supports filtering by:
- `areaId` - Specific sub-area (e.g., Gaming: LoL, Dota 2)
- `parentAreaId` - Parent category (e.g., Gaming, Music)
- `sortType` - Sort order (online, viewers)

## Sort Types

- `online` - Currently online streams
- `viewers` - Sorted by viewer count
- Other platform-specific sorts

## Pagination

- `pn` - Page number (1-indexed)
- Each page contains a fixed number of live streams
