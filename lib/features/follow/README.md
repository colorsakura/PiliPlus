# Follow Feature

Clean Architecture implementation for user follow management functionality.

## Overview

This feature handles managing user follow tags (分组). Users can create, update, delete tags, and retrieve member card information. This is commonly used for organizing followed users into custom categories.

## Architecture

### Domain Layer

**Entities:**
- `MemberCardInfoData` - User card information (reused from models)
- `MemberTagItemModel` - Follow tag item

**Repository Interface:**
- `FollowRepository` - Abstract contract for follow operations

**Use Cases:**
- `GetMemberCardInfoUseCase` - Retrieve user card info by MID
- `GetFollowUpTagsUseCase` - Retrieve all follow tags
- `CreateFollowTagUseCase` - Create a new follow tag
- `UpdateFollowTagUseCase` - Update existing tag name
- `DeleteFollowTagUseCase` - Delete a follow tag

### Data Layer

**Data Sources:**
- `FollowRemoteDataSource` - Remote API data source for follow operations
- `FollowRemoteDataSourceImpl` - Concrete implementation

**Repositories:**
- `FollowRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `FollowPageV2` - Main follow management page

**Providers:**
- `FollowController` - Controller for managing follow state
- `FollowState` - State management for follow feature
- Various providers for dependency injection

## Usage

```dart
import 'package:PiliPlus/features/follow/follow.dart';

// Initialize repository and use cases
final repository = FollowRepositoryImpl(
  remoteDataSource: FollowRemoteDataSourceImpl(),
);
final getMemberCardInfo = GetMemberCardInfoUseCase(repository);
final getFollowUpTags = GetFollowUpTagsUseCase(repository);
final createFollowTag = CreateFollowTagUseCase(repository);
final updateFollowTag = UpdateFollowTagUseCase(repository);
final deleteFollowTag = DeleteFollowTagUseCase(repository);

// Get user card info
final cardResult = await getMemberCardInfo(123456);
cardResult.when(
  success: (info) {
    print('User: ${info.name}');
  },
  error: (error) {
    print('Error: $error');
  },
);

// Get all follow tags
final tagsResult = await getFollowUpTags();
tagsResult.when(
  success: (tags) {
    for (var tag in tags) {
      print('Tag: ${tag.name}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Create new tag
final createResult = await createFollowTag('My Favorites');

// Update tag
final updateResult = await updateFollowTag(1, 'Updated Name');

// Delete tag
final deleteResult = await deleteFollowTag(1);
```

## Data Flow

1. User opens follow management page
2. Presentation layer calls `GetFollowUpTagsUseCase` to load existing tags
3. User creates a new tag
4. Presentation layer calls `CreateFollowTagUseCase` with tag name
5. Use case invokes repository method
6. Repository makes API call through remote data source
7. Result is returned to presentation layer for UI update

## Tag Operations

**Create Tag:**
- Input: Tag name (String)
- Output: Success/Error state

**Update Tag:**
- Input: Tag ID (int) and new name (String)
- Output: Success/Error state

**Delete Tag:**
- Input: Tag ID (int)
- Output: Success/Error state
- Note: Deleting a tag does not delete users assigned to that tag

**Get Member Card Info:**
- Input: User MID (int)
- Output: Member card information including name, avatar, etc.

## State Management

The feature uses Riverpod for state management with `FollowController`:
- Manages tag list state
- Handles loading and error states
- Provides reactive updates to UI
