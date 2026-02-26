# Music Feature - Clean Architecture

This feature has been refactored to follow **Clean Architecture** principles.

## Architecture Layers

### Domain Layer (Core Business Logic)
- **Entities**: Core business objects
  - `MusicDetailEntity`: Music detail information
  - `MusicCommentEntity`: Comment information for music
  - `MusicRecommendEntity`: Recommended music information

- **Repositories**: Abstract interfaces for data access
  - `MusicRepository`: Defines music data operations contract

- **Use Cases**: Business logic operations
  - `GetMusicDetail`: Fetch music details by ID
  - `UpdateMusicFavorite`: Like/unlike music
  - `GetMusicRecommendations`: Fetch music recommendations

### Data Layer (Data Access)
- **Data Sources**: Raw data providers
  - `MusicRemoteDataSource` (interface): Abstract data source interface
  - `MusicRemoteDataSource` (impl): Existing implementation in `music_api_datasource.dart`

- **Repositories**: Data repository implementations
  - `MusicRepositoryImpl`: Implements `MusicRepository` using remote data source

### Presentation Layer (UI)
- **Pages**: Screen widgets
  - `MusicDetailPage`: Music detail display page
  - `MusicRecommendPage`: Music recommendations page

- **Controllers**: State management
  - `MusicDetailController`: Manages music detail state
  - `MusicRecommendController`: Manages music recommendations

- **Providers**: Dependency injection
  - `music_providers.dart`: Riverpod providers for DI

## Dependency Flow

```
Presentation → Domain → Data
     ↓            ↓         ↓
   UI       Use Cases  Data Sources
            & Repos
```

## Key Features

1. **Music Detail**: View complete music information with comments
2. **Favorite Management**: Like/unlike music tracks
3. **Recommendations**: Get personalized music suggestions
4. **Comment Integration**: View and manage music comments

## Usage Example

```dart
// Using providers in a widget
class MusicDetailWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getMusicDetail = ref.watch(getMusicDetailUseCaseProvider);

    // Fetch music detail
    getMusicDetail('music_id').then((result) {
      result.when(
        success: (detail) => print('Loaded: ${detail.title}'),
        error: (error) => print('Error: $error'),
      );
    });

    return Container();
  }
}
```

## Migration Notes

- The existing `MusicRemoteDataSource` class has been adapted with an interface
- An adapter pattern is used to bridge the existing implementation with the new architecture
- Controllers still use the data source directly for some operations to maintain compatibility
- Full migration to use cases for all operations is planned for future updates
