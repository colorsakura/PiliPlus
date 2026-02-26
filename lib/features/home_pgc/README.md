# Home PGC Feature

Displays Professional Generated Content (anime, movies, TV) on the home page.

## Architecture

### Domain Layer
- **Repository**: PGC content repository
- **Use Cases**: Fetch home PGC feed

### Data Layer
- **Remote DataSource**: PGC remote data source
- **Repository Implementation**: PGC repository implementation

### Presentation Layer
- **Pages**: PGC content display on home page
- **Controllers**: PGC feed controller

## Key Features

- **Personalized Feed**: Curated anime, movies, and TV shows
- **Continue Watching**: Resume watching from where you left off
- **Recommendations**: Content based on viewing history

## Usage

```dart
// Fetch PGC feed for home page
final result = await fetchHomePgc();
```
