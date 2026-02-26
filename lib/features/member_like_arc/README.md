# Member Like Archive Feature

Displays member's liked (coin-given) videos archive.

## Architecture

### Domain Layer
- **Repository**: Member like archive repository
- **Use Cases**: `FetchLikeArchive`

### Data Layer
- **Remote DataSource**: Member like archive remote data source
- **Repository Implementation**: Member like archive repository implementation

### Presentation Layer
- **Pages**: Member like archive page
- **Controllers**: Like archive controller

## Key Features

- **Liked Videos**: Videos member has given coins to
- **Archive Pagination**: Browse through like history
- **Video Stats**: View count, coin count, etc.

## Usage

```dart
// Fetch member's liked videos
final result = await fetchLikeArchive(mid: 123456, page: 1);
```
