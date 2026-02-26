# Msg At Me Feature

Clean Architecture implementation for "@Me" notifications functionality.

## Overview

This feature handles notifications where the user has been mentioned (@). Users can view their mentions and remove individual notifications.

## Architecture

### Domain Layer

**Entities:**
- `MsgAtItemEntity` - Represents an @Me notification item (typealias to `MsgAtItem`)

**Repository Interface:**
- `MsgAtMeRepository` - Abstract contract for @Me notification operations

**Use Cases:**
- `GetMsgAtMeItemsUseCase` - Retrieve @Me notifications with cursor pagination
- `RemoveMsgItemUseCase` - Remove a notification item

### Data Layer

**Data Sources:**
- Remote API data source for @Me notifications

**Models:**
- `MsgAtData` - API response model for @Me data
- `MsgAtItem` - Individual notification item model

**Repositories:**
- `MsgAtMeRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `MsgAtMePageV2` - Main page for displaying @Me notifications

**Providers:**
- `MsgAtMeController` - Controller for managing notifications state
- `MsgAtMeProvider` - Riverpod provider for notifications data

## Usage

```dart
import 'package:PiliPlus/features/msg_at_me/msg_at_me.dart';

// Initialize repository and use cases
final repository = MsgAtMeRepositoryImpl(
  remoteDataSource: MsgAtMeRemoteDataSourceImpl(),
);
final getMsgAtMeItems = GetMsgAtMeItemsUseCase(repository);
final removeMsgItem = RemoveMsgItemUseCase(repository);

// Fetch @Me notifications
final result = await getMsgAtMeItems(
  cursor: null,  // First page
  cursorTime: null,
);

result.when(
  success: (data) {
    print('Total: ${data.total}');
    for (var item in data.items ?? []) {
      print('Mention by: ${item.user?.uname}');
      print('Content: ${item.content}');
      print('Time: ${item.ctime}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Remove a notification
final removeResult = await removeMsgItem(id: 'notification_id');
```

## Data Flow

1. User navigates to @Me notifications page
2. Presentation layer calls `GetMsgAtMeItemsUseCase`
3. Use case invokes repository method with cursor
4. Repository fetches data from remote data source
5. Data is returned to presentation layer
6. Notifications are displayed with user info, content, and timestamp
7. User can remove notifications via `RemoveMsgItemUseCase`

## Entity Structure

**MsgAtItemEntity** (aliased to `MsgAtItem`) contains:
- `id` - Notification ID
- `user` - User who mentioned (@) the current user
- `content` - Notification content/message
- `ctime` - Creation timestamp
- `source` - Source of the mention (comment, post, etc.)
- `item` - Reference to the mentioned item
- And other notification metadata

## Cursor-Based Pagination

The feature uses cursor-based pagination:
- `cursor` - Cursor for next page (null for first page)
- `cursorTime` - Timestamp cursor for pagination
- Returns data with next cursor for subsequent requests

## Notification Sources

@Me notifications can come from:
- Comments - User mentioned in comments
- Posts/Dynamics - User mentioned in posts
- Replies - User mentioned in replies
- Other platform features that support mentions

## Remove Notification

Users can remove individual notifications:
- Removes from local list
- May also mark as read on server
- `id` parameter identifies the notification to remove

## Migration Notes

This feature uses `typedef` to alias the existing `MsgAtItem` as `MsgAtItemEntity`. This is a transitional approach during Clean Architecture migration.

In a complete implementation:
1. Create pure domain entity for @Me notifications
2. Map data layer models to domain entities in repository
3. Remove dependency on data layer models from domain layer
