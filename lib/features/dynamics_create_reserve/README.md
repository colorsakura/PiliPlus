# Dynamics Create Reserve Feature

Manages live stream reservations for dynamic posts.

## Architecture

### Domain Layer
- **Repository**: `DynReserveRepository` (interface with getReserveInfo, createReserve, updateReserve)
- **Use Cases**: `GetDynReserveData`

### Data Layer
- **Remote DataSource**: `DynReserveRemoteDataSource`
- **Repository Implementation**: `DynReserveRepositoryImpl`
- **HTTP Client**: Uses Dynamics HTTP API

### Presentation Layer
- **Pages**: `DynCreateReservePage`
- **Providers**: `DynCreateReserveController`, `dynCreateReserveProvider`

## Key Features

- **Fetch Reserve Info**: Get existing live stream reservation details
- **Create Reserve**: Create new live stream reservation for a dynamic
- **Update Reserve**: Modify existing reservation (title, time)

## Usage

```dart
// Get reserve info
final getReserveInfo = GetDynReserveData(repository);
final result = await getReserveInfo(sid: 123);

// Create new reserve
await repository.createReserve(
  title: 'Live Stream Title',
  subType: 1,
  livePlanStartTime: timestamp,
);

// Update reserve
await repository.updateReserve(
  sid: 123,
  subType: 1,
  title: 'Updated Title',
  livePlanStartTime: newTimestamp,
);
```

## Integration

This feature is used when creating or editing dynamics with attached live stream reservation cards. The user can select a live stream to attach to their dynamic post.
