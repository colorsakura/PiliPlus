# Member Coin Archive Feature

Clean Architecture implementation for member coin archives (videos a user has given coins to) functionality.

## Overview

This feature handles fetching and displaying videos that a member has "coined" (given virtual coins to). It provides paginated access to a member's coin history.

## Architecture

### Domain Layer

**Entities:**
- `MemberCoinArcItemEntity` - Represents a coined video item (currently typealias to `CoinLikeArcItem`)

**Repository Interface:**
- `MemberCoinArcRepository` - Abstract contract for member coin archive operations

**Use Cases:**
- `FetchMemberCoinArcsUseCase` - Retrieve member's coined videos with pagination

### Data Layer

**Data Sources:**
- Remote API data source for member coin archives

**Repositories:**
- `MemberCoinArcRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `MemberCoinArcPage` - Main page for displaying member's coined videos

**Providers:**
- `MemberCoinArcListController` - Controller for managing coin archive list state
- `MemberCoinArcListProvider` - Riverpod provider for coin archive list
- Various providers for dependency injection

## Usage

```dart
import 'package:PiliPlus/features/member_coin_arc/member_coin_arc.dart';

// Initialize repository and use case
final repository = MemberCoinArcRepositoryImpl(
  remoteDataSource: MemberCoinArcRemoteDataSourceImpl(),
);
final fetchCoinArcs = FetchMemberCoinArcsUseCase(repository);

// Fetch member's coined videos
final result = await fetchCoinArcs(
  mid: 123456,
  page: 1,
);

result.when(
  success: (videos) {
    for (var video in videos) {
      print('Title: ${video.title}');
      print('Coins given: ${video.coin}');
      print('Date: ${video.time}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to member's coin archive page
2. Presentation layer calls `FetchMemberCoinArcsUseCase` with member ID and page number
3. Use case invokes repository method
4. Repository fetches data from remote data source
5. Data is returned as domain entities
6. Result is returned to presentation layer for UI rendering
7. User can load more pages by incrementing page number

## Entity Structure

**MemberCoinArcItemEntity** (aliased to `CoinLikeArcItem`) contains:
- `id` - Video identifier
- `title` - Video title
- `cover` - Cover image URL
- `coin` - Number of coins given
- `time` - Timestamp when coins were given
- `author` - Video author information
- And other metadata from the coin archive API

## Pagination

The feature supports paginated loading:
- `page` parameter is 1-indexed (page 1 is the first page)
- Each page contains a fixed number of coined video items
- Presentation layer should handle "load more" functionality
- Typically shows videos in reverse chronological order (newest first)

## Coin System Context

In the Bilibili platform:
- Users can give up to 2 coins per video
- Coins are earned daily by logging in and watching videos
- Coining a video shows support and helps with recommendation algorithm
- This feature shows all videos a member has given coins to

## Migration Notes

This feature uses `typedef` to alias the existing `CoinLikeArcItem` model as `MemberCoinArcItemEntity`. This is a transitional approach during Clean Architecture migration. In a complete implementation:

1. Create pure domain entity `MemberCoinArcItemEntity` in domain layer
2. Map data layer models to domain entities in repository
3. Remove dependency on data layer models from domain layer
