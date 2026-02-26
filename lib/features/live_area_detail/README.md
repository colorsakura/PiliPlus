# Live Area Detail Feature

Clean Architecture implementation for live area detail (sub-areas) functionality.

## Overview

This feature displays detailed information about a specific live streaming category area, showing its sub-areas and available live streams.

## Architecture

### Domain Layer

**Entities:**
- `LiveAreaItemEntity` - Represents a sub-area with live count

**Repository Interface:**
- `LiveAreaDetailRepository` - Abstract contract for area detail operations

**Use Cases:**
- `FetchLiveAreaDetailUseCase` - Retrieve sub-areas for a category

### Data Layer

**Data Sources:**
- `LiveAreaDetailRemoteDataSource` - Remote API data source

**Models:**
- Live area detail response models

**Repositories:**
- `LiveAreaDetailRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Live area detail page

**Providers:**
- `LiveAreaDetailController` - Controller for managing state
- `LiveAreaDetailProvider` - Riverpod provider for area data

## Usage

```dart
import 'package:PiliPlus/features/live_area_detail/live_area_detail.dart';

// Initialize repository and use case
final repository = LiveAreaDetailRepositoryImpl(
  remoteDataSource: LiveAreaDetailRemoteDataSourceImpl(),
);
final fetchLiveAreaDetail = FetchLiveAreaDetailUseCase(repository);

// Get sub-areas for a parent category
final result = await fetchLiveAreaDetail(
  parentAreaId: 1,  // Gaming category, for example
);

result.when(
  success: (subAreas) {
    print('Sub-areas: ${subAreas.length}');
    for (var area in subAreas) {
      print('${area.name}: ${area.count} live streams');
      print('Area ID: ${area.id}');
      print('Icon: ${area.pic}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User selects a live category
2. Presentation layer calls `FetchLiveAreaDetailUseCase`
3. Use case invokes repository with parent area ID
4. Repository fetches sub-areas from API
5. Results display available sub-areas with stream counts

## Entity Structure

**LiveAreaItemEntity** contains:
- `id` - Sub-area identifier
- `name` - Sub-area name
- `count` - Number of active live streams
- `pic` - Icon/image URL
- `parentAreaId` - Parent category reference

## Area Hierarchy

Live streaming areas are organized:
```
Gaming (parentAreaId: 1)
├── League of Legends (id: 2)
├── Dota 2 (id: 3)
├── CS:GO (id: 4)
└── ...
```

## Common Parent Areas

Popular parent categories:
- `1` - Gaming
- `2` - Entertainment
- `3` - Music
- And more platform-specific IDs

## Stream Counts

The `count` field shows:
- Currently active streams in that sub-area
- Real-time data
- Helps users find active content

## Use Cases

Users browse area details to:
- Find specific game streams
- Explore gaming categories
- Check activity levels
- Navigate to specific interests
- Discover active streamers
