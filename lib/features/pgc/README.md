# PGC Feature

Professional Generated Content (anime, movies, TV shows) browsing.

## Architecture

### Domain Layer
- **Repository**: PGC repository
- **Use Cases**: `FetchPGC`, `FetchPGCDetail`, `FollowPGC`

### Data Layer
- **Remote DataSource**: PGC remote data source
- **Repository Implementation**: PGC repository implementation

### Presentation Layer
- **Pages**: PGC browsing interface
- **Controllers**: PGC content controller

## Key Features

- **Browse Content**: Anime, movies, TV shows
- **Content Details**: Episodes, ratings, reviews
- **Follow System**: Track favorite series
- **Continue Watching**: Resume from last position

## Usage

```dart
// Fetch PGC content
final result = await fetchPGC(seasonId: 123);

// Follow a series
await followPGC(seasonId: 123);
```
