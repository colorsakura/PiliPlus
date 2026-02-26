# Reply Feature

Clean Architecture implementation for reply/comment functionality.

## Overview

This feature handles all reply and comment-related operations including:
- Fetching reply lists
- Liking/disliking replies
- Managing second-level replies (reply to reply)
- Getting emote lists for replies
- Managing reply top status
- Reporting replies
- Reply interaction info
- Reply subject modification (close/open comments)

## Architecture

### Domain Layer

**Repository Interface:**
- `ReplyRepository` - Abstract contract for all reply data operations

**Use Cases:**
- `GetReplyList` - Fetch reply list for a content
- `GetReplyReplyList` - Fetch second-level replies (replies to a reply)
- `LikeReply` - Like or unlike a reply
- `GetEmoteList` - Get available emotes for replies

### Data Layer

**Data Sources:**
- `ReplyRemoteDataSource` - Handles all HTTP requests for reply operations

**Repositories:**
- `ReplyRepositoryImpl` - Concrete implementation of `ReplyRepository`

## Usage

```dart
import 'package:PiliPlus/features/reply/reply.dart';

// Initialize repository and use cases
final repository = ReplyRepositoryImpl(
  remoteDataSource: ReplyRemoteDataSource(),
);

final getReplyList = GetReplyList(repository);
final likeReply = LikeReply(repository);

// Get replies
final result = await getReplyList(
  isLogin: true,
  oid: 12345,
  nextOffset: '',
  type: 1,
  page: 1,
  sort: 1,
);

// Like a reply
await likeReply(
  type: 1,
  oid: 12345,
  rpid: 67890,
  action: 1,
);
```

## API Operations

The `ReplyRemoteDataSource` provides the following operations:

| Method | Description |
|--------|-------------|
| `replyList` | Get reply list |
| `replyReplyList` | Get second-level reply list |
| `likeReply` | Like or unlike a reply |
| `hateReply` | Hate or unhate a reply (dislike) |
| `getEmoteList` | Get available emotes |
| `replyTop` | Set or cancel reply top status |
| `report` | Report a reply |
| `replyInteraction` | Get reply interaction info |
| `replySubjectModify` | Modify reply subject (close/open comments) |
