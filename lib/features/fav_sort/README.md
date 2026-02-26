# Fav Sort Feature

Clean Architecture implementation for favorite folder item sorting functionality.

## Overview

This feature handles reordering items within a favorite folder using drag-and-drop. It supports sorting items within a favorite folder and persists the order to the server.

## Architecture

### Domain Layer

**Entities:**
- `FavSortEntity` - Encapsulates sort parameters including mediaId and sort string

**Repository Interface:**
- `FavSortRepository` - Abstract contract for favorite sort operations

**Use Cases:**
- `SortFavorites` - Sort items in a favorite folder

### Data Layer

**Data Sources:**
- `FavSortRemoteDataSource` - Interface for sort data source
- `FavSortRemoteDataSourceImpl` - Implementation using FavHttp.sortFav

**Repositories:**
- `FavSortRepositoryImpl` - Concrete implementation using remote data source

## Usage

```dart
import 'package:PiliPlus/features/fav_sort/fav_sort.dart';

// Initialize repository and use case
final remoteDataSource = FavSortRemoteDataSourceImpl();
final repository = FavSortRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final sortFavorites = SortFavorites(repository);

// Prepare sort parameters
final sortEntity = FavSortEntity(
  mediaId: mediaId,
  sort: 'prevItemId:prevItemType:currItemId:currItemType',
);

// Sort items
final result = await sortFavorites(sortEntity);

if (result case Success()) {
  print('Sort successful');
} else if (result case Error(:final errorMsg)) {
  print('Sort failed: $errorMsg');
}
```

## Creating Sort Entry

To create a sort entry string when reordering items:

```dart
import 'package:PiliPlus/features/fav_sort/fav_sort.dart';
import 'package:PiliPlus/models/fav/fav_detail/media.dart';

// Get previous and current items
FavDetailItemModel? prevItem = ...;
FavDetailItemModel currItem = ...;

// Create sort entry
final sortEntry = FavSortEntity.createSortEntry(prevItem, currItem);
// Result: "prevId:prevType:currId:currType"
```

## Architecture Note

This feature uses the `FavHttp.sortFav` API endpoint for data persistence. The repository implementation wraps this HTTP call, providing a clean abstraction layer for the application logic.

## State Management

The presentation layer uses GetX controller (`FavDetailController`) from the `fav_detail` feature. The sort page receives this controller as a parameter and maintains its own state for the drag-and-drop operation.
