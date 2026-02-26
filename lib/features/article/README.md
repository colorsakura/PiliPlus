# Article Feature - Clean Architecture

This feature has been refactored to follow **Clean Architecture** principles.

## Architecture Layers

### Domain Layer (Core Business Logic)
- **Entities**: Core business objects
  - `ArticleSummaryEntity`: Summary information (author, title, cover)
  - `OpusContentEntity`: Opus (dynamic article) content
  - `ReadContentEntity`: Read (column article) content
  - `ArticleStatEntity`: Article statistics (likes, favorites, etc.)

- **Repositories**: Abstract interfaces for data access
  - `ArticleRepository`: Defines data operations contract

- **Use Cases**: Business logic operations
  - `GetOpusDetail`: Fetch opus article details
  - `GetReadArticleDetail`: Fetch column article details
  - `GetArticleInfo`: Fetch article metadata
  - `LikeArticle`: Like/unlike article
  - `FavoriteArticle`: Favorite/unfavorite article

### Data Layer (Data Access)
- **Data Sources**: Raw data providers
  - `ArticleRemoteDataSource`: API data source
  - `ArticleRemoteDataSourceImpl`: Bilibili API implementation

- **Repositories**: Data repository implementations
  - `ArticleRepositoryImpl`: Implements `ArticleRepository` using remote data source

### Presentation Layer (UI)
- **Pages**: Screen widgets
  - `ArticlePage`: Main article display page

- **Controllers**: State management
  - `ArticleController`: Manages article state and interactions

- **Widgets**: Reusable UI components
  - `ArticleOpus`: Article content renderer
  - `HtmlRender`: HTML content renderer
  - `OpusContent`: Opus content renderer

- **Providers**: Dependency injection
  - `article_providers.dart`: Riverpod providers for DI

## Dependency Flow

```
Presentation → Domain → Data
     ↓            ↓         ↓
   UI       Use Cases  Data Sources
            & Repos
```

## Key Principles

1. **Dependency Rule**: Dependencies point inward (Data → Domain ← Presentation)
2. **Separation of Concerns**: Each layer has specific responsibilities
3. **Testability**: Business logic is isolated from UI and data sources
4. **Scalability**: Easy to add new features or modify existing ones

## Usage Example

```dart
// Using providers in a widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getOpusDetail = ref.watch(getOpusDetailUseCaseProvider);

    // Fetch article
    getOpusDetail('opus_id').then((result) {
      result.when(
        success: (content) => print('Loaded: ${content.title}'),
        error: (error) => print('Error: $error'),
      );
    });

    return Container();
  }
}
```

## Migration Notes

- The controller still uses `DynamicsHttp` and `FavHttp` directly for some operations to maintain UI data compatibility
- Full migration to use cases for all operations is planned for future updates
- The presentation layer currently uses GetX for state management; migration to Riverpod is in progress
