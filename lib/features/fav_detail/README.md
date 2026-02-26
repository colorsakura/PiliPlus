# Favorite Folder Detail Feature

Displays and manages the contents of a favorite folder.

## Architecture

### Domain Layer
- **Entities**: `FetchFavDetailParams`, `CancelFavoriteParams`, `ToggleFavFolderParams`, `CleanFavoritesParams`
- **Repository**: `FavDetailRepository`
- **Use Cases**: `FetchFavDetail`, `CancelFavorites`, `ToggleFavFolder`, `CleanFavorites`

### Data Layer
- **Remote DataSource**: `FavDetailRemoteDataSource` / `FavDetailRemoteDataSourceImpl`
- **Repository Implementation**: `FavDetailRepositoryImpl`
- **HTTP Client**: Uses `FavHttp` for API calls

### Presentation Layer
- **Pages**: `FavDetailPage`
- **Controller**: `FavDetailController` with multi-select support

## Key Features

- **Pagination**: Fetch favorite folder contents with pagination
- **Sort Options**: Support for different sort orders (mtime, pubdate, click, etc.)
- **Multi-Select**: Select and remove multiple favorites at once
- **Folder Management**: Favorite/unfavorite folders, clean all items
- **Play All**: Option to play all videos in the folder sequentially

## Usage

```dart
// Fetch favorite folder detail
final fetchFavDetail = FetchFavDetail(repository);
final result = await fetchFavDetail(FetchFavDetailParams(
  mediaId: 123456,
  page: 1,
  order: FavOrderType.mtime,
));

// Cancel favorites
final cancelFavorites = CancelFavorites(repository);
await cancelFavorites(CancelFavoriteParams(
  resources: CancelFavoriteParams.fromList([(id: 789, type: 2)]),
  mediaId: 123456,
));

// Toggle folder favorite state
final toggleFavFolder = ToggleFavFolder(repository);
await toggleFavFolder(ToggleFavFolderParams(
  mediaId: 123456,
  isFavorite: false,
));
```

## API Notes

- `FavHttp.userFavFolderDetail`: Fetch folder contents with pagination
- `FavHttp.favVideo`: Cancel favorites (uses `delIds` parameter)
- `FavHttp.favFavFolder`: Add folder to favorites
- `FavHttp.unfavFavFolder`: Remove folder from favorites
- `FavHttp.cleanFav`: Remove all items from folder
