# Fav Folder Sort Feature

Clean Architecture implementation for favorite folder sorting functionality.

## Overview

This feature handles reordering favorite folders using drag-and-drop. It supports sorting folders in a specific order and persists the order to the server.

## Architecture

### Domain Layer

**Entities:**
- `FavFolderSortParams` - Encapsulates sort parameters including ordered folder IDs
- `FavFolderSortResult` - Represents the result of a folder sort operation

**Repository Interface:**
- `FavFolderSortRepository` - Abstract contract for folder sort operations

**Use Cases:**
- `SortFavoriteFolders` - Sort favorite folders in specified order

### Data Layer

**Data Sources:**
- `FavFolderSortRemoteDataSource` - Interface for sort data source
- `FavFolderSortRemoteDataSourceImpl` - Implementation using FavHttp.sortFavFolder

**Repositories:**
- `FavFolderSortRepositoryImpl` - Concrete implementation using remote data source

## Usage

```dart
import 'package:PiliPlus/features/fav_folder_sort/fav_folder_sort.dart';

// Initialize repository and use case
final remoteDataSource = FavFolderSortRemoteDataSourceImpl();
final repository = FavFolderSortRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final sortFavoriteFolders = SortFavoriteFolders(repository);

// Prepare sort parameters from folder list
final params = FavFolderSortParams.fromFolderList(folderList);

// Sort folders
final result = await sortFavoriteFolders(params);

if (result case Success()) {
  print('Sort successful');
} else if (result case Error(:final errorMsg)) {
  print('Sort failed: $errorMsg');
}
```

### Creating Sort Parameters

```dart
// From list of FavFolderInfo
final params = FavFolderSortParams.fromFolderList(folders);

// From list of folder IDs
final params2 = FavFolderSortParams(
  folderIds: [1, 2, 3, 4, 5],
);

// Get sort string
print(params.sortString); // "1,2,3,4,5"

// Create new params with reordered list
final newParams = params.withReorderedList(reorderedFolders);
```

## Architecture Note

This feature uses `FavHttp.sortFavFolder` API endpoint for data persistence. The repository implementation wraps this HTTP call, providing a clean abstraction layer for the application logic.

## Constraints

- The default folder (id: 0) cannot be moved from its position
- Sort order is persisted as a comma-separated string of folder IDs

## State Management

The presentation layer uses GetX controller from the `fav` feature. The sort page receives this controller as a parameter and maintains its own state for the drag-and-drop operation.
