# DLNA Feature - Clean Architecture

This feature has been refactored to follow **Clean Architecture** principles.

## Architecture Layers

### Domain Layer (Core Business Logic)
- **Entities**: Core business objects
  - `DlnaDeviceEntity`: DLNA device information
  - `DlnaSearchResultEntity`: Search result state

- **Repositories**: Abstract interfaces for data access
  - `DlnaRepository`: Defines DLNA operations contract

- **Use Cases**: Business logic operations
  - `SearchDlnaDevices`: Search for available DLNA devices
  - `StopDlnaSearch`: Stop device searching
  - `CastToDevice`: Connect and cast content to device

### Data Layer (Data Access)
- **Data Sources**: Raw data providers
  - `DlnaRemoteDataSource` (interface): Abstract data source interface
  - `DlnaRemoteDataSourceImpl`: Implementation using `dlna_dart` package

- **Repositories**: Data repository implementations
  - `DlnaRepositoryImpl`: Implements `DlnaRepository` using remote data source

### Presentation Layer (UI)
- **Pages**: Screen widgets
  - `DlnaPage`: DLNA device search and connection page

- **Providers**: Dependency injection
  - `dlna_providers.dart`: Riverpod providers for DI

## Dependency Flow

```
Presentation → Domain → Data
     ↓            ↓         ↓
   UI       Use Cases  Data Sources
            & Repos
```

## Key Features

1. **Device Discovery**: Search for DLNA devices on the local network
2. **Device Connection**: Connect to and control DLNA devices
3. **Content Casting**: Cast video content to DLNA devices
4. **Playback Control**: Play/pause content on connected devices

## Usage Example

```dart
// Using providers in a widget
class DlnaWidget extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchDevices = ref.watch(searchDlnaDevicesUseCaseProvider);

    return StreamBuilder(
      stream: searchDevices(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final devices = snapshot.data!;
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                title: Text(device.name),
                onTap: () {
                  ref.read(castToDeviceUseCaseProvider)(
                    deviceId: device.id,
                    url: 'https://example.com/video.mp4',
                    title: 'My Video',
                  );
                },
              );
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## Technical Details

- Uses `dlna_dart` package for DLNA protocol implementation
- Implements streaming search results using Dart Streams
- Manages device connection state internally
- Handles device switching and disconnection

## Migration Notes

- The implementation wraps the existing `dlna_dart` package functionality
- The page still uses GetX for navigation parameters (to be migrated to Riverpod)
- Device state management is handled at the repository level
