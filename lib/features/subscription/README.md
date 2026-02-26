# Subscription Feature

Clean Architecture implementation for subscription folders (订阅合集) functionality.

## Overview

This feature manages user's subscription folders - custom collections where users can organize creators and content they follow. Users can view folders, cancel subscriptions, and manage their subscriptions.

## Architecture

### Domain Layer

**Entities:**
- `SubData` - Contains subscription folders and metadata

**Repository Interface:**
- `SubscriptionRepository` - Abstract contract for subscription operations

**Use Cases:**
- `GetUserSubFoldersUseCase` - Retrieve user's subscription folders
- `CancelSubUseCase` - Cancel a subscription

### Data Layer

**Data Sources:**
- `SubscriptionRemoteDataSource` - Remote API data source

**Models:**
- `SubData` - Subscription data model
- Individual subscription folder models

**Repositories:**
- `SubscriptionRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `SubscriptionPageV2` - Main subscription folders page

**Providers:**
- `SubscriptionController` - Controller for managing state
- `SubscriptionProvider` - Riverpod provider for subscription data

## Usage

```dart
import 'package:PiliPlus/features/subscription/subscription.dart';

// Initialize repository and use cases
final repository = SubscriptionRepositoryImpl(
  remoteDataSource: SubscriptionRemoteDataSourceImpl(),
);
final getUserSubFolders = GetUserSubFoldersUseCase(repository);
final cancelSub = CancelSubUseCase(repository);

// Get subscription folders
final result = await getUserSubFolders(
  pn: 1,
  ps: 20,
  mid: 123456,
);

result.when(
  success: (data) {
    print('Total folders: ${data.total}');
    for (var folder in data.list ?? []) {
      print('${folder.name} - ${folder.count} items');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Cancel a subscription
final cancelResult = await cancelSub(
  id: 789,
  type: 12,  // Subscription type
);
```

## Data Flow

1. User opens subscriptions page
2. Presentation layer calls `GetUserSubFoldersUseCase`
3. Use case invokes repository method
4. Repository fetches folders from remote API
5. Folders are displayed in UI
6. User can cancel subscriptions via `CancelSubUseCase`

## Subscription Folders

Users can organize subscriptions into folders:
- Custom folder names
- Group related creators
- Organize by topic or category
- Quick access to content

## Subscription Types

Different types of subscriptions:
- `type: 12` - User subscription
- Other types for different content categories

## Pagination

- `pn` - Page number (1-indexed)
- `ps` - Page size (items per page)
- `total` in response indicates total count

## Folder Information

Each folder contains:
- `id` - Folder identifier
- `name` - Folder name
- `count` - Number of subscriptions
- `mid` - Owner user ID
- And other metadata

## Cancel Subscription

Users can cancel:
- Individual subscriptions
- From specific folders
- Using folder ID and subscription type

## Use Cases

Users use subscription folders to:
- Organize followed creators
- Group by content type
- Manage many subscriptions
- Quickly find specific content
- Bulk manage subscriptions
