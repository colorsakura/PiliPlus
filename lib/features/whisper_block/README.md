# Whisper Block Feature

Clean Architecture implementation for whisper (private message) keyword blocking functionality.

## Overview

This feature manages keyword-based filtering for private messages (whispers). Users can block messages containing specific keywords to avoid unwanted content.

## Architecture

### Domain Layer

**Entities:**
- `KeywordBlockingListReply` - Contains blocked keywords list

**Repository Interface:**
- `WhisperBlockRepository` - Abstract contract for whisper block operations

**Use Cases:**
- `GetKeywordBlockingListUseCase` - Retrieve blocked keywords
- `AddKeywordUseCase` - Add keyword to block list
- `DeleteKeywordUseCase` - Remove keyword from block list

### Data Layer

**Data Sources:**
- `WhisperBlockRemoteDataSource` - gRPC API data source

**Models:**
- `KeywordBlockingListReply` - gRPC response model

**Repositories:**
- `WhisperBlockRepositoryImpl` - Concrete implementation using gRPC source

### Presentation Layer

**Pages:**
- Whisper block settings page

**Providers:**
- `WhisperBlockController` - Controller for managing block state
- `WhisperBlockProvider` - Riverpod provider for block data

## Usage

```dart
import 'package:PiliPlus/features/whisper_block/whisper_block.dart';

// Initialize repository and use cases
final repository = WhisperBlockRepositoryImpl(
  remoteDataSource: WhisperBlockRemoteDataSourceImpl(),
);
final getKeywordList = GetKeywordBlockingListUseCase(repository);
final addKeyword = AddKeywordUseCase(repository);
final deleteKeyword = DeleteKeywordUseCase(repository);

// Get blocked keywords
final result = await getKeywordList();

result.when(
  success: (reply) {
    print('Blocked keywords: ${reply.keywords.length}');
    for (var keyword in reply.keywords) {
      print(keyword);
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Add keyword to block list
final addResult = await addKeyword('spam');

// Remove keyword from block list
final deleteResult = await deleteKeyword('spam');
```

## Data Flow

1. User opens whisper block settings
2. Presentation layer calls `GetKeywordBlockingListUseCase`
3. Use case invokes repository method
4. Repository fetches via gRPC API
5. Blocked keywords are displayed
6. User can add keywords via `AddKeywordUseCase`
7. User can remove keywords via `DeleteKeywordUseCase`

## Blocking Behavior

When a whisper contains a blocked keyword:
- Message is hidden or marked
- User is not notified
- Sender is not notified of blocking
- Multiple keywords can be blocked

## Keyword Management

- Add keywords to block list
- Remove keywords from block list
- View all blocked keywords
- Keywords are case-sensitive
- Exact matching or partial matching (depending on implementation)

## Use Cases

Users block keywords to:
- Filter spam messages
- Block inappropriate content
- Avoid specific topics
- Reduce harassment
- Maintain privacy

## gRPC Integration

This feature uses gRPC for communication:
- `KeywordBlockingListReply` - Response message type
- Real-time synchronization with server
- Efficient data transfer
