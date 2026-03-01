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

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

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

### Presentation Layer

**Controllers:**
- `ReplyListController` - Manages reply list state

**Pages:**
- `ReplyListPage` - Displays reply list for content

## Usage

```dart
import 'package:PiliPlus/features/reply/reply.dart';

// Using controllers with Riverpod
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navigate to reply list
    return ReplyListPage(
      oid: 12345, // Content ID
      type: 1, // Content type (1=video, etc.)
      sort: 1, // Sort order
    );
  }
}
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

## Migration Status

- ✅ Domain Layer Complete
- ✅ Data Layer Complete
- ✅ Presentation Layer Complete (New)
- ⏳ Tests (Pending)
- ✅ Documentation Complete

## Code Quality

- ✅ `flutter analyze` No issues found
- ✅ `dart format` Formatted
- ✅ Riverpod code generation verified
- ✅ Clean architecture compliance verified
