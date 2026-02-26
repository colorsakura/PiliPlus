# Follow Type Feature

Clean Architecture implementation for following/followers list functionality.

## Overview

This feature handles displaying different types of follow relationships:
- **Followed** (followers): Users who follow the specified user
- **Follow Same** (mutual): Users who have similar follows to the specified user

## Architecture

### Domain Layer

**Entities:**
- `FollowTypeParams` - Base parameters for fetching follow lists
- `FollowedParams` - Parameters for fetching followers
- `FollowSameParams` - Parameters for fetching mutual follows

**Repository Interface:**
- `FollowTypeRepository` - Abstract contract for follow type operations

**Use Cases:**
- `FetchFollowed` - Fetch users who follow the specified user
- `FetchFollowSame` - Fetch users with mutual follows

### Data Layer

**Data Sources:**
- `FollowTypeRemoteDataSource` - Interface for follow type data source
- `FollowTypeRemoteDataSourceImpl` - Implementation using UserHttp

**Repositories:**
- `FollowTypeRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Fetch Followers

```dart
import 'package:PiliPlus/features/follow_type/follow_type.dart';

// Initialize repository and use case
final remoteDataSource = FollowTypeRemoteDataSourceImpl();
final repository = FollowTypeRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final fetchFollowed = FetchFollowed(repository);

// Prepare parameters
final params = FollowedParams(
  mid: 12345, // User ID to fetch followers for
  page: 1,
);

// Fetch followers
final result = await fetchFollowed(params);

if (result case Success(:final response)) {
  print('Found ${response.list?.length} followers');
  print('Total: ${response.total}');
} else if (result case Error(:final errorMsg)) {
  print('Fetch failed: $errorMsg');
}
```

### Fetch Mutual Follows

```dart
final fetchFollowSame = FetchFollowSame(repository);

final params = FollowSameParams(
  mid: 12345,
  page: 1,
);

final result = await fetchFollowSame(params);
```

### Pagination

```dart
// Fetch next page
final nextPageParams = params.nextPage();
final nextResult = await fetchFollowed(nextPageParams);
```

## Follow Types

The feature supports two main operations:

1. **Followed** (followers) - Users who follow the specified user
   - Returns list of followers with pagination

2. **Follow Same** (mutual follows) - Users with similar followings
   - Returns list of users who have similar follow patterns

## Architecture Note

This feature uses `UserHttp.followedUp` and `UserHttp.followSameUp` API endpoints for data fetching. The repository implementations wrap these HTTP calls, providing clean abstraction layers for the application logic.

The presentation layer uses `CommonListController` as a base class for managing list state, loading, and pagination.
