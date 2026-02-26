# Fan Feature

Clean Architecture implementation for fans (followers) management functionality.

## Overview

This feature handles displaying and managing a user's fans/followers. Users can view their followers list and remove fans if needed.

## Architecture

### Domain Layer

**Entities:**
- `FanEntity` - Represents a fan/follower (currently typealias to `FollowItemModel`)

**Repository Interface:**
- `FanRepository` - Abstract contract for fan operations

### Data Layer

**Data Sources:**
- Remote API data source for fan data

**Models:**
- `FollowData` - API response model for follow data
- `FollowItemModel` - Individual follower item model

**Repositories:**
- `FanRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `FanPageV2` - Main page for displaying fans list

**Providers:**
- `FanController` - Controller for managing fans state
- `FanProvider` - Riverpod provider for fans data

## Usage

```dart
import 'package:PiliPlus/features/fan/fan.dart';

// Initialize repository
final repository = FanRepositoryImpl(
  remoteDataSource: FanRemoteDataSourceImpl(),
);

// Get fans list
final result = await repository.getFans(
  vmid: 123456,
  pn: 1,
  orderType: 'attention',  // or 'online' for online-first order
);

result.when(
  success: (data) {
    print('Total fans: ${data.total}');
    for (var fan in data.list ?? []) {
      print('Fan: ${fan.uname}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Remove a fan
final removeResult = await repository.removeFan(
  mid: 789012,
  act: 2,  // Action type
  reSrc: 1,  // Remove source
);
```

## Data Flow

1. User navigates to fans page
2. Presentation layer calls repository `getFans()` method
3. Repository fetches data from remote data source
4. Data is returned to presentation layer
5. User can remove fans via `removeFan()` method
6. UI updates after successful removal

## Entity Structure

**FanEntity** (aliased to `FollowItemModel`) contains:
- `mid` - User ID of the fan
- `uname` - Username
- `face` - Avatar URL
- `sign` - User bio/signature
- `officialVerify` - Official verification info
- `vip` - VIP status
- And other profile information

## Order Types

The `orderType` parameter controls sort order:
- `attention` - Sort by attention (default)
- `online` - Sort by online status first

## Remove Fan Action

When removing a fan, the following parameters are used:
- `mid` - User ID of the fan to remove
- `act` - Action type (2 for remove)
- `reSrc` - Source of removal action

## Migration Notes

This feature uses `typedef` to alias the existing `FollowItemModel` as `FanEntity`. This is a transitional approach during Clean Architecture migration.

In a complete implementation:
1. Create pure domain entity `FanEntity` in domain layer
2. Map data layer models to domain entities in repository
3. Implement proper use cases for fan operations
4. Remove dependency on data layer models from domain layer
