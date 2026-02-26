# Popular Precious Feature

Clean Architecture implementation for "Precious" (high-quality/treasured) popular content functionality.

## Overview

This feature displays curated, high-quality content that has been selected as "precious" or "treasured" by the platform. These are exceptional videos that stand out from regular popular content.

## Architecture

### Domain Layer

**Entities:**
- `PopularPreciousItemEntity` - Represents a precious content item (typealias to `HotVideoItemModel`)

**Repository Interface:**
- `PopularPreciousRepository` - Abstract contract for precious content operations

**Use Cases:**
- `FetchPopularPreciousUseCase` - Retrieve precious content with pagination

### Data Layer

**Data Sources:**
- Remote API data source for precious content

**Models:**
- `HotVideoItemModel` - Video item model

**Repositories:**
- `PopularPreciousRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `PopularPreciousPage` - Main page for precious content

**Providers:**
- `PopularPreciousListController` - Controller for managing precious content state
- `PopularPreciousProvider` - Riverpod provider for precious data

## Usage

```dart
import 'package:PiliPlus/features/popular_precious/popular_precious.dart';

// Initialize repository and use case
final repository = PopularPreciousRepositoryImpl(
  remoteDataSource: PopularPreciousRemoteDataSourceImpl(),
);
final fetchPopularPrecious = FetchPopularPreciousUseCase(repository);

// Fetch precious content
final result = await fetchPopularPrecious(page: 1);

result.when(
  success: (items) {
    print('Precious items: ${items.length}');
    for (var item in items) {
      print('${item.title} - ${item.stat?.view ?? 0} views');
      print('Owner: ${item.owner?.name}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to precious content section
2. Presentation layer calls `FetchPopularPreciousUseCase`
3. Use case invokes repository method with page number
4. Repository fetches data from remote API
5. Data is returned as domain entities
6. Results are displayed to user

## What Makes Content "Precious"?

Content is selected as precious based on:
- Exceptional quality
- High engagement and positive feedback
- Unique creativity or storytelling
- Educational or artistic value
- Community impact
- Editor's choice selection

## Entity Structure

**PopularPreciousItemEntity** (aliased to `HotVideoItemModel`) contains:
- `title` - Video title
- `cover` - Cover image URL
- `duration` - Video length
- `stat` - View, like, coin statistics
- `owner` - Creator information
- `description` - Video description
- And other video metadata

## Pagination

- `page` - Page number (1-indexed)
- Each page contains a fixed number of items
- Supports infinite scroll loading

## Content Quality

Precious content differs from regular popular content:
- Curated by editors or algorithms
- Higher quality threshold
- Focus on value over virality
- Evergreen content that remains relevant
- Positive community impact

## Use Cases

Users explore precious content to:
- Find high-quality videos
- Discover exceptional creators
- Skip lower-tier popular content
- Get curated recommendations
- Enjoy hand-picked content
