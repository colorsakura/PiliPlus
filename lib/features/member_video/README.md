# Member Video Feature

Displays and manages a member's video content (videos, seasons, series).

## Architecture

### Domain Layer
- **Entities**: `FetchMemberArchiveParams`, `MemberArchiveResult`
- **Repository**: `MemberVideoRepository`
- **Use Cases**: `FetchMemberArchive`, `SearchVideoCid`

### Data Layer
- **Remote DataSource**: `MemberVideoRemoteDataSource` / `MemberVideoRemoteDataSourceImpl`
- **Repository Implementation**: `MemberVideoRepositoryImpl`
- **HTTP Clients**: Uses `MemberHttp` for archives, `SearchHttp` for cid lookup

### Presentation Layer
- **Pages**: `MemberVideoPage`
- **Controller**: `MemberVideoCtr` (extends CommonListController)

## Key Features

- **Multi-Type Support**: Videos, seasons, series, charging content
- **Advanced Pagination**: Bidirectional (previous/next) with cursor positioning
- **Sort Options**: By publish date or click count, ascending/descending
- **Continue Playing**: Episodic button for resuming playback
- **Play All**: Sequential playback of all videos

## Usage

```dart
// Fetch member videos
final fetchMemberArchive = FetchMemberArchive(repository);
final result = await fetchMemberArchive(FetchMemberArchiveParams(
  mid: 123456,
  type: ContributeType.video,
  order: 'pubdate',
));

// Search video cid
final searchVideoCid = SearchVideoCid(repository);
final cid = await searchVideoCid('123456', 'BV1xx411c7mD');
```

## API Notes

- `MemberHttp.spaceArchive`: Complex pagination support with:
  - `aid`: For video type pagination (previous/next)
  - `next`: For season/series cursor pagination
  - `includeCursor`: For cursor positioning when seeking specific video
  - `order`: `pubdate` or `click`
  - `sort`: `asc` or `desc`

- `SearchHttp.ab2c`: Convert aid/bvid to cid for video playback
