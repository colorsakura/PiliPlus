# Home Zone Feature

Displays rank video lists for different content categories (anime, movie, TV shows, etc.).

## Architecture

### Domain Layer
- **Entities**: `FetchRankParams`, `RankType`
- **Repository**: `RankRepository`
- **Use Cases**: `FetchRank`

### Data Layer
- **Remote DataSource**: `RankRemoteDataSource` / `RankRemoteDataSourceImpl`
- **Repository Implementation**: `RankRepositoryImpl`
- **HTTP Client**: Uses `VideoHttp` for API calls

### Presentation Layer
- **Views**: `RankView` / `RankViewV2`
- **Controllers**: `RankController` (tab navigation), `ZoneController` (data fetching)

## Key Features

- **Multiple Rank Types**: Partition-based ranks, PGC ranks, PGC season ranks
- **Tab Navigation**: Switch between different rank categories
- **Pagination**: Infinite scroll for rank lists

## Usage

```dart
// Fetch partition-based rank
final fetchRank = FetchRank(repository);
final result = await fetchRank(FetchRankParams.byPartition(rid: 33));

// Fetch PGC rank
final result = await fetchRank(FetchRankParams.pgc(seasonType: 1));

// Fetch PGC season rank
final result = await fetchRank(FetchRankParams.pgcSeason(seasonType: 2));
```

## API Notes

Three different APIs are used based on rank type:

1. **Partition Rank** (`VideoHttp.getRankVideoList`):
   - Requires `rid`: Partition ID
   - Returns videos for a specific category

2. **PGC Rank** (`VideoHttp.pgcRankList`):
   - Requires `seasonType`: Type of PGC content
   - Returns PGC (anime, movie, TV) rankings

3. **PGC Season Rank** (`VideoHttp.pgcSeasonRankList`):
   - Optional `seasonType`: Season type filter
   - Returns season-specific rankings
