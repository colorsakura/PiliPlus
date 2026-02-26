# Live Area Feature

Clean Architecture implementation for live streaming areas/categories functionality.

## Overview

This feature manages live streaming areas and categories. Users can browse different live content categories, view their favorite areas, and customize their live streaming experience.

## Architecture

### Domain Layer

**Entities:**
- `AreaList` - Live area/category group
- `AreaItem` - Individual area item

**Repository Interface:**
- `LiveAreaRepository` - Abstract contract for live area operations

**Use Cases:**
- `GetLiveAreaListUseCase` - Retrieve all live categories
- `GetLiveFavTagUseCase` - Get favorite areas
- `SetLiveFavTagUseCase` - Set favorite areas

### Data Layer

**Data Sources:**
- `LiveAreaRemoteDataSource` - Remote API data source

**Models:**
- `AreaList` - Area list model
- `AreaItem` - Area item model

**Repositories:**
- `LiveAreaRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Live area selection page

**Providers:**
- `LiveAreaController` - Controller for managing state
- `LiveAreaProvider` - Riverpod provider for area data

## Usage

```dart
import 'package:PiliPlus/features/live_area/live_area.dart';

// Initialize repository and use cases
final repository = LiveAreaRepositoryImpl(
  remoteDataSource: LiveAreaRemoteDataSourceImpl(),
);
final getLiveAreaList = GetLiveAreaListUseCase(repository);
final getLiveFavTag = GetLiveFavTagUseCase(repository);
final setLiveFavTag = SetLiveFavTagUseCase(repository);

// Get all live areas
final result = await getLiveAreaList();

result.when(
  success: (areaLists) {
    if (areaLists != null) {
      for (var areaList in areaLists) {
        print('Category: ${areaList.name}');
        for (var area in areaList.list ?? []) {
          print('  ${area.name} (ID: ${area.id})');
        }
      }
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Get favorite tags
final favResult = await getLiveFavTag();

// Set favorite tags (comma-separated IDs)
final setResult = await setLiveFavTag('1,2,3');
```

## Data Flow

1. User opens live streaming section
2. Presentation layer calls `GetLiveAreaListUseCase`
3. Use case invokes repository method
4. Repository fetches areas from remote API
5. Areas are displayed grouped by category
6. Users can set favorite areas via `SetLiveFavTagUseCase`
7. Favorite areas appear first or are highlighted

## Area Structure

Live areas are organized hierarchically:
- **Parent Category** (e.g., Gaming, Music, Talk)
  - **Sub-areas** (e.g., LoL, Dota 2 under Gaming)

## Common Categories

Typical live categories include:
- Gaming (游戏) - Various game streams
- Entertainment (娱乐) - Talk shows, variety
- Music (音乐) - Musical performances
- Technology (科技) - Tech talks, reviews
- And more platform-specific categories

## Favorite Areas

Users can customize which areas appear first:
- Select favorite sub-areas
- IDs are comma-separated string
- Stored per user account
- Affects recommendation order

## Area Information

Each area includes:
- `id` - Unique area identifier
- `name` - Display name
- `count` - Number of live streams
- `pic` - Area icon/image
- `parentAreaId` - Parent category ID

## Use Cases

Users use live areas to:
- Browse by category
- Find specific game streams
- Discover new content types
- Customize their live feed
- Focus on preferred categories
