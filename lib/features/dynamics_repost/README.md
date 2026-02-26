# Dynamics Repost Feature

Clean Architecture implementation for dynamic repost (forwarding) functionality.

## Overview

This feature handles reposting/forwarding dynamics and sharing videos to dynamics. It supports both forwarding existing dynamics and sharing videos with optional text content, rich text editing, emojis, and mentions.

## Architecture

### Domain Layer

**Entities:**
- `DynamicsRepostParams` - Encapsulates all parameters for creating/reposting a dynamic
- `DynamicsRepostResult` - Represents the result of a repost operation

**Repository Interface:**
- `DynamicsRepostRepository` - Abstract contract for dynamic repost operations

**Use Cases:**
- `RepostDynamic` - Create or repost a dynamic

### Data Layer

**Data Sources:**
- `DynamicsRepostRemoteDataSource` - Interface for repost data source
- `DynamicsRepostRemoteDataSourceImpl` - Implementation using DynamicsHttp.createDynamic

**Repositories:**
- `DynamicsRepostRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Basic Repost

```dart
import 'package:PiliPlus/features/dynamics_repost/dynamics_repost.dart';

// Initialize repository and use case
final remoteDataSource = DynamicsRepostRemoteDataSourceImpl();
final repository = DynamicsRepostRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final repostDynamic = RepostDynamic(repository);

// Prepare repost parameters
final params = DynamicsRepostParams(
  mid: Accounts.main.mid,
  dynIdStr: '123456789', // Dynamic ID to repost
  rawText: 'Check this out!',
);

// Repost dynamic
final result = await repostDynamic(params);

if (result case Success(:final response)) {
  final dynId = response?['dyn_id'];
  print('Repost successful: $dynId');
} else if (result case Error(:final errorMsg)) {
  print('Repost failed: $errorMsg');
}
```

### Share Video to Dynamic

```dart
// Share a video to your dynamics
final params = DynamicsRepostParams(
  mid: Accounts.main.mid,
  rid: 12345, // Video ID
  dynType: 8, // Dynamic type for video
  rawText: 'Amazing video!',
);

final result = await repostDynamic(params);
```

### With Rich Text Content

```dart
// Create rich text content with mentions and emojis
final richTextContent = [
  {"raw_text": "Check out this video by ", "type": 1, "biz_id": ""},
  {"raw_text": "@username", "type": 2, "biz_id": "123456"},
  {"raw_text": "! 😮", "type": 9, "biz_id": "123"},
];

final params = DynamicsRepostParams(
  mid: Accounts.main.mid,
  dynIdStr: '123456789',
  extraContent: richTextContent,
);

final result = await repostDynamic(params);
```

## Repost Types

The feature supports two main operations:

1. **Repost Dynamic** (`isRepost == true`) - Forward an existing dynamic
   - Requires: `dynIdStr` or `item` (original dynamic)

2. **Share Video** (`isVideoShare == true`) - Share a video to your dynamics
   - Requires: `rid` and `dynType`

## Architecture Note

This feature uses `DynamicsHttp.createDynamic` API endpoint for data persistence. The repository implementation wraps this HTTP call, providing a clean abstraction layer for the application logic.

The presentation layer uses `CommonRichTextPubPage` as a base class, providing rich text editing capabilities including emoji selection and @mentions.
