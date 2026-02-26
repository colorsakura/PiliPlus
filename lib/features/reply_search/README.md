# Reply Search Feature

Clean Architecture implementation for reply/comment search functionality.

## Overview

This feature handles searching replies and comments within videos and articles. It supports searching across different content types (video and article) with pagination.

## Architecture

### Domain Layer

**Entities:**
- `ReplySearchParamsEntity` - Encapsulates search parameters including type, oid, keyword, searchType, and page

**Repository Interface:**
- `ReplySearchRepository` - Abstract contract for reply search operations

**Use Cases:**
- `SearchReplies` - Search replies with given parameters

### Data Layer

**Data Sources:**
- `ReplySearchRemoteDataSource` - Interface for search data source
- `ReplySearchRemoteDataSourceImpl` - Placeholder implementation (currently uses gRPC directly)

**Repositories:**
- `ReplySearchRepositoryImpl` - Concrete implementation using ReplyGrpc

## Usage

```dart
import 'package:PiliPlus/features/reply_search/reply_search.dart';

// Initialize repository and use case
final repository = ReplySearchRepositoryImpl();
final searchReplies = SearchReplies(repository);

// Prepare search parameters
final params = ReplySearchParamsEntity(
  type: 1, // Content type
  oid: 12345, // Content ID
  keyword: 'search term',
  searchType: ReplySearchType.video,
  page: 1,
);

// Search replies
final result = await searchReplies(params);

if (result case Success(:final data)) {
  print('Found ${data.items?.length} results');
  print('Has next: ${data.cursor.hasNext}');
} else if (result case Error(:final errorMsg)) {
  print('Search failed: $errorMsg');
}

// Get next page
final nextPageParams = params.nextPage();
final nextResult = await searchReplies(nextPageParams);
```

## Search Types

The feature supports searching in:
- **Video replies** (`ReplySearchType.video`) - Search within video comments
- **Article replies** (`ReplySearchType.article`) - Search within article comments

## Architecture Note

This feature uses gRPC (`ReplyGrpc.searchItem`) for data fetching. The repository implementation wraps this gRPC call, providing a clean abstraction layer. The remote data source is defined but currently delegates directly to the gRPC implementation since the gRPC client already provides a clean interface.

## State Management

The presentation layer uses Riverpod with two controllers:
- `ReplySearchControllerV2` - Main controller managing UI state
- `ReplySearchChildControllerV2` - Child controller for each search type (video/article)

Both controllers can be updated to use the `SearchReplies` use case for better separation of concerns.
