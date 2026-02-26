# Follow Search Feature

Clean Architecture implementation for searching within followed users functionality.

## Overview

This feature allows users to search through their followed users by name. This is useful when users follow many creators and need to find specific ones quickly.

## Architecture

### Domain Layer

**Entities:**
- Various follow-related entities

**Repository Interface:**
- `FollowSearchRepository` - Abstract contract for follow search operations

**Use Cases:**
- `SearchFollowsUseCase` - Search followed users by name

### Data Layer

**Data Sources:**
- Remote API data source for follow data

**Models:**
- `FollowData` - Follow list data model
- Individual follow item models

**Repositories:**
- `FollowSearchRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Follow search page/dialog

**Providers:**
- `FollowSearchController` - Controller for managing search state
- `FollowSearchProvider` - Riverpod provider for search results

## Usage

```dart
import 'package:PiliPlus/features/follow_search/follow_search.dart';

// Initialize repository and use case
final repository = FollowSearchRepositoryImpl(
  remoteDataSource: FollowSearchRemoteDataSourceImpl(),
);
final searchFollows = SearchFollowsUseCase(repository);

// Search followed users
final result = await searchFollows(
  mid: 123456,
  name: 'gaming',
  page: 1,
  pageSize: 20,
);

result.when(
  success: (data) {
    print('Found: ${data.total}');
    for (var user in data.list ?? []) {
      print(user.uname);
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User opens follow search interface
2. User types search query
3. Presentation layer calls `SearchFollowsUseCase` with search term
4. Use case invokes repository method
5. Repository fetches matching results from API
6. Results are displayed in real-time

## Search Parameters

- `mid` - User ID whose follows are being searched
- `name` - Search query (username or display name)
- `page` - Page number for pagination
- `pageSize` - Number of results per page

## Search Behavior

- Case-insensitive matching
- Partial name matching
- Searches username and display name
- Returns most relevant results first
- Supports pagination for many results

## Use Cases

Common use cases include:
- Finding specific followed creators
- Navigating large follow lists
- Quick access to favorite creators
- Checking if someone is followed
- Managing follow relationships

## UI Integration

Typically implemented as:
- Search bar on follow list page
- Modal/dialog for search
- Real-time search as user types
- Highlighted search terms in results
