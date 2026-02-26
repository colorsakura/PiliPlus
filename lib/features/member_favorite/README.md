# Member Favorite Feature

Clean Architecture implementation for user's favorite collections and subscriptions.

## Overview

This feature handles displaying and managing a user's favorite collections (收藏夹) and subscribed collections (订阅夹). It supports both initial data loading and paginated loading of more items.

## Architecture

### Domain Layer

**Entities:**
- `MemberFavoriteParams` - Base parameters for fetching collections
- `UserFavFolderParams` - Parameters for fetching favorite folders
- `UserSubFolderParams` - Parameters for fetching subscription folders

**Repository Interface:**
- `MemberFavoriteRepository` - Abstract contract for member favorite operations

**Use Cases:**
- `FetchSpaceFavorites` - Fetch member space favorites (both fav and sub)
- `FetchUserFavFolders` - Fetch user favorite folders with pagination
- `FetchUserSubFolders` - Fetch user subscription folders with pagination

### Data Layer

**Data Sources:**
- `MemberFavoriteRemoteDataSource` - Interface for member favorite data source
- `MemberFavoriteRemoteDataSourceImpl` - Implementation using FavHttp and Request

**Repositories:**
- `MemberFavoriteRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Fetch Space Favorites (Initial Load)

```dart
import 'package:PiliPlus/features/member_favorite/member_favorite.dart';

// Initialize repository and use case
final remoteDataSource = MemberFavoriteRemoteDataSourceImpl();
final repository = MemberFavoriteRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final fetchSpaceFavorites = FetchSpaceFavorites(repository);

// Fetch space favorites
final result = await fetchSpaceFavorites(mid);

if (result case Success(:final response)) {
  // response is List<SpaceFavData>?
  // response[0] - favorite folders
  // response[1] - subscription folders
  print('Found ${response?.length} collection types');
} else if (result case Error(:final errorMsg)) {
  print('Fetch failed: $errorMsg');
}
```

### Fetch Favorite Folders (Paginated)

```dart
final fetchUserFavFolders = FetchUserFavFolders(repository);

// Prepare parameters
final params = UserFavFolderParams(
  mid: 12345,
  page: 2, // Start from page 2 since page 1 is loaded initially
  pageSize: 20,
);

// Fetch more favorite folders
final result = await fetchUserFavFolders(params);

if (result case Success(:final response)) {
  final hasMore = response['has_more'] == true;
  final list = response['list'] as List<dynamic>?;
  print('Has more: $hasMore, Items: ${list?.length ?? 0}');
}
```

### Fetch Subscription Folders (Paginated)

```dart
final fetchUserSubFolders = FetchUserSubFolders(repository);

final params = UserSubFolderParams(
  mid: 12345,
  page: 2,
  pageSize: 20,
);

final result = await fetchUserSubFolders(params);
```

### Pagination

```dart
// Fetch next page
final nextPageParams = params.nextPage();
final nextResult = await fetchUserFavFolders(nextPageParams);
```

## Collection Types

The feature supports two main types of collections:
1. **Favorite Folders** (收藏夹) - Collections created by users to save content
2. **Subscription Folders** (订阅夹) - Collections of content users have subscribed to

## State Management

The presentation layer uses GetX controller (`MemberFavoriteCtr`) that extends `CommonDataController`. The controller manages:
- Initial data loading
- Pagination state for both collection types
- Expansion/collapse state for each collection section
- End-of-list detection

## Architecture Note

This feature uses `FavHttp.spaceFav` API for initial data and direct `Request` calls for paginated data fetching. The repository implementations wrap these HTTP calls, providing clean abstraction layers for the application logic.
