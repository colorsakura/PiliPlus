# Message Feature

Clean Architecture implementation for message functionality.

## Overview

This feature handles all message-related operations including:
- Reply messages (@ replies to your content)
- At messages (@ mentions)
- Like messages (when someone likes your content)
- Unread counts for message types

## Architecture

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

## Usage

```dart
import 'package:PiliPlus/features/msg/msg.dart';

// Initialize repository and use cases
final repository = MsgRepositoryImpl(
  remoteDataSource: MsgRemoteDataSource(),
);

final getReplyMessages = GetReplyMessages(repository);
final getAtMessages = GetAtMessages(repository);
final getLikeMessages = GetLikeMessages(repository);
final getMsgFeedUnread = GetMsgFeedUnread(repository);

// Get reply messages
final result = await getReplyMessages(
  cursor: null,
  cursorTime: null,
);

if (result case Success(:final data)) {
  print('Total reply messages: ${data.total}');
  for (final item in data.items ?? []) {
    print('Reply from: ${item.reply.uname}');
  }
}

// Get unread counts
final unreadResult = await getMsgFeedUnread();
if (unreadResult case Success(:final unreadData)) {
  print('Reply unread: ${unreadData.reply}');
  print('At unread: ${unreadData.at}');
  print('Like unread: ${unreadData.like}');
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
