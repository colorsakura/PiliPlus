# Message Feature

Clean Architecture implementation for message functionality.

## Overview

This feature handles all message-related operations including:
- Reply messages (@ replies to your content)
- At messages (@ mentions)
- Like messages (when someone likes your content)
- Unread counts for message types

## Architecture

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### Domain Layer

**Repository Interface:**
- `MsgRepository` - Abstract contract for message data operations

**Use Cases:**
- `GetReplyMessages` - Fetch reply messages
- `GetAtMessages` - Fetch @ mention messages
- `GetLikeMessages` - Fetch like messages
- `GetMsgFeedUnread` - Fetch message feed unread counts

### Data Layer

**Data Sources:**
- `MsgRemoteDataSource` - HTTP client for message API endpoints

**Repositories:**
- `MsgRepositoryImpl` - Concrete implementation wrapping the remote data source

### Presentation Layer

**Controllers:**
- `MsgUnreadController` - Manages message unread counts
- `MsgReplyController` - Manages reply messages
- `MsgAtController` - Manages @ mention messages
- `MsgLikeController` - Manages like messages

**Pages:**
- `MsgListPage` - Unified message list with tab switching

## Usage

```dart
import 'package:PiliPlus/features/msg/msg.dart';

// Using controllers with Riverpod
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadState = ref.watch(msgUnreadControllerProvider);

    // Display unread counts
    return Text('Unread: ${unreadState.totalUnread}');

    // Navigate to message list
    return MsgListPage();
  }
}
```

## API Operations

The `MsgRemoteDataSource` provides the following methods:

| Method | Description |
|--------|-------------|
| `msgFeedReplyMe` | Get reply messages |
| `msgFeedAtMe` | Get @ mention messages |
| `msgFeedLikeMe` | Get like messages |
| `msgFeedUnread` | Get message feed unread counts |
| `msgUnread` | Get single unread count |
| `msgLikeDetail` | Get like details |
| `uploadImage` | Upload image |
| `createTextDynamic` | Create text dynamic |
| `removeDynamic` | Remove dynamic |
| `removeMsg` | Remove conversation |
| `delMsgfeed` | Delete messages |
| `setTop` | Set top conversation |
| `ackSessionMsg` | Acknowledge session messages |
| `sendMsg` | Send message |
| `setPushSs` | Set push settings |

## Message Types

The feature supports different message types:
- **Reply** - Replies to your comments or content
- **At** - @ mentions in comments or content
- **Like** - Likes on your content
- **System** - System notifications

Each type has its own unread count that can be retrieved through `getMsgFeedUnread()`.

## Migration Status

- ✅ Domain Layer Complete
- ✅ Data Layer Complete
- ✅ Presentation Layer Complete (New)
- ⏳ Tests (Pending)
- ✅ Documentation Complete

## Code Quality

- ✅ `flutter analyze` No errors found (only warnings in switch statements)
- ✅ `dart format` Formatted
- ✅ Riverpod code generation verified
- ✅ Clean architecture compliance verified
