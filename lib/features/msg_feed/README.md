# Msg Feed Feature

Manages message feed notifications.

## Architecture

### Domain Layer
- **Repository**: Message feed repository
- **Use Cases**: `FetchMsgFeed`, `MarkAsRead`

### Data Layer
- **Remote DataSource**: Message feed remote data source
- **Repository Implementation**: Message feed repository implementation

### Presentation Layer
- **Pages**: Message feed list
- **Controllers**: Feed controller

## Key Features

- **Notification Feed**: List of recent notifications
- **Read Status**: Track which notifications are read
- **Feed Types**: Likes, comments, follows, etc.

## Usage

```dart
// Fetch message feed
final result = await fetchMsgFeed();

// Mark as read
await markAsRead(feedId: 123);
```
