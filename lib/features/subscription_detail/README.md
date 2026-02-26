# Subscription Detail Feature

Clean Architecture implementation for subscription folder detail functionality.

## Overview

This feature displays the contents of a specific subscription folder. Users can view all creators and content within a folder they've created.

## Architecture

### Domain Layer

**Entities:**
- `SubDetailData` - Contains subscription folder contents

**Repository Interface:**
- `SubscriptionDetailRepository` - Abstract contract for folder detail operations

**Use Cases:**
- `GetFavSeasonListUseCase` - Retrieve folder contents

### Data Layer

**Data Sources:**
- `SubscriptionDetailRemoteDataSource` - Remote API data source

**Models:**
- `SubDetailData` - Folder detail data model
- Individual subscription item models

**Repositories:**
- `SubscriptionDetailRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `SubscriptionDetailPageV2` - Folder detail page

**Providers:**
- `SubscriptionDetailController` - Controller for managing state
- `SubscriptionDetailProvider` - Riverpod provider for folder data

## Usage

```dart
import 'package:PiliPlus/features/subscription_detail/subscription_detail.dart';

// Initialize repository and use case
final repository = SubscriptionDetailRepositoryImpl(
  remoteDataSource: SubscriptionDetailRemoteDataSourceImpl(),
);
final getFavSeasonList = GetFavSeasonListUseCase(repository);

// Get folder contents
final result = await getFavSeasonList(
  id: 123,  // Folder ID
  ps: 20,   // Page size
  pn: 1,    // Page number
);

result.when(
  success: (data) {
    print('Folder: ${data.info?.name}');
    print('Items: ${data.list?.length ?? 0}');
    for (var item in data.list ?? []) {
      print(item.title ?? item.name);
      print('Type: ${item.type}');
      print('Season ID: ${item.seasonId}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User clicks on a subscription folder
2. Presentation layer calls `GetFavSeasonListUseCase`
3. Use case invokes repository method with folder ID
4. Repository fetches contents from remote API
5. Results are displayed showing folder contents

## Content Types

Subscription folders can contain:
- Anime series (番剧)
- Movies (电影)
- Documentaries (纪录片)
- TV shows (电视剧)
- Other PGC content types

## Folder Information

`SubDetailData` contains:
- `info` - Folder metadata (name, description, cover)
- `list` - List of subscribed content items
- `total` - Total number of items

## Item Properties

Each subscription item includes:
- `seasonId` - Season/series identifier
- `type` - Content type (anime, movie, etc.)
- `title` or `name` - Content title
- `cover` - Cover image URL
- `status` - Publication status
- `subtitle` - Additional info (episode count, etc.)

## Pagination

- `id` - Folder ID to fetch contents for
- `pn` - Page number (1-indexed)
- `ps` - Page size (items per page)
- Supports loading more items as user scrolls

## Use Cases

Users view folder details to:
- See all subscriptions in a folder
- Browse by categories
- Access specific series
- Manage folder contents
- Discover new episodes
