# Dynamics Tab Feature

Clean Architecture implementation for dynamics (posts) tab functionality.

## Overview

This feature handles displaying and managing user dynamics/posts in a tabbed interface. Users can view different types of dynamics from followed users or specific users.

## Architecture

### Domain Layer

**Entities:**
- `DynamicsTabType` - Enum for different dynamic tab types

**Repository Interface:**
- `DynTabRepository` - Abstract contract for dynamics operations

**Use Cases:**
- `FetchFollowDynamicsUseCase` - Retrieve dynamics from followed users
- `RemoveDynamicUseCase` - Remove/delete a dynamic

### Data Layer

**Data Sources:**
- `DynTabRemoteDataSource` - Remote API data source

**Models:**
- Various dynamic response models
- `DynamicsTabType` - Tab type enumeration

**Repositories:**
- `DynTabRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `DynamicsTabPage` - Main page for dynamics tab view

**Providers:**
- `DynamicsTabController` - Controller for managing dynamics state
- `DynamicsTabProvider` - Riverpod provider for dynamics data

## Usage

```dart
import 'package:PiliPlus/features/dynamics_tab/dynamics_tab.dart';

// Initialize repository and use cases
final repository = DynTabRepositoryImpl(
  remoteDataSource: DynTabRemoteDataSourceImpl(),
);
final fetchFollowDynamics = FetchFollowDynamicsUseCase(repository);
final removeDynamic = RemoveDynamicUseCase(repository);

// Fetch dynamics from followed users
final result = await fetchFollowDynamics(
  type: DynamicsTabType.all,
  offset: '',
  tempBannedList: {},
);

result.when(
  success: (data) {
    // Process dynamics data
    print('Loaded dynamics');
  },
  error: (error) {
    print('Error: $error');
  },
);

// Remove a dynamic
final removeResult = await removeDynamic(dynIdStr: '123456');
```

## Data Flow

1. User opens dynamics tab
2. Presentation layer calls `FetchFollowDynamicsUseCase`
3. Use case invokes repository method with tab type and offset
4. Repository fetches data from remote API
5. Data is transformed to domain entities
6. Results are displayed in tabbed interface
7. User can remove dynamics via `RemoveDynamicUseCase`

## Tab Types

`DynamicsTabType` enum defines different views:
- `all` - All dynamics
- `video` - Video posts only
- `article` - Article posts only
- Other specific content types

## Pagination

Uses offset-based pagination:
- `offset` - Starting point for next page
- Empty string for first page
- Update with returned offset for subsequent pages

## Temporary Ban List

The `tempBannedList` parameter filters out unwanted content:
- Set of banned user IDs
- Bans are temporary for this session
- Helps avoid seeing specific users' content

## Dynamic Removal

Users can remove dynamics:
- `dynIdStr` - Dynamic ID to remove
- Can only remove own dynamics
- Deletes from public view

## Content Types

Dynamics can include:
- Video posts - Uploaded or shared videos
- Article posts - Written articles
- Image posts - Photo galleries
- Text posts - Plain text updates
- Shared content - Reposts from others
