# User Feature

Handles user-related operations including fetching user info, statistics, and watch later list.

## Architecture

### Domain Layer
- **Entities**: `FetchUserInfoParams`, `FetchUserStatParams`, `FetchSeeYouLaterParams`
- **Repository**: `UserRepository`
- **Use Cases**: `FetchUserInfo`, `FetchUserStat`, `FetchSeeYouLater`

### Data Layer
- **Remote DataSource**: `UserRemoteDataSource` (base class with HTTP implementation)
- **Repository Implementation**: `UserRepositoryImpl`

### Key Features

- **User Info**: Fetch navigation information (coins, level, VIP status)
- **User Statistics**: View count, follower count, like count
- **Watch Later**: "See You Later" list management with pagination

## Usage

```dart
// Fetch user info
final fetchUserInfo = FetchUserInfo(repository);
final userInfo = await fetchUserInfo();

// Fetch user stats
final fetchUserStat = FetchUserStat(repository);
final stats = await fetchUserStat(FetchUserStatParams(isOwner: true));

// Fetch watch later list
final fetchSeeYouLater = FetchSeeYouLater(repository);
final laterList = await fetchSeeYouLater(FetchSeeYouLaterParams(page: 1));
```

## API Notes

- `userInfo()`: Returns comprehensive user information including wallet balance
- `userStatOwner()`: Returns statistics for the current user
- `seeYouLater()`: Supports filtering by viewed status, keyword search, and sorting

The data source is implemented as a base class with all HTTP logic, and the implementation class extends it to satisfy the interface.
