# Search Trending Feature

Clean Architecture implementation for search trending topics functionality.

## Overview

This feature displays trending search terms and popular topics on the platform. Users can discover what's currently popular and trending.

## Architecture

### Domain Layer

**Entities:**
- `SearchTrendingItemEntity` - Represents a trending search term

**Repository Interface:**
- `SearchTrendingRepository` - Abstract contract for trending operations

**Use Cases:**
- `GetSearchTrendingUseCase` - Retrieve trending search terms

### Data Layer

**Data Sources:**
- `SearchTrendingRemoteDataSource` - Remote API data source

**Models:**
- Trending API response models

**Repositories:**
- `SearchTrendingRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Search trending page/section

**Providers:**
- `SearchTrendingController` - Controller for managing state
- `SearchTrendingProvider` - Riverpod provider for trending data

## Usage

```dart
import 'package:PiliPlus/features/search_trending/search_trending.dart';

// Initialize repository and use case
final repository = SearchTrendingRepositoryImpl(
  remoteDataSource: SearchTrendingRemoteDataSourceImpl(),
);
final getSearchTrending = GetSearchTrendingUseCase(repository);

// Get trending searches
final result = await getSearchTrending();

result.when(
  success: (items) {
    print('Trending items: ${items.length}');
    for (var item in items) {
      print('${item.keyword} - ${item.icon ?? "No icon"}');
      print('Heat: ${item.heat}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User opens search interface
2. Trending section loads automatically
3. Presentation layer calls `GetSearchTrendingUseCase`
4. Use case invokes repository method
5. Repository fetches trending data from API
6. Results are displayed in search interface
7. Users can tap trending terms to search

## Entity Structure

**SearchTrendingItemEntity** contains:
- `keyword` - Trending search term
- `icon` - Optional icon identifier (e.g., "hot", "new")
- `heat` - Popularity score/indicator
- `url` - Direct search URL (if available)

## Trending Categories

Icons may indicate:
- 🔥 "hot" - Currently hot topic
- 🆕 "new" - New trending term
- Other platform-specific indicators

## Display Priority

Trending items are typically ordered by:
- Recency of trend
- Search volume
- Heat score
- Platform curation

## Use Cases

Trending searches help users:
- Discover popular content
- Find trending topics
- Stay current with platform trends
- Get search inspiration
- Explore new content categories

## Update Frequency

Trending data is typically refreshed:
- Periodically (every few hours)
- On search page load
- Cached for performance
- May vary by platform strategy
