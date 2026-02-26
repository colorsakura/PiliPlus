# Popular Series Feature

Clean Architecture implementation for popular series (weekly/monthly highlights) functionality.

## Overview

This feature handles displaying curated video series that are trending or highlighted by the platform. These can be weekly highlights, monthly top picks, or themed collections.

## Architecture

### Domain Layer

**Entities:**
- Various popular series entities

**Repository Interface:**
- `PopularSeriesRepository` - Abstract contract for popular series operations

**Use Cases:**
- `GetPopularSeriesListUseCase` - Retrieve list of popular series
- `GetPopularSeriesOneUseCase` - Retrieve videos in a specific series

### Data Layer

**Data Sources:**
- Remote API data source for popular series

**Models:**
- `PopularSeriesListItem` - Series list item model
- `PopularSeriesOneData` - Series videos data model

**Repositories:**
- `PopularSeriesRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Popular series page

**Providers:**
- `PopularSeriesController` - Controller for managing state
- `PopularSeriesProvider` - Riverpod provider for series data

## Usage

```dart
import 'package:PiliPlus/features/popular_series/popular_series.dart';

// Initialize repository and use cases
final repository = PopularSeriesRepositoryImpl(
  remoteDataSource: PopularSeriesRemoteDataSourceImpl(),
);
final getPopularSeriesList = GetPopularSeriesListUseCase(repository);
final getPopularSeriesOne = GetPopularSeriesOneUseCase(repository);

// Get list of popular series
final listResult = await getPopularSeriesList();

listResult.when(
  success: (seriesList) {
    if (seriesList != null) {
      for (var series in seriesList) {
        print('${series.name} - ${series.description}');
      }
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Get videos from a specific series
final videosResult = await getPopularSeriesOne(number: 1);

videosResult.when(
  success: (data) {
    print('Videos in series: ${data.list?.length ?? 0}');
    for (var video in data.list ?? []) {
      print(video.title);
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to popular series section
2. Presentation layer calls `GetPopularSeriesListUseCase`
3. Use case invokes repository method
4. Repository fetches series list from remote API
5. User selects a series
6. Presentation layer calls `GetPopularSeriesOneUseCase`
7. Repository fetches videos from that series
8. Results are displayed to user

## Series Types

Popular series may include:
- Weekly Highlights - Top videos of the week
- Monthly Picks - Editor's monthly selections
- Themed Collections - Holiday/event collections
- Genre Highlights - Best in specific categories
- Creator Spotlights - Featured creator works

## Series Content

Each series contains:
- Series metadata (name, description, cover)
- List of curated videos
- Video ordering (editor's choice)
- Series numbering/identifier

## Use Cases

Users explore popular series to:
- Discover trending content
- Find high-quality videos
- Explore new creators
- Stay updated with platform highlights
