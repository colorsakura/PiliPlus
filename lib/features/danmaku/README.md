# Danmaku Feature - Clean Architecture

This feature has been refactored to follow **Clean Architecture** principles.

## Architecture Layers

### Domain Layer (Core Business Logic)
- **Entities**: Core business objects
  - `DanmakuEntity`: Danmaku (bullet comment) content with display options
  - `DanmakuSendResultEntity`: Result of sending a danmaku

- **Repositories**: Abstract interfaces for data access
  - `DanmakuRepository`: Defines danmaku operations contract

- **Use Cases**: Business logic operations
  - `SendDanmaku`: Send danmaku to a video

### Data Layer (Data Access)
- **Data Sources**: Raw data providers
  - `DanmakuRemoteDataSource` (interface): Abstract data source interface
  - `DanmakuRemoteDataSource` (impl): Existing implementation in `danmaku_remote_datasource.dart`

- **Repositories**: Data repository implementations
  - `DanmakuRepositoryImpl`: Implements `DanmakuRepository` using remote data source

### Presentation Layer (UI)
- **Pages**: Screen widgets
  - `DanmakuPage`: Danmaku input and display page

- **Controllers**: State management
  - `DanmakuController`: Manages danmaku state

- **Providers**: Dependency injection
  - `danmaku_providers.dart`: Riverpod providers for DI

## Dependency Flow

```
Presentation → Domain → Data
     ↓            ↓         ↓
   UI       Use Cases  Data Sources
            & Repos
```

## Key Features

1. **Send Danmaku**: Send bullet comments to videos
2. **Multiple Modes**: Support for scrolling, bottom, and top danmaku
3. **Customization**: Color, font size, and timing options
4. **Colorful Danmaku**: Support for colored/membership danmaku

## Danmaku Modes

- **Mode 1 (Scrolling)**: Default scrolling danmaku from right to left
- **Mode 4 (Bottom)**: Fixed at the bottom of the screen
- **Mode 5 (Top)**: Fixed at the top of the screen

## Usage Example

```dart
// Using providers in a widget
class DanmakuWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendDanmaku = ref.watch(sendDanmakuUseCaseProvider);

    Future<void> sendMessage() async {
      final danmaku = const DanmakuEntity.scrolling(
        content: 'Great video!',
        color: 0xFFFFFF,
        fontSize: 25,
        progress: 5000, // 5 seconds into video
      );

      final result = await sendDanmaku(
        oid: 12345, // Video CID
        danmaku: danmaku,
        bvid: 'BV1xx411c7mD',
      );

      result.when(
        success: (sendResult) {
          if (sendResult.success) {
            print('Danmaku sent successfully!');
          }
        },
        error: (error) => print('Error: $error'),
      );
    }

    return ElevatedButton(
      onPressed: sendMessage,
      child: Text('Send Danmaku'),
    );
  }
}
```

## Technical Details

- Uses Bilibili's danmaku API for sending comments
- Supports all danmaku display modes
- Handles CSRF token for authenticated requests
- Integrates with existing video playback infrastructure

## Migration Notes

- An adapter pattern is used to bridge the existing data source implementation
- The controller still uses direct API calls in some places for compatibility
- Full migration to use cases for all operations is planned for future updates
