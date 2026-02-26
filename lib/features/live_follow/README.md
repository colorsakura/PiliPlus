# Live Follow Feature

Manages live streamer following functionality.

## Architecture

### Domain Layer
- **Repository**: Live follow repository
- **Use Cases**: `FollowStreamer`, `UnfollowStreamer`, `GetFollowList`

### Data Layer
- **Remote DataSource**: Live follow remote data source
- **Repository Implementation**: Live follow repository implementation

### Presentation Layer
- **Pages**: Follow management interface
- **Controllers**: Follow state controller

## Key Features

- **Follow/Unfollow**: Manage streamer subscriptions
- **Follow List**: View all followed streamers
- **Live Status**: Check if followed streamers are live
- **Notifications**: Get notified when followed streamers go live

## Usage

```dart
// Follow a streamer
await followStreamer.call(uid: 123456);

// Unfollow a streamer
await unfollowStreamer.call(uid: 123456);

// Get follow list
final result = await getFollowList();
```
