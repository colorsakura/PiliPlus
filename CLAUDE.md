# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PiliPlus** is a Flutter-based third-party Bilibili client (unofficial) built with:
- **Dart SDK**: >=3.10.0
- **Flutter**: 3.38.6 (managed via FVM)
- **State Management**: GetX (MVC/MVVM pattern)
- **Platforms**: Android, iOS, Windows, Linux, macOS

## Development Commands

### Flutter Version Management
This project uses FVM to manage the Flutter version. Use `fvm` before all Flutter commands:

```bash
fvm flutter pub get              # Install dependencies
fvm flutter run                  # Run app
fvm flutter build apk            # Build Android APK
fvm flutter build ios            # Build iOS
fvm flutter build windows        # Build Windows
fvm flutter build linux          # Build Linux
fvm flutter build macos          # Build macOS
fvm flutter analyze              # Static analysis
dart format .                    # Format code
```

### Testing
```bash
fvm flutter test                 # Run tests
```

### Build Distribution
Build outputs go to `dist/` directory (configured in `distribute_options.yaml`).

## Architecture

### Multi-Layer Architecture

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│  (Pages/Views + GetX Controllers + Widgets)      │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Business Logic Layer               │
│  (Services: Account, Download, Audio, etc.)     │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                          │
│  (HTTP API, gRPC, TCP, Hive Storage)            │
└─────────────────────────────────────────────────┘
```

### Key Architectural Patterns

1. **GetX MVC Pattern**: Most pages follow GetX MVC with separate files:
   - `lib/pages/[feature]/view.dart` - UI layer
   - `lib/pages/[feature]/controller.dart` - Business logic with `GetxController`
   - Controllers extend `GetxController` and may use mixins like `GetTickerProviderStateMixin`

2. **Service Locator**: Dependency injection via GetX `lazyPut`/`put`
   - Defined in `lib/services/service_locator.dart`
   - Services: `AccountService`, `DownloadService`, `AudioHandler`

3. **Routing**: Centralized in `lib/router/app_pages.dart`
   - Uses GetX routing with `GetPage` definitions
   - 150+ routes registered for different features

4. **Repository Pattern**: HTTP layer abstracts API calls
   - Single Request singleton in `lib/http/init.dart`
   - Feature-specific API files: `login.dart`, `video.dart`, `dynamics.dart`, `live.dart`

### Directory Structure

```
lib/
├── common/           # Shared widgets, constants, dialogs
├── grpc/             # Protobuf-based gRPC implementations
│   └── bilibili/     # Generated protobuf files (excluded from analysis)
├── http/             # Networking layer with Dio
│   ├── init.dart     # Request singleton & configuration
│   ├── api.dart      # API endpoint definitions
│   └── *.dart        # Feature-specific API calls
├── models/           # Legacy data models
├── models_new/       # New data models (API responses)
├── pages/            # 150+ feature pages (MVC structure)
│   └── [feature]/
│       ├── view.dart
│       └── controller.dart
├── plugin/           # Custom plugins
│   └── pl_player/    # Video player built on media-kit
├── router/           # Route definitions
├── scripts/          # Build scripts & Flutter framework patches
├── services/         # Business logic services
│   ├── account_service.dart
│   ├── audio_handler.dart
│   └── service_locator.dart
├── tcp/              # Live streaming TCP implementation
└── utils/            # Utilities, extensions, helpers
    ├── accounts/     # Multi-account management
    └── storage.dart  # Hive-based local storage
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

**Data Persistence** (`lib/utils/storage.dart`):
- Hive-based NoSQL storage for:
  - User info, settings, local cache
  - Search history, video settings
  - Watch progress
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

Key third-party packages:
- **media-kit**: Video playback engine
- **GetX**: State management, routing, DI
- **Dio**: HTTP client with interceptors
- **Hive**: Local NoSQL database
- **canvas_danmaku**: Danmaku (bullet comment) rendering
- **flutter_inappwebview**: WebView for authentication

## Build Process

**Flutter Framework Patches**:
The project applies custom patches to the Flutter SDK during build:
- `lib/scripts/bottom_sheet_patch.diff`
- `lib/scripts/modal-barrier-patch.diff`

These patches modify Flutter framework behavior for specific UI requirements.

## Code Style

The project uses strict linting rules in `analysis_options.yaml`:
- `flutter_lints` with additional custom rules
- Excludes generated gRPC files from analysis (`lib/grpc/bilibili/**`)
- Requires return types, const constructors, and other strict patterns
- Formatter preserves trailing commas

Run `fvm flutter analyze` before committing.

## Multi-Account Considerations

When working with authenticated features:
- Use `AccountService` to access current account info
- HTTP requests automatically include appropriate cookies via `AccountManager`
- Account switching is handled transparently by the interceptor
- Store account-specific data with account context

## Special Features

- **Danmaku System**: Bullet comment rendering with filtering/blocking
- **Download Manager**: Offline video viewing
- **Live Streaming**: TCP-based real-time communication
- **DLNA Support**: Video casting to compatible devices
- **WebDAV Backup**: Settings backup/restore
- **Multi-language**: Chinese-language interface (Bilibili-specific)
