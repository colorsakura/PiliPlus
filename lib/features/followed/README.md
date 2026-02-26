# Followed Feature

Clean Architecture implementation for "Also Followed" (我关注的也关注了) functionality.

## Overview

This feature displays users who are followed by both the current user and a target user. It helps discover common interests and connections between users.

## Architecture

### Domain Layer

**Entities:**
- `FollowedItemEntity` - Represents a user that is also followed (typealias to `FollowItemModel`)

**Repository Interface:**
- `FollowedRepository` - Abstract contract for followed operations

**Use Cases:**
- `GetFollowedListUseCase` - Retrieve list of common followed users
- `GetUserNameUseCase` - Get user name by ID

### Data Layer

**Data Sources:**
- Remote API data source for followed data

**Models:**
- `FollowData` - API response model for follow data
- `FollowItemModel` - Individual follow item model

**Repositories:**
- `FollowedRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `FollowedPageV2` - Main page for displaying common followed users

**Providers:**
- `FollowedController` - Controller for managing followed state
- `FollowedProvider` - Riverpod provider for followed data

## Usage

```dart
import 'package:PiliPlus/features/followed/followed.dart';

// Initialize repository and use cases
final repository = FollowedRepositoryImpl(
  remoteDataSource: FollowedRemoteDataSourceImpl(),
);
final getFollowedList = GetFollowedListUseCase(repository);
final getUserName = GetUserNameUseCase(repository);

// Get list of users also followed by target user
final result = await getFollowedList(
  mid: 123456,  // Target user ID
  pn: 1,
);

result.when(
  success: (data) {
    print('Common follows: ${data.total}');
    for (var user in data.list ?? []) {
      print('User: ${user.uname}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Get user name by ID
final userName = await getUserName(123456);
print('User name: $userName');
```

## Data Flow

1. User navigates to a profile page
2. User clicks on "Also Followed" section
3. Presentation layer calls `GetFollowedListUseCase` with target user ID
4. Use case invokes repository method
5. Repository fetches data from remote data source
6. Data is returned to presentation layer
7. List of common followed users is displayed
8. User names are fetched via `GetUserNameUseCase` if needed

## Entity Structure

**FollowedItemEntity** (aliased to `FollowItemModel`) contains:
- `mid` - User ID
- `uname` - Username
- `face` - Avatar URL
- `sign` - User bio/signature
- `officialVerify` - Official verification info
- `vip` - VIP status
- And other profile information

## Pagination

The feature supports paginated loading:
- `pn` - Page number (1-indexed)
- Each page contains a fixed number of users

## Use Case Context

This feature is typically used when:
- Viewing a user's profile
- Exploring common interests
- Finding mutual connections
- Discovering content from shared followed creators

## Migration Notes

This feature uses `typedef` to alias the existing `FollowItemModel` as `FollowedItemEntity`. This is a transitional approach during Clean Architecture migration.

In a complete implementation:
1. Create pure domain entity in domain layer
2. Map data layer models to domain entities in repository
3. Remove dependency on data layer models from domain layer
