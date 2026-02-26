# Home Hot Feature

Clean Architecture implementation for hot videos functionality on home page.

## Overview

This feature handles fetching and displaying trending/hot videos on the home page. It provides a list of popular videos based on current trends.

## Architecture

### Domain Layer

**Entities:**
- `HotVideoResult` - Contains list of hot videos with pagination info

**Repository Interface:**
- `HotVideoRepository` - Abstract contract for hot video operations

**Use Cases:**
- `GetHotVideosUseCase` - Retrieve hot/trending videos

### Data Layer

**Data Sources:**
- Remote API data source for hot videos

**Models:**
- Hot video response models

**Repositories:**
- `HotVideoRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Hot videos section on home page

**Providers:**
- `HotVideoController` - Controller for managing hot video state
- `HotVideoProvider` - Riverpod provider for hot videos

## Usage

```dart
import 'package:PiliPlus/features/home_hot/home_hot.dart';

// Initialize repository and use case
final repository = HotVideoRepositoryImpl(
  remoteDataSource: HotVideoRemoteDataSourceImpl(),
);
final getHotVideos = GetHotVideosUseCase(repository);

// Fetch hot videos
final result = await getHotVideos(
  pn: 1,
  ps: 20,
);

print('Hot videos: ${result.videos.length}');
for (var video in result.videos) {
  print('${video.title} - ${video.stat?.view ?? 0} views');
}
```

## Data Flow

1. User navigates to home page
2. Hot videos section loads
3. Presentation layer calls `GetHotVideosUseCase`
4. Use case invokes repository method
5. Repository fetches data from remote API
6. Data is transformed to domain entities
7. Results are displayed on home page

## Entity Structure

**HotVideoResult** contains:
- `videos` - List of hot video items
- Pagination metadata

## Pagination

- `pn` - Page number (1-indexed)
- `ps` - Page size (items per page)

## Trending Algorithm

Hot videos are determined by:
- Recent view count
- Engagement rate (likes, comments, shares)
- Recency of upload
- User interaction patterns
