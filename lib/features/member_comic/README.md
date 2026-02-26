# Member Comic Feature

Clean Architecture implementation for member comics (漫画) functionality.

## Overview

This feature displays comic/manga content created by a member. Users can browse all comics published by the creator.

## Architecture

### Domain Layer

**Entities:**
- `MemberComicItemEntity` - Represents a comic item

**Repository Interface:**
- `MemberComicRepository` - Abstract contract for comic operations

**Use Cases:**
- `FetchMemberComicsUseCase` - Retrieve member's comics

### Data Layer

**Data Sources:**
- Remote API data source

**Models:**
- Comic data models

**Repositories:**
- `MemberComicRepositoryImpl` - Concrete implementation

### Presentation Layer

**Pages:**
- Member comics page

**Providers:**
- `MemberComicController` - Controller
- `MemberComicProvider` - Riverpod provider

## Usage

```dart
import 'package:PiliPlus/features/member_comic/member_comic.dart';

// Initialize repository and use case
final repository = MemberComicRepositoryImpl(
  remoteDataSource: MemberComicRemoteDataSourceImpl(),
);
final fetchMemberComics = FetchMemberComicsUseCase(repository);

// Get comics for a member
final result = await fetchMemberComics(
  mid: 123456,
  page: 1,
);

result.when(
  success: (comics) {
    print('Comics: ${comics.length}');
    for (var comic in comics) {
      print('${comic.title}');
      print('ID: ${comic.id}');
      print('Cover: ${comic.cover}');
      print('Description: ${comic.description}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User visits member's profile
2. User selects "Comics" tab
3. Presentation layer calls use case with member ID
4. Repository fetches comics from API
5. Comics displayed with covers

## Entity Structure

**MemberComicItemEntity** contains:
- `id` - Comic identifier
- `title` - Comic title
- `cover` - Cover image URL
- `description` - Summary
- `episodeCount` - Number of episodes
- `status` - Publication status
- And other metadata

## Comic Types

Comics can be:
- Original works
- Fan comics
- Collaborations
- Serialized works
- One-shots

## Pagination

- `mid` - Member/user ID
- `page` - Page number
- Each page shows fixed number of comics

## Comic Status

Comics may have status:
- Ongoing - Still publishing
- Completed - Finished
- Hiatus - On break

## Use Cases

Users browse comics to:
- Read creator's works
- Discover new comics
- Follow ongoing series
- Support comic creators
