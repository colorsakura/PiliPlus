# Group Panel Feature

Clean Architecture implementation for follow-up group management.

## Overview

This feature handles managing follow-up groups for users. It allows adding users to specific groups (tags) for better organization of followed users.

## Architecture

### Domain Layer

**Entities:**
- `GroupTagEntity` - Represents a follow-up group tag
- `AddUserToGroupsParams` - Parameters for adding user to groups

**Repository Interface:**
- `GroupPanelRepository` - Abstract contract for group panel operations

**Use Cases:**
- `FetchGroupTags` - Fetch all follow-up group tags
- `AddUserToGroups` - Add user to specified groups

### Data Layer

**Data Sources:**
- `GroupPanelRemoteDataSource` - Interface for group panel data source
- `GroupPanelRemoteDataSourceImpl` - Implementation using MemberHttp

**Repositories:**
- `GroupPanelRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Fetch Group Tags

```dart
import 'package:PiliPlus/features/group_panel/group_panel.dart';

// Initialize repository and use case
final remoteDataSource = GroupPanelRemoteDataSourceImpl();
final repository = GroupPanelRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final fetchGroupTags = FetchGroupTags(repository);

// Fetch group tags
final result = await fetchGroupTags();

if (result case Success(:final response)) {
  print('Found ${response.length} groups');
  for (final tag in response) {
    print('${tag.name}: ${tag.count} users');
  }
} else if (result case Error(:final errorMsg)) {
  print('Fetch failed: $errorMsg');
}
```

### Add User to Groups

```dart
final addUserToGroups = AddUserToGroups(repository);

// Add to default group
final params = AddUserToGroupsParams(
  mid: '12345',
  tagIds: '0',
);

// Add to specific groups (comma-separated)
final params2 = AddUserToGroupsParams(
  mid: '12345',
  tagIds: '1,2,3',
);

final result = await addUserToGroups(params);

if (result case Success()) {
  print('User added to groups successfully');
} else if (result case Error(:final errorMsg)) {
  print('Add failed: $errorMsg');
}
```

### Group Tag Entity

```dart
// Create from model
final entity = GroupTagEntity.fromModel(memberTagItemModel);

// Check if default group
print(entity.isDefault); // true if tagId == 0

// Access properties
print(entity.name);
print(entity.count);
```

## Group Management

Groups are used to organize followed users:
- **Default group** (tagId: 0) - Users without specific grouping
- **Custom groups** - User-defined groups for categorization

## Architecture Note

This feature uses `MemberHttp.followUpTags` and `MemberHttp.addUsers` API endpoints for data operations. The repository implementations wrap these HTTP calls, providing clean abstraction layers for the application logic.

The presentation layer (`GroupPanel` widget) manages the UI state for group selection and provides callbacks for completing the action.
