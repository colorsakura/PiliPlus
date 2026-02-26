# Fav Panel Feature

Clean Architecture implementation for favorite folder selection panel.

## Overview

This feature handles selecting favorite folders when adding a video to favorites. It displays all available folders and allows users to select which folder(s) to add the video to.

## Architecture

### Domain Layer

**Entities:**
- `FavFolderItemEntity` - Represents a favorite folder with selection state

**Repository Interface:**
- `FavFolderRepository` - Abstract contract for favorite folder operations

**Use Cases:**
- `QueryVideoInFolders` - Query folders containing a specific video

### Data Layer

**Data Sources:**
- `FavFolderRemoteDataSource` - Interface for folder data source
- `FavFolderRemoteDataSourceImpl` - Implementation (to be completed with controller integration)

**Repositories:**
- `FavFolderRepositoryImpl` - Concrete implementation using remote data source

## Usage

```dart
import 'package:PiliPlus/features/fav_panel/fav_panel.dart';

// Initialize repository and use case
final remoteDataSource = FavFolderRemoteDataSourceImpl();
final repository = FavFolderRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final queryVideoInFolders = QueryVideoInFolders(repository);

// Query folders containing the video
final result = await queryVideoInFolders();

if (result case Success(:final response)) {
  print('Found ${response.length} folders');
  for (final folder in response) {
    print('${folder.title}: ${folder.mediaCount} items');
  }
} else if (result case Error(:final errorMsg)) {
  print('Query failed: $errorMsg');
}
```

## Folder Entity

The `FavFolderItemEntity` provides helper methods:

```dart
final folder = FavFolderItemEntity(
  id: 1,
  title: 'My Favorites',
  mediaCount: 42,
  attr: 0,
);

// Check if public
print(folder.isPublic); // true

// Toggle selection
folder.toggle();
print(folder.isSelected); // true

// Toggle again
folder.toggle();
print(folder.isSelected); // false
```

## Architecture Note

This feature is primarily a UI component that works with the `FavMixin` controller from the common features. The repository implementation needs to be completed with proper integration to the controller's `queryVideoInFolder` method.

The presentation layer (`FavPanel` widget) manages the UI state for folder selection and provides callbacks for completing the action.
