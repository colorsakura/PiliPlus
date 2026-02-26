# FavSearch Feature - Clean Architecture

This feature has been refactored to follow **Clean Architecture** principles.

## Architecture Layers

### Domain Layer (Core Business Logic)
- **Entities**: Core business objects
  - `FavSearchResultEntity`: Search results with media items
  - `FavSearchParamsEntity`: Search parameters (keyword, filters, pagination)

- **Repositories**: Abstract interfaces for data access
  - `FavSearchRepository`: Defines favorite search operations contract

- **Use Cases**: Business logic operations
  - `SearchFavorites`: Search favorites in a folder

### Data Layer (Data Access)
- **Data Sources**: Raw data providers
  - `FavSearchRemoteDataSource` (interface): Abstract data source interface
  - `FavSearchRemoteDataSourceImpl`: Implementation using `FavHttp`

- **Repositories**: Data repository implementations
  - `FavSearchRepositoryImpl`: Implements `FavSearchRepository` using remote data source

### Presentation Layer (UI)
- **Pages**: Screen widgets
  - `FavSearchPage`: Favorite search page

- **Controllers**: State management
  - `FavSearchController`: Manages search state and pagination

- **Providers**: Dependency injection
  - `fav_search_providers.dart`: Riverpod providers for DI

## Dependency Flow

```
Presentation → Domain → Data
     ↓            ↓         ↓
   UI       Use Cases  Data Sources
            & Repos
```

## Key Features

1. **Search Favorites**: Search within a favorite folder
2. **Filtering**: Filter by keyword and order type
3. **Pagination**: Paginated search results
4. **Multi-select**: Support for batch operations

## Usage Example

```dart
// Using providers in a widget
class FavSearchWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchFavorites = ref.watch(searchFavoritesUseCaseProvider);

    Future<void> performSearch() async {
      final params = FavSearchParamsEntity(
        keyword: 'music',
        mediaId: 123,
        type: 0,
        order: FavOrderType.mtime,
        page: 1,
      );

      final result = await searchFavorites(params);

      result.when(
        success: (searchResult) {
          print('Found ${searchResult.medias.length} items');
          if (!searchResult.hasMore) {
            print('No more results');
          }
        },
        error: (error) => print('Error: $error'),
      );
    }

    return ElevatedButton(
      onPressed: performSearch,
      child: Text('Search'),
    );
  }
}
```

## Technical Details

- Uses `FavHttp` for favorite folder search API
- Supports various order types (mtime, view, play)
- Integrates with common search and multi-select mixins
- Handles pagination and loading states

## Migration Notes

- The implementation wraps the existing `FavHttp` functionality
- The controller still uses direct API calls in some places for compatibility
- Mixed with `CommonSearchController` and `DeleteItemMixin` for shared functionality
