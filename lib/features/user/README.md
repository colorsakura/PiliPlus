# User Feature

Handles user-related operations including fetching user info, statistics, and watch later list.

## Architecture

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### Domain Layer
- **Entities**: `FetchUserInfoParams`, `FetchUserStatParams`, `FetchSeeYouLaterParams`
- **Repository**: `UserRepository`
- **Use Cases**: `FetchUserInfo`, `FetchUserStat`, `FetchSeeYouLater`

### Data Layer
- **Remote DataSource**: `UserRemoteDataSource` (base class with HTTP implementation)
- **Repository Implementation**: `UserRepositoryImpl`

### Presentation Layer
- **Controllers**:
  - `UserInfoController`: Manages user navigation information state
  - `UserStatController`: Manages user statistics state
  - `SeeYouLaterController`: Manages watch later list state
- **Pages**:
  - `UserInfoPage`: Displays user profile information
  - `UserStatPage`: Displays user statistics (following, follower, etc.)
  - `SeeYouLaterPage`: Displays watch later video list

### Key Features

- **User Info**: Fetch navigation information (coins, level, VIP status)
- **User Statistics**: View count, follower count, like count
- **Watch Later**: "See You Later" list management with pagination

## Usage

```dart
// Using controllers with Riverpod
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoState = ref.watch(userInfoControllerProvider);

    // Fetch user info
    ref.read(userInfoControllerProvider.notifier).fetchUserInfo();

    return UserInfoPage();
  }
}
```

## API Notes

- `userInfo()`: Returns comprehensive user information including wallet balance
- `userStatOwner()`: Returns statistics for the current user
- `seeYouLater()`: Supports filtering by viewed status, keyword search, and sorting

The data source is implemented as a base class with all HTTP logic, and the implementation class extends it to satisfy the interface.

## Migration Status

- ✅ Domain Layer Complete
- ✅ Data Layer Complete
- ✅ Presentation Layer Complete (New)
- ⏳ Tests (Pending)
- ✅ Documentation Complete

## Code Quality

- ✅ `flutter analyze` No issues found
- ✅ `dart format` Formatted
- ✅ Riverpod code generation verified
- ✅ Clean architecture compliance verified
