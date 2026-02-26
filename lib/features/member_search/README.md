# Member Search Feature

Search for members (users) by keyword.

## Architecture

### Domain Layer
- **Repository**: Member search repository
- **Use Cases**: `SearchMembers`

### Data Layer
- **Remote DataSource**: Member search remote data source
- **Repository Implementation**: Member search repository implementation

### Presentation Layer
- **Pages**: Member search results page
- **Controllers**: Search controller with suggestions

## Key Features

- **Keyword Search**: Find users by username
- **Search Suggestions**: Auto-complete while typing
- **Result Pagination**: Paginated search results

## Usage

```dart
// Search for members
final result = await searchMembers(keyword: 'username');
```
