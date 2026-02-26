# Match Feature

Clean Architecture implementation for match (esports/contest) functionality.

## Overview

This feature handles fetching information about esports matches and contests, particularly for gaming content on the platform.

## Architecture

### Domain Layer

**Entities:**
- `MatchContestEntity` - Represents a match/contest with all relevant information

**Repository Interface:**
- `MatchRepository` - Abstract contract for match data operations

**Use Cases:**
- `GetMatchInfo` - Fetch match information by contest ID

### Data Layer

**Data Sources:**
- `MatchRemoteDataSource` - HTTP client for match API endpoints

**Repositories:**
- `MatchRepositoryImpl` - Concrete implementation with error handling

## Usage

```dart
import 'package:PiliPlus/features/match/match.dart';

// Initialize repository and use case
final repository = MatchRepositoryImpl(
  remoteDataSource: MatchRemoteDataSource(),
);

final getMatchInfo = GetMatchInfo(repository);

// Get match info by contest ID
final result = await getMatchInfo(
  cid: '123456',
  platform: 2, // 2 for Web platform
);

if (result case Success(:final match)) {
  print('Match: ${match.title}');
  print('Status: ${match.status}');
  print('Is Live: ${match.isLive}');
  print('Start Date: ${match.startDate}');
} else if (result case Error(:final errorMsg)) {
  print('Failed to get match info: $errorMsg');
}
```

## Match Status

The `MatchContestEntity` provides convenience methods to check match status:

- `isLive` - Check if the match is currently live (status == '1' or 'live')
- `isUpcoming` - Check if the match is upcoming (status == '0' or 'upcoming')
- `hasEnded` - Check if the match has ended (status == '2' or 'ended')

## API Operations

The `MatchRemoteDataSource` provides:

| Method | Description |
|--------|-------------|
| `matchInfo` | Get match contest information by ID |

## Error Handling

The repository catches `ServerException` and general `Exception`, converting them to `LoadingState` for consistent error handling in the presentation layer.

Common error messages:
- '获取赛事信息失败' - Failed to get match information
- '未找到赛事信息' - Match information not found
