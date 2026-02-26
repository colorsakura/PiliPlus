# HistorySearch Feature - Clean Architecture

This feature has been refactored to follow **Clean Architecture** principles.

## Architecture Layers

### Domain Layer (Core Business Logic)
- **Entities**: Core business objects
  - `HistorySearchResultEntity`: Search results with history items
  - `HistorySearchParamsEntity`: Search parameters (keyword, pagination, account)
  - `HistoryDeleteParamsEntity`: Parameters for deleting history items

- **Repositories**: Abstract interfaces for data access
  - `HistorySearchRepository`: Defines history operations contract

- **Use Cases**: Business logic operations
  - `SearchHistory`: Search watch history by keyword
  - `DeleteHistoryItem`: Delete single history item
  - `DeleteMultipleHistoryItems`: Batch delete history items

### Data Layer (Data Access)
- **Data Sources**: Raw data providers
  - `HistoryRemoteDataSource` (interface): Abstract data source interface
  - `HistoryRemoteDataSourceImpl`: Implementation using `UserHttp`

- **Repositories**: Data repository implementations
  - `HistorySearchRepositoryImpl`: Implements `HistorySearchRepository` using remote data source

### Presentation Layer (UI)
- **Pages**: Screen widgets
  - `HistorySearchPage`: History search page

- **Controllers**: State management
  - `HistorySearchController`: Manages search state and deletion

- **Providers**: Dependency injection
  - `history_search_providers.dart`: Riverpod providers for DI

## Dependency Flow

```
Presentation → Domain → Data
     ↓            ↓         ↓
   UI       Use Cases  Data Sources
            & Repos
```

## Key Features

1. **Search History**: Search watch history by keyword
2. **Delete Items**: Delete single or multiple history items
3. **Multi-select**: Support for batch operations
4. **Pagination**: Paginated search results

## Usage Example

```dart
// Using providers in a widget
class HistorySearchWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryUseCaseProvider);

    Future<void> performSearch(String keyword) async {
      final params = HistorySearchParamsEntity(
        keyword: keyword,
        account: 'user_account',
        page: 1,
      );

      final result = await searchHistory(params);

      result.when(
        success: (searchResult) {
          print('Found ${searchResult.historyItems.length} items');
          if (!searchResult.hasMore) {
            print('No more results');
          }
        },
        error: (error) => print('Error: $error'),
      );
    }

    return ElevatedButton(
      onPressed: () => performSearch('music'),
      child: Text('Search History'),
    );
  }
}
```

## Technical Details

- Uses `UserHttp` for history search and delete API
- Supports history keys in format "business_kid" for deletion
- Integrates with common search and multi-select mixins
- Handles pagination and loading states
- Account-aware history management

## Migration Notes

- The implementation wraps the existing `UserHttp` functionality
- The controller still uses direct API calls in some places for compatibility
- Mixed with `CommonSearchController` and `DeleteItemMixin` for shared functionality
