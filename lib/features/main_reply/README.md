# Main Reply Feature

Displays the main reply list for videos, articles, and other content types.

## Architecture

### Domain Layer
- **Entities**: `FetchMainRepliesParams`
- **Repository**: `MainReplyRepository`
- **Use Cases**: `FetchMainReplies`

### Data Layer
- **Remote DataSource**: `MainReplyRemoteDataSource` / `MainReplyRemoteDataSourceImpl`
- **Repository Implementation**: `MainReplyRepositoryImpl`
- **gRPC Client**: Uses `ReplyGrpc.mainList` for API calls

### Presentation Layer
- **Pages**: `MainReplyPage`
- **Controller**: `MainReplyController` (extends ReplyController)

## Key Features

- **gRPC API**: Uses gRPC for efficient reply list fetching
- **Multiple Modes**: Hot replies (mode=2) and chronological (mode=3)
- **Pagination**: Cursor-based pagination for efficient scrolling
- **Animated FAB**: Floating action button with show/hide animation

## Usage

```dart
// Fetch main replies
final fetchMainReplies = FetchMainReplies(repository);
final result = await fetchMainReplies(FetchMainRepliesParams(
  oid: 123456, // Video ID
  replyType: 1, // Video reply type
  mode: 3, // Chronological order
));
```

## API Notes

- **Reply Types**: Different content types have different replyType values:
  - Video: 1
  - Article: 12
  - Dynamic: 17
  - And more...

- **Modes**:
  - mode=2: Hot replies (sorted by likes)
  - mode=3: Time order (newest first)

- The controller extends `ReplyController` which provides common reply functionality
