# Member Season Series Feature

Clean Architecture implementation for member season/series content functionality.

## Overview

This feature displays season series (剧集/系列) created by a member. Users can browse all series a creator has organized their content into.

## Architecture

### Domain Layer

**Entities:**
- `MemberSeasonSeriesItemEntity` - Represents a season/series

**Repository Interface:**
- `MemberSeasonSeriesRepository` - Abstract contract for season series operations

**Use Cases:**
- `FetchMemberSeasonSeriesUseCase` - Retrieve member's season series

### Data Layer

**Data Sources:**
- Remote API data source

**Models:**
- Season series response models

**Repositories:**
- `MemberSeasonSeriesRepositoryImpl` - Concrete implementation

### Presentation Layer

**Pages:**
- Member season series page

**Providers:**
- `MemberSeasonSeriesController` - Controller
- `MemberSeasonSeriesProvider` - Riverpod provider

## Usage

```dart
import 'package:PiliPlus/features/member_season_series/member_season_series.dart';

// Initialize repository and use case
final repository = MemberSeasonSeriesRepositoryImpl(
  remoteDataSource: MemberSeasonSeriesRemoteDataSourceImpl(),
);
final fetchSeasonSeries = FetchMemberSeasonSeriesUseCase(repository);

// Get season series for a member
final result = await fetchSeasonSeries(
  mid: 123456,
  page: 1,
);

result.when(
  success: (seriesList) {
    print('Series: ${seriesList.length}');
    for (var series in seriesList) {
      print('${series.title}');
      print('Season ID: ${series.seasonId}');
      print('Cover: ${series.cover}');
      print('Videos: ${series.mediaCount}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User visits a creator's profile
2. User selects "Series" tab
3. Presentation layer calls use case with member ID
4. Repository fetches series data
5. Series displayed with covers and metadata

## Entity Structure

**MemberSeasonSeriesItemEntity** contains:
- `seasonId` - Series identifier
- `title` - Series title
- `cover` - Cover image URL
- `mediaCount` - Number of videos in series
- `description` - Series description
- And other metadata

## Series Types

Creators organize content as:
- Video series (视频合集)
- Playlist collections
- Themed content groups
- Sequential content

## Pagination

- `mid` - Member/user ID
- `page` - Page number
- Each page shows fixed number of series

## Use Cases

Users view series to:
- Watch content in order
- Find themed playlists
- Discover creator's series
- Binge-watch related content
