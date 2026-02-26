# SponsorBlock Feature

Clean Architecture implementation for SponsorBlock functionality.

## Overview

SponsorBlock is a crowdsourced system for skipping annoying parts of videos. This feature integrates with the SponsorBlock API to:

- Fetch skip segments for videos
- Submit new skip segments
- Vote on segment accuracy
- Track user statistics
- Manage port video bindings (Bilibili <-> YouTube)

## Architecture

### Domain Layer

**Entities:**
- `SponsorSegmentEntity` - Represents a skip segment with timing and category
- `SponsorUserInfoEntity` - Represents user statistics and reputation

**Repository Interface:**
- `SponsorBlockRepository` - Abstract contract for SponsorBlock operations

**Use Cases:**
- `GetSkipSegments` - Fetch skip segments for a video
- `VoteOnSegment` - Vote on segment accuracy
- `PostSkipSegments` - Submit new skip segments
- `GetSponsorUserInfo` - Fetch user statistics

### Data Layer

**Data Sources:**
- `SponsorBlockRemoteDataSource` - HTTP client for SponsorBlock API

**Repositories:**
- `SponsorBlockRepositoryImpl` - Implementation converting models to entities

## Usage

```dart
import 'package:PiliPlus/features/sponsor_block/sponsor_block.dart';

// Initialize repository and use cases
final repository = SponsorBlockRepositoryImpl(
  remoteDataSource: SponsorBlockRemoteDataSource(),
);

final getSkipSegments = GetSkipSegments(repository);

// Get skip segments for a video
final segments = await getSkipSegments(
  bvid: 'BV1xx411c7mD',
  cid: 123456789,
);

for (final segment in segments) {
  print('Skip ${segment.category} from ${segment.startTime}s to ${segment.endTime}s');
}
```

## API Operations

The `SponsorBlockRemoteDataSource` provides:

| Method | Description |
|--------|-------------|
| `getSkipSegments` | Get skip segments for a video |
| `voteOnSponsorTime` | Vote on segment accuracy |
| `viewedVideoSponsorTime` | Mark segment as viewed |
| `uptimeStatus` | Check service status |
| `userInfo` | Get user statistics |
| `postSkipSegments` | Submit new segments |
| `getPortVideo` | Get YouTube port binding |
| `postPortVideo` | Create YouTube port binding |

## Segment Categories

Common segment categories include:
- `sponsor` - Sponsorships
- `intro` - Intros
- `outro` - Outros
- `interaction` - Interaction reminders
- `selfpromo` - Self-promotion
- `music_offtopic` - Non-music sections

## Error Handling

The repository throws `ServerException` for API errors with appropriate status codes:
- `200` with error body - Unexpected response
- `400` - Parameter error
- `403` - Auto-moderation rejection
- `404` - Data not found
- `409` - Duplicate submission
- `429` - Rate limiting
- `500` - Server error
