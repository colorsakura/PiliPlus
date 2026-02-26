# Whisper Detail Feature

Clean Architecture implementation for whisper (private message) conversation detail.

## Overview

This feature handles viewing and managing a single whisper conversation. It supports fetching message history, sending new messages, and marking messages as read.

## Architecture

### Domain Layer

**Entities:**
- `FetchSessionMessagesParams` - Parameters for fetching conversation messages
- `SendMessageParams` - Parameters for sending a message
- `AckSessionMsgParams` - Parameters for acknowledging messages as read
- `SendMessageResult` - Result of a send operation

**Repository Interface:**
- `WhisperDetailRepository` - Abstract contract for whisper detail operations

**Use Cases:**
- `FetchSessionMessages` - Fetch conversation messages with pagination
- `SendMessage` - Send a text or picture message
- `AckSessionMessage` - Mark messages as read

### Data Layer

**Data Sources:**
- `WhisperDetailRemoteDataSource` - Interface for whisper detail data source
- `WhisperDetailRemoteDataSourceImpl` - Implementation using ImGrpc and MsgHttp

**Repositories:**
- `WhisperDetailRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Fetch Session Messages

```dart
import 'package:PiliPlus/features/whisper_detail/whisper_detail.dart';

// Initialize repository and use case
final remoteDataSource = WhisperDetailRemoteDataSourceImpl();
final repository = WhisperDetailRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final fetchSessionMessages = FetchSessionMessages(repository);

// Prepare parameters
final params = FetchSessionMessagesParams(
  talkerId: 12345,
  msgSeqno: null, // null for initial load
);

// Fetch messages
final result = await fetchSessionMessages(params);

if (result case Success(:final response)) {
  final messages = response.messages;
  print('Found ${messages.length} messages');
} else if (result case Error(:final errorMsg)) {
  print('Fetch failed: $errorMsg');
}
```

### Send Message

```dart
final sendMessage = SendMessage(repository);

// Send text message
final textParams = SendMessageParams(
  senderUid: myUserId,
  receiverId: 12345,
  content: 'Hello!',
  msgType: MsgType.MSG_TYPE_TEXT,
);

final result = await sendMessage(textParams);

if (result case Success(:final response)) {
  print('Message sent');
} else if (result case Error(:final errorMsg)) {
  print('Send failed: $errorMsg');
}
```

### Send Picture Message

```dart
// Send picture message
final picParams = SendMessageParams(
  senderUid: myUserId,
  receiverId: 12345,
  content: jsonEncode({'url': 'https://...', 'width': 800, 'height': 600}),
  msgType: MsgType.MSG_TYPE_PICTURE,
);

final result = await sendMessage(picParams);
```

### Acknowledge Messages as Read

```dart
final ackSessionMessage = AckSessionMessage(repository);

final ackParams = AckSessionMsgParams(
  talkerId: 12345,
  ackSeqno: 123, // Last message sequence number
);

final result = await ackSessionMessage(ackParams);
```

## Message Types

Messages are categorized by `MsgType`:
- **TEXT** (MSG_TYPE_TEXT) - Plain text message
- **PICTURE** (MSG_TYPE_PICTURE) - Image message
- **RECALL** (MSG_TYPE_RECALL) - Message recall operation
- And other types as defined in the gRPC schema

## Pagination

When fetching more messages:
```dart
// Use the last message's msgSeqno
final nextParams = FetchSessionMessagesParams(
  talkerId: 12345,
  msgSeqno: lastMsgSeqno, // From previous result
);

final nextResult = await fetchSessionMessages(nextParams);
```

## Architecture Note

This feature uses `ImGrpc.getSessionMsg` and `ImGrpc.sendMsg` gRPC endpoints for messaging, and `MsgHttp.ackSessionMsg` HTTP endpoint for read acknowledgments. The repository implementations wrap these API calls, providing clean abstraction layers for the application logic.

## State Management

The presentation layer uses GetX controller (`WhisperDetailController`) that extends `CommonListController`. The controller manages:
- Message list with pagination
- Message sending state
- Read acknowledgment
- Emotion info for message rendering
