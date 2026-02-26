# Follow Same Feature

Clean Architecture implementation for "Common Follows" (共同关注) functionality.

## Overview

This feature displays users that both the current user and a target user follow. It helps discover mutual interests and find new creators to follow.

## Architecture

### Domain Layer

**Entities:**
- Various follow-related entities

**Repository Interface:**
- `FollowSameRepository` - Abstract contract for common follows operations

**Use Cases:**
- `GetSameFollowListUseCase` - Retrieve list of common followed users
- `GetUserNameUseCase` - Get user name by ID

### Data Layer

**Data Sources:**
- Remote API data source for follow data

**Models:**
- `FollowData` - Follow list data model
- Individual follow item models

**Repositories:**
- `FollowSameRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Common follows page

**Providers:**
- `FollowSameController` - Controller for managing state
- `FollowSameProvider` - Riverpod provider for follow data

## Usage

```dart
import 'package:PiliPlus/features/follow_same/follow_same.dart';

// Initialize repository and use cases
final repository = FollowSameRepositoryImpl(
  remoteDataSource: FollowSameRemoteDataSourceImpl(),
);
final getSameFollowList = GetSameFollowListUseCase(repository);
final getUserName = GetUserNameUseCase(repository);

// Get common follows with target user
final result = await getSameFollowList(
  mid: 123456,
  pn: 1,
);

result.when(
  success: (data) {
    print('Common follows: ${data.total}');
    for (var user in data.list ?? []) {
      print(user.uname);
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Get user name
final userName = await getUserName(123456);
print('User: $userName');
```

## Data Flow

1. User views another user's profile
2. User clicks on "Common Follows" section
3. Presentation layer calls `GetSameFollowListUseCase` with target user ID
4. Use case invokes repository method
5. Repository fetches data from remote API
6. Results are displayed showing mutual follows

## Use Cases

Common use cases include:
- Finding creators both users enjoy
- Discovering content through shared interests
- Expanding own following list
- Understanding taste compatibility
- Social discovery

## Pagination

- `pn` - Page number (1-indexed)
- Each page shows fixed number of users
- Total count available in response
