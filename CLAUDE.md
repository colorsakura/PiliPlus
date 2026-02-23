# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PiliPlus** is a Flutter-based third-party Bilibili client (unofficial) built with:
- **Dart SDK**: >=3.10.0
- **Flutter**: 3.41.2 (see `.fvmrc` for FVM configuration)
- **State Management**: Hybrid approach
  - **Legacy pages** (150+): GetX MVC/MVVM pattern in `lib/pages/`
  - **New features**: Clean Architecture + Riverpod in `lib/features/`
- **Platforms**: Android, iOS, Windows, Linux, macOS

## Development Commands

### Common Commands

```bash
# Dependency management
flutter pub get                  # Install dependencies
flutter pub upgrade              # Upgrade dependencies

# Running and building
flutter run                      # Run app (default platform)
flutter build apk                # Build Android APK
flutter build ios                # Build iOS
flutter build windows            # Build Windows
flutter build linux              # Build Linux
flutter build macos              # Build macOS

# Code quality
flutter test                     # Run tests
flutter analyze                  # Static analysis (run before committing)
dart format .                    # Format code

# Build outputs go to dist/ directory (configured in distribute_options.yaml)
```

### Flutter Version Management

The project uses FVM (Flutter Version Manager). The Flutter version is specified in `.fvmrc`:
- Flutter 3.41.2
- Ensure matching Dart SDK >=3.10.0

## Architecture

The codebase uses a **hybrid architecture** approach:

### 1. Legacy Architecture (GetX MVC) - `lib/pages/`

150+ pages follow the traditional GetX MVC pattern:
- `lib/pages/[feature]/view.dart` - UI layer
- `lib/pages/[feature]/controller.dart` - Business logic with `GetxController`
- Controllers extend `GetxController` and may use mixins like `GetTickerProviderStateMixin`

### 2. Clean Architecture (Riverpod) - `lib/features/`

New features are being migrated to Clean Architecture with Riverpod:

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: HomePage, ShellPage, etc.             │
│  - Widgets: Feature-specific widgets            │
│  - Providers: Riverpod state management         │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: Core business models               │
│  - Repositories: Abstract repository interfaces │
│  - Use Cases: Business logic encapsulation      │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - DataSources: Local/Remote data sources       │
│  - RepositoryImpls: Repository implementations  │
└─────────────────────────────────────────────────┘
```

**Clean Architecture Directory Structure:**
```
lib/features/[feature]/
├── domain/                  # Domain layer (core business logic)
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/          # Use cases
├── data/                   # Data layer (data fetching & persistence)
│   ├── datasources/       # Data sources
│   └── repositories/      # Repository implementations
└── presentation/          # Presentation layer (UI & state)
    ├── providers/         # Riverpod providers
    ├── pages/            # Pages
    └── widgets/          # Widgets
```

**Key Features Using Clean Architecture:**
- `lib/features/shell/` - Main navigation shell
- `lib/features/home/` - Home page with tabs
- `lib/features/home_hot/` - Hot videos
- `lib/features/home_rcmd/` - Recommended videos
- `lib/features/backup/` - Settings backup

### Key Architectural Patterns

1. **State Management**:
   - **GetX**: Legacy pages use `GetxController` with reactive variables (`Rx`)
   - **Riverpod**: New features use Riverpod providers with `ConsumerWidget`
   - Both coexist during migration period

2. **Service Locator**: Dependency injection via GetX `lazyPut`/`put`
   - Defined in `lib/services/service_locator.dart`
   - Services: `AccountService`, `DownloadService`, `AudioHandler`

3. **Routing**: Centralized in `lib/app/router/app_pages.dart`
   - Uses GetX routing with `GetPage` definitions
   - 150+ routes registered for different features
   - Clean architecture pages also registered here

4. **Repository Pattern**: HTTP layer abstracts API calls
   - Single Request singleton in `lib/http/init.dart`
   - Feature-specific API files: `login.dart`, `video.dart`, `dynamics.dart`, `live.dart`
   - Clean architecture features define repository interfaces in domain layer

### Startup Flow

The app uses a three-phase initialization strategy managed by `AppInitializer`:

1. **Blocking Phase** (before `runApp`):
   - Flutter bindings (ScaledWidgetsFlutterBinding, MediaKit)
   - App paths
   - Full storage initialization (all Hive boxes)

2. **Core Phase** (async after `runApp`):
   - HTTP client
   - GetX services (AccountService, DownloadService)
   - Platform settings (orientation, system UI)

3. **Auxiliary Phase** (on-demand lazy loading):
   - Audio service (setupServiceLocator)
   - WebView (desktop only)
   - Window manager (desktop only)

This design minimizes startup time while maintaining code organization.

For implementation details, see `lib/services/app_initializer/app_initializer.dart`.

### Directory Structure

```
lib/
├── app/                  # Application-level configuration
│   ├── app.dart         # Root app widget
│   └── router/          # Route definitions (app_pages.dart)
├── common/              # Shared widgets, constants, dialogs
├── core/                # Core utilities
│   ├── constants/       # App-wide constants
│   └── storage/         # Core storage abstractions
├── features/            # NEW: Clean architecture features
│   ├── shell/           # Main navigation shell
│   ├── home/            # Home page
│   ├── home_hot/        # Hot videos
│   ├── home_rcmd/       # Recommended videos
│   └── backup/          # Settings backup
├── grpc/                # Protobuf-based gRPC implementations
│   └── bilibili/        # Generated protobuf files (excluded from analysis)
├── http/                # Networking layer with Dio
│   ├── init.dart        # Request singleton & configuration
│   ├── api.dart         # API endpoint definitions
│   └── *.dart           # Feature-specific API calls
├── models/              # Legacy data models
├── models_new/          # New data models (API responses)
├── pages/               # 150+ legacy feature pages (MVC structure)
│   └── [feature]/
│       ├── view.dart
│       └── controller.dart
├── plugin/              # Custom plugins
│   └── pl_player/       # Video player built on media-kit
├── scripts/             # Build scripts & Flutter framework patches
├── services/            # Business logic services
│   ├── account_service.dart
│   ├── audio_handler.dart
│   ├── app_initializer/  # App initialization phases
│   └── service_locator.dart
├── tcp/                 # Live streaming TCP implementation
└── utils/               # Utilities, extensions, helpers
    ├── accounts/        # Multi-account management
    └── storage.dart     # Hive-based local storage
```

### Key Components

**Networking Layer** (`lib/http/`):
- Dio-based HTTP client with HTTP/2 support
- Custom `AccountManager` interceptor for multi-account cookie management
- Brotli and GZIP decompression support
- Request/response interceptors for authentication

**Multi-Account System** (`lib/utils/accounts/`):
- Support for multiple user accounts with cookie-based authentication
- Seamless account switching via `AccountManager`
- Storage via Hive database

**Data Persistence** (`lib/core/storage/`):
- **New Architecture**: Clean Architecture-based storage with Domain/Data layer separation
  - Domain: Abstract repository interfaces (`StorageRepository`, `TypedStorageRepository`)
  - Data: MMKV implementations (default) + Hive (for account system)
  - Storage factory pattern for easy backend switching
- **Current State**: MMKV is the default storage backend
  - **MMKV** (86%): setting, localCache, video, historyWord, watchProgress, userInfo
  - **Hive** (14%): account system only (`utils/accounts.dart`)
- **Migration**: Automatic Hive → MMKV migration on first startup (transparent to users)
- WebDAV import/export support

**Video Player** (`lib/plugin/pl_player/`):
- Custom player built on media-kit
- Features: PIP, DLNA, background playback
- Advanced controls: danmaku, subtitle, speed control

**gRPC Layer** (`lib/grpc/`):
- Bilibili-specific gRPC implementations
- Protobuf-based communication for audio, DM, dynamics, IM, replies

**Live Streaming** (`lib/tcp/`):
- Real-time TCP communication for live rooms

### Data Flow

1. User interaction triggers Controller action
2. Controller calls Service/HTTP layer
3. HTTP layer makes API request (with account context)
4. Response parsed into Models (`models_new/`)
5. Controller updates state via reactive programming (`Rx` variables, `update()`)
6. View rebuilds automatically

## Important Dependencies

The project uses custom forks of several packages:

```yaml
get:
  git: https://github.com/bggRGjQaUbCoE/getx.git
  ref: version_4.7.2

extended_nested_scroll_view:
  git: https://github.com/bggRGjQaUbCoE/extended_nested_scroll_view.git
  ref: mod

material_design_icons_flutter:
  git: https://github.com/bggRGjQaUbCoE/material_design_icons_flutter.git
  ref: const
```

The project also uses forked media-kit packages (see `dependency_overrides` in `pubspec.yaml`).

Key third-party packages:
- **media-kit**: Video playback engine (forked)
- **GetX**: State management, routing, DI (forked)
- **flutter_riverpod**: New state management for clean architecture features
- **Dio**: HTTP client with interceptors
- **Hive/MMKV**: Local NoSQL database storage
- **canvas_danmaku**: Danmaku (bullet comment) rendering
- **flutter_inappwebview**: WebView for authentication
- **audio_service**: Background audio playback
- **window_manager/tray_manager**: Desktop window management

## Build Process

**Flutter Framework Patches**:
The project applies custom patches to the Flutter SDK during build:
- `lib/scripts/bottom_sheet_patch.diff`
- `lib/scripts/modal_barrier-patch.diff`
- `lib/scripts/mouse_cursor_patch.diff`

These patches modify Flutter framework behavior for specific UI requirements.

## Code Style

The project uses strict linting rules in `analysis_options.yaml`:
- `flutter_lints` with additional custom rules
- Excludes generated gRPC files from analysis (`lib/grpc/bilibili/**`)
- Requires return types, const constructors, and other strict patterns
- Formatter preserves trailing commas

Run `flutter analyze` before committing.

## Working with Clean Architecture (Riverpod)

When adding new features using Clean Architecture:

1. **Create feature structure** under `lib/features/[feature]/`:
   ```
   lib/features/my_feature/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   ├── data/
   │   ├── datasources/
   │   └── repositories/
   └── presentation/
       ├── providers/
       ├── pages/
       └── widgets/
   ```

2. **Follow dependency rules**:
   - Domain layer has no dependencies on outer layers
   - Data layer implements Domain interfaces
   - Presentation layer uses Use Cases, not repositories directly

3. **Use Riverpod providers** for state management:
   ```dart
   final myFeatureProvider = StateNotifierProvider<MyFeatureNotifier, MyState>((ref) {
     return MyFeatureNotifier(ref.read(getMyFeatureUseCaseProvider));
   });
   ```

4. **Register routes** in `lib/app/router/app_pages.dart`

## Working with Legacy Architecture (GetX)

When modifying existing GetX pages:

1. **Follow MVC pattern**:
   - View in `view.dart` extends `GetView<Controller>`
   - Controller in `controller.dart` extends `GetxController`
   - Use `Rx` variables for reactive state
   - Call `update()` to trigger rebuilds

2. **Navigation**:
   - Use `Get.toNamed()` for route navigation
   - Routes defined in `lib/app/router/app_pages.dart`

3. **Services**:
   - Access via `Get.find()` or `Get.put()`
   - Registered in `lib/services/service_locator.dart`

## Multi-Account Considerations

When working with authenticated features:
- Use `AccountService` to access current account info
- HTTP requests automatically include appropriate cookies via `AccountManager` interceptor
- Account switching is handled transparently
- Store account-specific data with account context

The multi-account system uses Hive for persistence and supports cookie-based authentication with seamless switching.

## Special Features

- **Danmaku System**: Bullet comment rendering with filtering/blocking (canvas_danmaku)
- **Download Manager**: Offline video viewing with queue management
- **Live Streaming**: TCP-based real-time communication for live rooms
- **DLNA Support**: Video casting to compatible devices (dlna_dart)
- **WebDAV Backup**: Settings backup/restore (webdav_client)
- **Audio Service**: Background playback with media notification support
- **Video Player**: Custom player on media-kit with PIP, danmaku, subtitle support
- **Multi-language**: Chinese-language interface (Bilibili-specific)

## Common Development Patterns

### HTTP API Calls

For legacy pages:
```dart
import 'package:PiliPlus/http/init.dart';

final response = await Request().get(url, query: data);
```

For clean architecture:
```dart
// Define in domain/repositories/my_repository.dart
abstract class MyRepository {
  Future<Result> fetchData();
}

// Implement in data/repositories/my_repository_impl.dart
class MyRepositoryImpl implements MyRepository {
  final RemoteDataSource remoteDataSource;
  // Use HTTP client via data source
}
```

## Storage Architecture

The storage module follows Clean Architecture principles with **MMKV as the default storage backend**.

### Current Status

- **MMKV (Default)**: 86% of storage operations
  - setting, localCache, video, historyWord, watchProgress, userInfo
  - Automatic migration from Hive on first startup
  - Transparent to users, backward compatible
- **Hive (Legacy)**: 14% of storage operations
  - Account system only (`utils/accounts.dart`)
  - Uses complex TypeAdapter chain for `LoginAccount` and `DefaultCookieJar`

### Directory Structure

```
lib/core/storage/
├── domain/                      # Domain layer (abstractions)
│   ├── keys/                    # Storage key constants
│   │   ├── setting_keys.dart    # Setting keys (organized by feature)
│   │   ├── local_cache_keys.dart
│   │   └── video_keys.dart
│   └── repositories/            # Storage interfaces
│       ├── storage_repository.dart
│       └── typed_storage_repository.dart
├── data/                        # Data layer (implementations)
│   ├── datasources/
│   │   ├── hive_storage_repository_impl.dart
│   │   └── mmkv_storage_repository_impl.dart
│   ├── storage_factory.dart     # Storage factory
│   ├── storage_config.dart      # Storage configuration
│   └── storage_migrator.dart    # Hive to MMKV migration
├── storage.dart                 # Main storage class (backward compatible)
├── storage_key.dart             # Re-exports domain keys
└── storage_pref.dart            # Type-safe preference accessors
```

### Using Storage

**Legacy API (still supported)**:
```dart
// Read/write using GStorage (internally uses MMKV)
final value = GStorage.setting.get(SettingBoxKey.someKey, defaultValue: 'default');
GStorage.setting.put(SettingBoxKey.someKey, 'newValue');

// Type-safe access via Pref
final bool enableFeature = Pref.someBoolSetting;
```

**New API (recommended for new code)**:
```dart
// Using storage repository (MMKV backend)
final repository = GStorage.settingRepository;
final value = repository.getString('someKey') ?? 'default';
await repository.setString('someKey', 'newValue');

// Typed storage for complex objects
final userInfo = GStorage.userInfoRepository.get('userInfoCache');
await GStorage.userInfoRepository.set('userInfoCache', newUserInfo);
```

### MMKV Migration

**Migration is automatic and enabled by default:**
1. First startup detects existing Hive data
2. Automatically migrates to MMKV in background
3. Marks migration complete to avoid re-migration
4. All subsequent operations use MMKV

**Migrated storages:**
- ✅ setting - Application settings
- ✅ localCache - Local cache
- ✅ video - Video settings
- ✅ historyWord - Search history
- ✅ userInfo - User info (JSON serialized)
- ✅ watchProgress - Watch progress

**Not migrated (still uses Hive):**
- ⚠️ account - Account system (see `HIVE_REMOVAL_ANALYSIS.md`)

### Adding New Storage Keys

1. Add key to appropriate file in `lib/core/storage/domain/keys/`
2. For settings, use categorized files (video, danmaku, subtitle, UI, etc.)
3. Keys are automatically re-exported from `storage_key.dart` for backward compatibility

### Directory Structure

```
lib/core/storage/
├── domain/                      # Domain layer (abstractions)
│   ├── keys/                    # Storage key constants
│   │   ├── setting_keys.dart    # Setting keys (organized by feature)
│   │   ├── local_cache_keys.dart
│   │   └── video_keys.dart
│   └── repositories/            # Storage interfaces
│       ├── storage_repository.dart
│       └── typed_storage_repository.dart
├── data/                        # Data layer (implementations)
│   ├── datasources/
│   │   ├── hive_storage_repository_impl.dart
│   │   └── mmkv_storage_repository_impl.dart
│   ├── storage_factory.dart     # Storage factory
│   ├── storage_config.dart      # Storage configuration
│   └── storage_migrator.dart    # Hive to MMKV migration
├── storage.dart                 # Main storage class (backward compatible)
├── storage_key.dart             # Re-exports domain keys
└── storage_pref.dart            # Type-safe preference accessors
```

### Using Storage

**Legacy API (still supported)**:
```dart
// Read/write using GStorage (internally uses MMKV)
final value = GStorage.setting.get(SettingBoxKey.someKey, defaultValue: 'default');
GStorage.setting.put(SettingBoxKey.someKey, 'newValue');

// Type-safe access via Pref
final bool enableFeature = Pref.someBoolSetting;
```

**New API (recommended for new code)**:
```dart
// Using storage repository (MMKV backend)
final repository = GStorage.settingRepository;
final value = repository.getString('someKey') ?? 'default';
await repository.setString('someKey', 'newValue');

// Typed storage for complex objects
final userInfo = GStorage.userInfoRepository.get('userInfoCache');
await GStorage.userInfoRepository.set('userInfoCache', newUserInfo);
```

### MMKV Migration

**Migration is automatic and enabled by default:**
1. First startup detects existing Hive data
2. Automatically migrates to MMKV in background
3. Marks migration complete to avoid re-migration
4. All subsequent operations use MMKV

**Migrated storages:**
- ✅ setting - Application settings
- ✅ localCache - Local cache
- ✅ video - Video settings
- ✅ historyWord - Search history
- ✅ userInfo - User info (JSON serialized)
- ✅ watchProgress - Watch progress

**Not migrated (still uses Hive):**
- ⚠️ account - Account system (see `HIVE_REMOVAL_ANALYSIS.md`)

### Adding New Storage Keys

1. Add key to appropriate file in `lib/core/storage/domain/keys/`
2. For settings, use categorized files (video, danmaku, subtitle, UI, etc.)
3. Keys are automatically re-exported from `storage_key.dart` for backward compatibility

