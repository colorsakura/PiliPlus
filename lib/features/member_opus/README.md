# Member Opus Feature

Displays a member's opus (图文 content - articles/posts with images and text).

## Architecture

### Domain Layer
- **Entities**: `FetchMemberOpusParams`
- **Repository**: `MemberOpusRepository`
- **Use Cases**: `FetchMemberOpus`

### Data Layer
- **Remote DataSource**: `MemberOpusRemoteDataSource` / `MemberOpusRemoteDataSourceImpl`
- **Repository Implementation**: `MemberOpusRepositoryImpl`
- **HTTP Client**: Uses `MemberHttp.spaceOpus` for API calls

### Presentation Layer
- **Pages**: `MemberOpusPage`
- **Controller**: `MemberOpusController` (extends CommonListController)

## Key Features

- **Pagination**: Offset-based pagination for efficient loading
- **Type Filtering**: Filter by content type (all, video, article, etc.)
- **Integration**: Part of member profile's contribute section

## Usage

```dart
// Fetch member opus list
final fetchMemberOpus = FetchMemberOpus(repository);
final result = await fetchMemberOpus(FetchMemberOpusParams(
  hostMid: 123456,
  page: 1,
  type: 'all',
));
```

## API Notes

- `MemberHttp.spaceOpus`: Fetches opus content with:
  - `hostMid`: Member ID
  - `page`: Page number
  - `offset`: Pagination offset from previous response
  - `type`: Content filter type

- The response includes:
  - `items`: List of opus items
  - `offset`: Next offset for pagination
  - `hasMore`: Whether more content exists
