# Live Emote Feature

Clean Architecture implementation for live room emotes functionality.

## Overview

This feature manages custom emotes available in live streaming rooms. Users can view and use room-specific emotes during live chat.

## Architecture

### Domain Layer

**Entities:**
- `LiveEmoteDatum` - Represents a live room emote

**Repository Interface:**
- `LiveEmoteRepository` - Abstract contract for live emote operations

**Use Cases:**
- `GetLiveEmoticonsUseCase` - Retrieve emotes for a live room

### Data Layer

**Data Sources:**
- `LiveEmoteRemoteDataSource` - Remote API data source

**Models:**
- `LiveEmoteDatum` - Emote data model

**Repositories:**
- `LiveEmoteRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Live emote panel/keyboard

**Providers:**
- `LiveEmoteController` - Controller for managing state
- `LiveEmoteProvider` - Riverpod provider for emote data

## Usage

```dart
import 'package:PiliPlus/features/live_emote/live_emote.dart';

// Initialize repository and use case
final repository = LiveEmoteRepositoryImpl(
  remoteDataSource: LiveEmoteRemoteDataSourceImpl(),
);
final getLiveEmoticons = GetLiveEmoticonsUseCase(repository);

// Get emotes for a live room
final result = await getLiveEmoticons(roomId: 123456);

result.when(
  success: (emotes) {
    if (emotes != null) {
      print('Room emotes: ${emotes.length}');
      for (var emote in emotes) {
        print('${emote.name}: ${emote.url}');
        print('Size: ${emote.width}x${emote.height}');
        print('Level: ${emote.level}'); // VIP requirement
      }
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User enters a live room
2. Room emotes load automatically
3. Presentation layer calls `GetLiveEmoticonsUseCase`
4. Use case invokes repository with room ID
5. Repository fetches emotes from API
6. Emotes displayed in chat/emote panel
7. Users can tap emotes to send in chat

## Entity Structure

**LiveEmoteDatum** contains:
- `id` - Emote identifier
- `name` - Emote name/keyword
- `url` - Image URL
- `width` - Image width
- `height` - Image height
- `level` - Required user level (0 = all users)

## Emote Tiers

Emotes may have usage restrictions:
- `level: 0` - Available to all users
- `level: 1` - Requires VIP/level 1
- `level: 2+` - Higher tier VIP
- Platform-specific tier system

## Room-Specific Emotes

Live room emotes are:
- Unique to each room/Streamer
- Created by streamers
- Reflect channel culture
- May include memes and in-jokes

## Emote Usage

Users can:
- View all available room emotes
- Click emote to send in chat
- Emotes appear as images in chat
- Support for animated emotes

## Display

Emotes are typically shown in:
- Emote keyboard/panel
- Auto-complete suggestions
- Chat history with images rendered
- Grid layout for easy selection

## Use Cases

Live emotes enhance:
- Chat engagement
- Community building
- Streamer identity
- User expression
- Channel culture
