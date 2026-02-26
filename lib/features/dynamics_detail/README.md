# Dynamics Detail Feature

Clean Architecture implementation for dynamic (post) detail functionality.

## Overview

This feature handles viewing and managing individual dynamic posts. Users can view full post details, change visibility settings, and manage reply permissions.

## Architecture

### Domain Layer

**Entities:**
- Dynamic data structures

**Repository Interface:**
- `DynDetailRepository` - Abstract contract for detail operations

**Use Cases:**
- `GetDynamicDetailUseCase` - Retrieve full post details
- `SetPubSettingUseCase` - Change post visibility
- `SetReplySubjectUseCase` - Modify reply permissions

### Data Layer

**Data Sources:**
- `DynDetailRemoteDataSource` - Remote API data source

**Models:**
- Dynamic detail response models

**Repositories:**
- `DynDetailRepositoryImpl` - Concrete implementation

### Presentation Layer

**Pages:**
- Dynamic detail page

**Providers:**
- `DynDetailController` - Controller for state
- `DynDetailProvider` - Riverpod provider

## Usage

```dart
import 'package:PiliPlus/features/dynamics_detail/dynamics_detail.dart';

// Initialize repository and use cases
final repository = DynDetailRepositoryImpl(
  remoteDataSource: DynDetailRemoteDataSourceImpl(),
);
final getDynamicDetail = GetDynamicDetailUseCase(repository);
final setPubSetting = SetPubSettingUseCase(repository);

// Get dynamic details
final result = await getDynamicDetail(id: '123456');

result.when(
  success: (data) {
    print('Dynamic: ${data['content']}');
    print('Author: ${data['author']}');
  },
  error: (error) {
    print('Error: $error');
  },
);

// Set visibility (private/public)
final setResult = await setPubSetting(
  dynId: 123456,
  action: 'private',  // or 'public'
);
```

## Data Flow

1. User clicks on a dynamic in feed
2. Presentation layer calls `GetDynamicDetailUseCase`
3. Repository fetches full details from API
4. Complete dynamic displayed with comments
5. User can change visibility via `SetPubSettingUseCase`

## Visibility Settings

Users can control who sees their posts:
- `public` - Visible to everyone
- `private` - Only visible to self
- May have additional options

## Reply Permissions

`SetReplySubjectUseCase` controls who can reply:
- `oid` - Object ID (dynamic ID)
- `type` - Content type
- `action` - Permission action (enable/disable)

## Dynamic Types

Supports various dynamic content:
- Text posts
- Image posts
- Video posts
- Article shares
- Reposts

## Use Cases

Detail page allows users to:
- View full post content
- Read all comments
- Change visibility
- Control reply permissions
- Share post
- Delete post
