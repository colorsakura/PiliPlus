# Dynamics Mention Feature

Manages @mention functionality for dynamic posts.

## Architecture

### Domain Layer
- **Repository**: Mention repository interface
- **Use Cases**: Search users for mentioning

### Data Layer
- **Remote DataSource**: Mention remote data source
- **Repository Implementation**: Mention repository implementation

### Presentation Layer
- **Controllers**: `DynamicsMentionController`
- **Pages**: Mention selection interface

## Key Features

- **User Search**: Search for users by username/UID
- **Suggestion List**: Display matching users for @mention
- **Quick Insert**: Insert mentioned users into dynamic content

## Usage

```dart
// Search users to mention
final controller = Get.find<DynamicsMentionController>();
await controller.searchUsers(keyword);
```

## Integration

This feature provides the @mention autocomplete functionality when creating or editing dynamic posts, allowing users to tag other users in their content.
