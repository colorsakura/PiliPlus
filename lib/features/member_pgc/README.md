# Member PGC Feature

Clean Architecture implementation for member PGC (Professional Generated Content) functionality.

## Overview

This feature displays PGC content (bangumi/anime) associated with a member. Shows anime, dramas, or other professional content the member has contributed to or is associated with.

## Architecture

### Domain Layer

**Entities:**
- `SpaceArchiveData` - Contains PGC content list

**Repository Interface:**
- `MemberPgcRepository` - Abstract contract for PGC operations

**Use Cases:**
- `GetSpaceArchiveUseCase` - Retrieve member's PGC content

### Data Layer

**Data Sources:**
- `MemberPgcRemoteDataSource` - Remote API data source

**Models:**
- `SpaceArchiveData` - PGC archive data
- `ContributeType` - Contribution type enum

**Repositories:**
- `MemberPgcRepositoryImpl` - Concrete implementation

### Presentation Layer

**Pages:**
- Member PGC page

**Providers:**
- `MemberPgcController` - Controller
- `MemberPgcProvider` - Riverpod provider

## Usage

```dart
import 'package:PiliPlus/features/member_pgc/member_pgc.dart';

// Initialize repository and use case
final repository = MemberPgcRepositoryImpl(
  remoteDataSource: MemberPgcRemoteDataSourceImpl(),
);
final getSpaceArchive = GetSpaceArchiveUseCase(repository);

// Get PGC content for a member
final result = await getSpaceArchive(
  type: ContributeType.bangumi,
  mid: 123456,
  pn: 1,
);

result.when(
  success: (data) {
    print('PGC items: ${data.list?.length ?? 0}');
    for (var item in data.list ?? []) {
      print('${item.title}');
      print('Season ID: ${item.seasonId}');
      print('Type: ${item.type}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User visits member's profile
2. User selects "Bangumi" or "PGC" tab
3. Presentation layer calls use case
4. Repository fetches PGC content from API
5. Results displayed with covers and info

## Contribution Types

`ContributeType` enum includes:
- `bangumi` - Anime series
- `pgc` - Other professional content
- `cosplay` - Cosplay content
- `article` - Articles
- And more types

## Content Types

Member PGC includes:
- Anime appearances
- Drama participation
- Documentary features
- Voice acting roles
- Production credits

## Pagination

- `mid` - Member/user ID
- `type` - Content type to filter
- `pn` - Page number

## Use Cases

Users check member PGC to:
- See creator's professional work
- Find anime appearances
- Discover voice acting roles
- View production credits
