# Whisper Link Setting Feature

Clean Architecture implementation for whisper (private message) session settings functionality.

## Overview

This feature manages settings for individual whisper conversations including push notifications, do-not-disturb, pinning, and blocking. Users can customize how they receive notifications from specific users.

## Architecture

### Domain Layer

**Entities:**
- Various settings-related entities
- `SessionId` - gRPC session identifier

**Repository Interface:**
- `WhisperLinkSettingRepository` - Abstract contract for whisper settings operations

**Use Cases:**
- `GetUserInfoUseCase` - Retrieve user information
- `GetSessionSsUseCase` - Get session notification settings
- `SetPushSsUseCase` - Update push notification settings
- `PinSessionUseCase` - Pin a conversation
- `UnpinSessionUseCase` - Unpin a conversation
- `SetMsgDndUseCase` - Set do-not-disturb for messages
- `RelationModUseCase` - Block/unblock a user

### Data Layer

**Data Sources:**
- `WhisperLinkSettingRemoteDataSource` - gRPC API data source

**Models:**
- `ImUserInfosData` - User info data
- `SessionSsData` - Session settings data
- `UidSetting` - DND settings data
- `SessionUpdateReply` - Session update response

**Repositories:**
- `WhisperLinkSettingRepositoryImpl` - Concrete implementation using gRPC source

### Presentation Layer

**Pages:**
- Whisper link settings page

**Providers:**
- `WhisperLinkSettingController` - Controller for managing settings state
- `WhisperLinkSettingProvider` - Riverpod provider for settings data

## Usage

```dart
import 'package:PiliPlus/features/whisper_link_setting/whisper_link_setting.dart';

// Initialize repository
final repository = WhisperLinkSettingRepositoryImpl(
  remoteDataSource: WhisperLinkSettingRemoteDataSourceImpl(),
);

// Get user info
final userInfoResult = await repository.getUserInfo('123456');

// Get session settings
final sessionResult = await repository.getSessionSs(123456);

// Set push notification (0=off, 1=on)
final pushResult = await repository.setPushSs(
  setting: 1,
  talkerUid: 123456,
);

// Pin session
final sessionId = SessionId()..talkerId = 123456;
final pinResult = await repository.pinSession(sessionId);

// Set do-not-disturb
final dndResult = await repository.setMsgDnd(
  uid: 123456,
  setting: 1,  // 0=off, 1=on
  dndUid: 123456,
);
```

## Data Flow

1. User opens settings for a specific conversation
2. Presentation layer loads current settings via use cases
3. User modifies settings
4. Changes are saved via repository methods
5. Settings sync with server via gRPC
6. UI updates to reflect changes

## Settings Available

### Push Notifications
Control push notifications for specific conversations:
- Enable/disable push for individual chats
- Different from system-level notification settings

### Session Pinning
Pin important conversations to top:
- Pinned chats stay at top of list
- Unpin to restore normal order

### Do Not Disturb
Silence notifications from specific users:
- Messages arrive silently
- No push notifications
- Messages still visible in chat list

### Blocking
Block users from sending messages:
- `act: 2` - Block user
- `act: 3` - Unblock user
- `reSrc: 1` - Source of action

## Session Management

Each conversation has a `SessionId`:
- Identifies unique conversation
- Used for pin/unpin operations
- Contains `talkerId` field

## Use Cases

Users customize settings to:
- Prioritize important conversations (pin)
- Reduce notifications from chatty users (DND)
- Block harassment or spam
- Control notification granularity
- Manage message overload
