# Share Feature

Clean Architecture implementation for the share functionality.

## Overview

This feature handles sharing content to other users via private messages.

## Architecture

### Domain Layer

**Entities:**
- `ShareUserEntity` - Represents a user that can receive shared content
  - Backward compatibility: `UserModel` type alias is provided

**Repository Interface:**
- `ShareRepository` - Abstract contract for share data operations

**Use Cases:**
- `SendShare` - Handles sending share content to selected users

### Data Layer

**Data Sources:**
- `ShareRemoteDataSource` - Interface for remote data operations
- `ShareRemoteDataSourceImpl` - Implementation using `RequestUtils.pmShare`

**Repositories:**
- `ShareRepositoryImpl` - Concrete implementation of `ShareRepository`

### Presentation Layer

**Pages:**
- `SharePanel` - UI panel for selecting users and sending shares

## Usage

```dart
import 'package:PiliPlus/features/share/share.dart';

// Use the SendShare use case
final sendShare = SendShare(
  ShareRepositoryImpl(
    remoteDataSource: ShareRemoteDataSourceImpl(),
  ),
);

await sendShare(
  users: selectedUsers,
  content: shareContent,
  message: optionalMessage,
);
```

## Backward Compatibility

For backward compatibility, the `UserModel` type alias is provided:
```dart
import 'package:PiliPlus/features/share/share.dart' show UserModel;
```

This allows existing code to continue using the `UserModel` name without changes.
