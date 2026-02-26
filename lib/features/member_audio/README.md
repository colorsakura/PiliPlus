# Member Audio Feature

Clean Architecture implementation for member audio (audio content created by a user) functionality.

## Overview

This feature handles fetching and displaying audio content uploaded by a specific member (user). It provides paginated access to a member's audio catalog.

## Architecture

### Domain Layer

**Entities:**
- `MemberAudioItemEntity` - Represents a single audio item (currently typealias to `SpaceAudioItem`)

**Repository Interface:**
- `MemberAudioRepository` - Abstract contract for member audio operations

**Use Cases:**
- `FetchMemberAudiosUseCase` - Retrieve member's audio list with pagination

### Data Layer

**Data Sources:**
- Remote API data source for member audio

**Repositories:**
- `MemberAudioRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `MemberAudioPageV2` - Main page for displaying member's audio content

**Providers:**
- `MemberAudioListController` - Controller for managing audio list state
- `MemberAudioListProvider` - Riverpod provider for audio list
- Various providers for dependency injection

## Usage

```dart
import 'package:PiliPlus/features/member_audio/member_audio.dart';

// Initialize repository and use case
final repository = MemberAudioRepositoryImpl(
  remoteDataSource: MemberAudioRemoteDataSourceImpl(),
);
final fetchAudios = FetchMemberAudiosUseCase(repository);

// Fetch member's audio list
final result = await fetchAudios(
  mid: 123456,
  page: 1,
);

result.when(
  success: (audios) {
    for (var audio in audios) {
      print('Title: ${audio.title}');
      print('Duration: ${audio.duration}');
      print('Plays: ${audio.play}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to member's audio page
2. Presentation layer calls `FetchMemberAudiosUseCase` with member ID and page number
3. Use case invokes repository method
4. Repository fetches data from remote data source
5. Data is returned as domain entities
6. Result is returned to presentation layer for UI rendering
7. User can load more pages by incrementing page number

## Entity Structure

**MemberAudioItemEntity** (aliased to `SpaceAudioItem`) contains:
- `id` - Audio identifier
- `title` - Audio title
- `cover` - Cover image URL
- `duration` - Audio duration in seconds
- `play` - Play count
- `ctime` - Creation timestamp
- And other metadata from the space audio API

## Pagination

The feature supports paginated loading:
- `page` parameter is 1-indexed (page 1 is the first page)
- Each page contains a fixed number of audio items
- Presentation layer should handle "load more" functionality

## Migration Notes

This feature uses `typedef` to alias the existing `SpaceAudioItem` model as `MemberAudioItemEntity`. This is a transitional approach during Clean Architecture migration. In a complete implementation:

1. Create pure domain entity `MemberAudioItemEntity` in domain layer
2. Map data layer models to domain entities in repository
3. Remove dependency on data layer models from domain layer
