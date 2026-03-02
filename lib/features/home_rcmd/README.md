# Home Recommendation Feature

Clean Architecture implementation for home video recommendations functionality.

## Overview

This feature handles the personalized video feed on the home page. It fetches and displays recommended videos based on user preferences and viewing history.

## Architecture

### Domain Layer

**Entities:**
- `VideoRecommendation` - Represents a recommended video with reason
- `RecommendationResult` - Contains list of recommendations with pagination

**Repository Interface:**
- `VideoRecommendationRepository` - Abstract contract for recommendation operations

**Use Cases:**
- `GetVideoRecommendationsUseCase` - Retrieve personalized video recommendations

### Data Layer

**Data Sources:**
- `VideoRecommendationRemoteDataSource` - Remote API data source

**Models:**
- Various video models (Web/App API formats)

**Repositories:**
- `VideoRecommendationRepositoryImpl` - Concrete implementation

### Presentation Layer

**Pages:**
- Home page with recommendation feed

**Providers:**
- `RecommendationController` - Controller for managing recommendation state
- `RecommendationProvider` - Riverpod provider for recommendations

## Usage

```dart
import 'package:PiliPlus/features/home_rcmd/home_rcmd.dart';

// Initialize repository and use case
final repository = VideoRecommendationRepositoryImpl(
  remoteDataSource: RecommendationRemoteDataSourceImpl(),
  cacheDataSource: RecommendationCacheDataSourceImpl(),
);
final getRecommendations = GetVideoRecommendationsUseCase(repository);

// Fetch recommendations
final result = await getRecommendations(
  freshIdx: 0,  // First page
  useAppApi: true,  // Use App API
);

print('Videos: ${result.videos.length}');
print('Has more: ${result.hasMore}');
print('Page: ${result.currentPage}');

for (var rec in result.videos) {
  print('${rec.title} - ${rec.rcmdReason ?? "No reason"}');
}
```

## Data Flow

1. User opens home page
2. Presentation layer calls `FetchRecommendationsUseCase`
3. Use case fetches from remote source
4. Repository handles both Web API and App API formats
5. Data is transformed to domain entities
6. UI displays videos with recommendation reasons

## Entity Structure

**VideoRecommendation** contains:
- `video` - Video data (can be Web or App format)
- `rcmdReason` - Why this video was recommended
- Computed properties: `id`, `bvid`, `cover`, `title`, `duration`, `owner`, `stat`, `isFollowed`

**RecommendationResult** contains:
- `videos` - List of recommended videos
- `hasMore` - Whether more recommendations exist
- `currentPage` - Current page index

## API Selection

The feature supports two API modes:
- `useAppApi: true` - Uses App API (richer metadata, personalized)
- `useAppApi: false` - Uses Web API (simpler format)

## Pagination

Uses `freshIdx` for pagination:
- Starts at 0 for first request
- Increment for subsequent pages
- Returns `hasMore` to indicate availability

## Recommendation Reasons

Each video may include a reason for recommendation:
- "Because you watched X"
- "Popular in your area"
- "From creators you follow"
- And other personalized reasons
