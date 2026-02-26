# Live DM Block Feature

Manages danmaku (live comments) blocking functionality.

## Architecture

### Domain Layer
- **Repository**: Danmaku block repository
- **Use Cases**: Block keywords, users, or patterns

### Data Layer
- **Remote DataSource**: Danmaku block remote data source
- **Repository Implementation**: Danmaku block repository implementation

### Presentation Layer
- **Pages**: Danmaku block settings interface
- **Controllers**: Block list management

## Key Features

- **Keyword Blocking**: Filter unwanted words in live chat
- **User Blocking**: Block specific users
- **Pattern Matching**: Regex-based filtering
- **Import/Export**: Share block lists

## Usage

```dart
// Add keyword to block list
await repository.addBlockKeyword(keyword);

// Get all blocked items
final blocks = await repository.getBlockList();
```
