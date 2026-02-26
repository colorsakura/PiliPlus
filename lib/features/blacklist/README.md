# Blacklist Feature

Clean Architecture implementation for user blacklist functionality.

## Overview

This feature manages the user's blacklist - users who have been blocked from interacting. Users can view their blocked users list and remove users from the blacklist.

## Architecture

### Domain Layer

**Entities:**
- `BlacklistItemEntity` - Represents a blocked user with profile information
- `BlacklistResultEntity` - Contains blacklist items with pagination info

**Repository Interface:**
- `BlacklistRepository` - Abstract contract for blacklist operations

**Use Cases:**
- `FetchBlacklistUseCase` - Retrieve paginated blacklist
- `RemoveFromBlacklistUseCase` - Remove a user from blacklist

### Data Layer

**Data Sources:**
- `BlacklistRemoteDataSource` - Remote API data source for blacklist

**Models:**
- `BlackListItem` - API response model for blacklist items

**Repositories:**
- `BlacklistRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `BlacklistPage` - Main page for displaying blocked users

**Providers:**
- `BlacklistController` - Controller for managing blacklist state
- `BlacklistProvider` - Riverpod provider for blacklist data

## Usage

```dart
import 'package:PiliPlus/features/blacklist/blacklist.dart';

// Initialize repository and use cases
final repository = BlacklistRepositoryImpl(
  remoteDataSource: BlacklistRemoteDataSourceImpl(),
);
final fetchBlacklist = FetchBlacklistUseCase(repository);
final removeFromBlacklist = RemoveFromBlacklistUseCase(repository);

// Fetch blacklist with pagination
final result = await fetchBlacklist(pn: 1, ps: 20);

for (var item in result.items) {
  print('Blocked: ${item.uname} (${item.mid})');
  print('Added: ${DateTime.fromMillisecondsSinceEpoch(item.mtime * 1000)}');
}

print('Total blocked: ${result.total}');
print('Has more: ${result.hasMore}');

// Remove user from blacklist
final success = await removeFromBlacklist(mid: 123456);
if (success) {
  print('User removed from blacklist');
}
```

## Data Flow

1. User opens blacklist page
2. Presentation layer calls `FetchBlacklistUseCase` with page parameters
3. Use case invokes repository method
4. Repository fetches data from remote data source
5. Data is transformed to domain entities
6. Result is returned to presentation layer for UI rendering
7. User can remove users via `RemoveFromBlacklistUseCase`
8. UI updates after successful removal

## Entity Structure

**BlacklistItemEntity** contains:
- `mid` - User ID
- `uname` - Username
- `face` - Avatar URL
- `sign` - User bio/signature
- `mtime` - Timestamp when user was added to blacklist
- `attribute` - User attribute flags
- `tag` - User tags
- `special` - Special markers
- `faceNft` - NFT avatar flag
- `officialVerify` - Official verification information
- `vip` - VIP status information
- `nftIcon` - NFT icon URL
- `recReason` - Recommendation reason
- `trackId` - Tracking ID
- `followTime` - Follow time string

**BlacklistResultEntity** contains:
- `items` - List of blocked users
- `total` - Total count of blocked users
- `hasMore` - Whether more pages exist
- `currentPage` - Current page number

## Pagination

The feature supports paginated loading:
- `pn` - Page number (1-indexed)
- `ps` - Page size (number of items per page)
- `hasMore` indicates if next page is available

## Blocking Context

When a user is blocked:
- Their comments are hidden
- Their messages are filtered
- They cannot follow the user
- Their interactions are limited

## Model Mapping

The entity maps to/from `BlackListItem` model:
- Each field is directly mapped
- `fromModel()` factory creates entity from model
- `toModel()` method converts entity back to model
