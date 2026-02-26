# Search Result Feature

Clean Architecture implementation for search result state management.

## Overview

This feature manages the state for search results across different search types (video, bangumi, media_bangumi, article, topic, user).

## Architecture

### Domain Layer

**Entities:**
- `SearchResultStateEntity` - Represents the search result state with keyword, counts, and navigation info

**Repository Interface:**
- `SearchResultRepository` - Abstract contract for search result state operations

**Use Cases:**
- `ManageSearchResultState` - Manage search result state operations

### Data Layer

**Data Sources:**
- `SearchResultMemoryDataSource` - In-memory data source for state management

**Repositories:**
- `SearchResultRepositoryImpl` - Concrete implementation using memory data source

### Presentation Layer

**Providers (Riverpod):**
- `SearchResultController` - Notifier-based controller for state management
- `searchResultControllerProvider` - Riverpod provider

## Usage

```dart
import 'package:PiliPlus/features/search_result/search_result.dart';

// Using Riverpod provider (recommended)
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(searchResultControllerProvider);
    final state = controller.state;

    // Initialize with keyword
    ref.read(searchResultControllerProvider.notifier).initKeyword('flutter');

    // Update count
    ref.read(searchResultControllerProvider.notifier).updateCount(0, 100);

    return Text('Results: ${state.counts[0]}');
  }
}

// Using Clean Architecture directly
final repository = SearchResultRepositoryImpl(
  memoryDataSource: SearchResultMemoryDataSourceImpl(),
);
final manageState = ManageSearchResultState(repository);

// Initialize
manageState.initKeyword('flutter');

// Update count
manageState.updateCount(0, 100);
```

## State Structure

The `SearchResultStateEntity` contains:
- `keyword` - Current search keyword
- `counts` - Result count for each search type
- `toTopIndex` - Tab index to scroll to top

## Migration Notes

This feature uses Riverpod for state management in the presentation layer while maintaining Clean Architecture principles. The `SearchResultController` provides compatibility methods for legacy GetX code in `search_panel`.

TODO: Remove GetX compatibility layer after search_panel is migrated to Riverpod.
