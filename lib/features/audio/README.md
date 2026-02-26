# Audio Feature

Audio player with playlist management and social interactions.

## Architecture

### Domain Layer
- **Entities**: `FetchAudioPlayUrlParams`, `FetchAudioPlaylistParams`, `ThumbUpAudioParams`, `TripleLikeAudioParams`, `CoinAudioParams`
- **Repository**: `AudioRepository`
- **Use Cases**: `FetchAudioPlayUrl`, `FetchAudioPlaylist`, `ThumbUpAudio`, `TripleLikeAudio`, `AddAudioCoin`

### Data Layer
- **Remote DataSource**: `AudioRemoteDataSource` / `AudioRemoteDataSourceImpl`
- **Repository Implementation**: `AudioRepositoryImpl`
- **gRPC Client**: Uses `AudioGrpc` for API calls

### Presentation Layer
- **Pages**: `AudioPage`
- **Controllers**: `AudioController` with playlist and player management

## Key Features

- **Audio Playback**: Play audio with speed control and seeking
- **Playlist Management**: Navigate through audio playlists
- **Social Interactions**:
  - Thumb up (like) audio
  - Triple like (like + fav + coin)
  - Add coins to support creators
- **Continuous Play**: Auto-play next in playlist
- **Background Play**: Support for background playback

## Usage

```dart
// Fetch audio play URL
final fetchAudioPlayUrl = FetchAudioPlayUrl(repository);
final result = await fetchAudioPlayUrl(FetchAudioPlayUrlParams(
  itemType: 1,
  oid: 123456,
  subId: [789],
));

// Fetch playlist
final fetchAudioPlaylist = FetchAudioPlaylist(repository);
final playlist = await fetchAudioPlaylist(FetchAudioPlaylistParams(
  id: 123456,
  oid: 123456,
  subId: [789],
  itemType: 1,
  from: PlaylistSource.listSourceAlbum,
));

// Thumb up
await thumbUpAudio.call(ThumbUpAudioParams(
  oid: 123456,
  subId: [789],
  itemType: 1,
  isThumbUp: true,
));

// Triple like
final result = await tripleLikeAudio.call(TripleLikeAudioParams(
  oid: 123456,
  subId: [789],
  itemType: 1,
));

// Add coin
await addAudioCoin.call(CoinAudioParams(
  oid: 123456,
  subId: [789],
  itemType: 1,
  num: 2,
  thumbUp: true,
));
```

## Architecture Notes

This feature manages audio playback with gRPC-based API calls for:
- Fetching play URLs and playlists
- User interactions (like, coin, triple like)
- Player state management (speed, position, duration)

The Clean Architecture separation allows the business logic to be tested independently while the presentation layer handles UI-specific concerns like player controls and playlist navigation.
