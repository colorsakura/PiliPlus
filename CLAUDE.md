# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PiliPlus** is a Flutter-based third-party Bilibili client (unofficial) built with:
- **Dart SDK**: >=3.10.0
- **Flutter**: 3.38.6
- **State Management**: GetX (MVC/MVVM pattern)
- **Platforms**: Android, iOS, Windows, Linux, macOS

## Development Commands

### Common Commands

```bash
flutter pub get                  # Install dependencies
flutter run                      # Run app
flutter build apk                # Build Android APK
flutter build ios                # Build iOS
flutter build windows            # Build Windows
flutter build linux              # Build Linux
flutter build macos              # Build macOS
flutter analyze                  # Static analysis
dart format .                    # Format code
```

### Rust Commands (FFI Bridge)

```bash
# Navigate to Rust directory
cd rust

# Build Rust library
cargo build                      # Debug build
cargo build --release            # Release build

# Check code (faster than build)
cargo check                      # Quick compile check
cargo clippy                     # Lint with Clippy

# Format code
cargo fmt                        # Format Rust code

# Update dependencies
cargo update                     # Update Cargo.lock
```

### Flutter-Rust Bridge Code Generation

```bash
# Generate Dart bindings from Rust code
flutter_rust_bridge_codegen --config-file flutter_rust_bridge.yaml
```

**IMPORTANT:** After modifying Rust bridge code (functions marked with `#[frb]`), regenerate Dart bindings:
1. Run `flutter_rust_bridge_codegen`
2. Format generated code: `dart format lib/src/rust/`
3. Do NOT manually edit generated files (marked with auto-generated comments)

### Build Distribution
Build outputs go to `dist/` directory (configured in `distribute_options.yaml`).

## Architecture

### Multi-Layer Architecture with Rust FFI

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│  (Pages/Views + GetX Controllers + Widgets)      │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Business Logic Layer               │
│  (Dart Services + Rust Core via FFI)            │
├─────────────────────────────────────────────────┤
│  Rust Core (pilicore):                          │
│  - API calls (reqwest, tokio)                   │
│  - Storage (sqlx, SQLite)                       │
│  - Stream processing                            │
│  - Download management                          │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                          │
│  (HTTP API, gRPC, TCP, Hive Storage)            │
└─────────────────────────────────────────────────┘
```

### Rust Integration Architecture

**Flutter-Rust Bridge (FRB):**
- **Location:** `rust/src/api/` (Rust side), `lib/src/rust/` (Dart side)
- **Config:** `flutter_rust_bridge.yaml`
- **Purpose:** High-performance FFI bridge between Dart and Rust
- **Version:** flutter_rust_bridge 2.11.1

**Rust Crate Structure:**
```
rust/
├── src/
│   ├── api/              # FFI bridge endpoints (#[frb] marked)
│   │   ├── bridge.rs     # Core bridge init & health checks
│   │   ├── video.rs      # Video API endpoints
│   │   ├── rcmd.rs       # Recommendation API
│   │   ├── account.rs    # Account management
│   │   ├── comments.rs   # Comments API
│   │   ├── dynamics.rs   # Dynamics/Feed API
│   │   └── mod.rs        # API module exports
│   ├── models/           # Data models (serde + FRB)
│   ├── bilibili_api/     # Bilibili-specific API clients
│   ├── services/         # Business logic services
│   ├── storage/          # SQLite persistence (sqlx)
│   ├── http/             # HTTP client (reqwest)
│   ├── account/          # Account/login logic
│   ├── download/         # Download management
│   ├── stream/           # Stream processing
│   ├── error/            # Error types (thiserror)
│   ├── lib.rs            # Library root
│   └── frb_generated.rs  # AUTO-GENERATED (DO NOT EDIT)
├── Cargo.toml            # Rust dependencies
└── target/               # Build artifacts (gitignored)
```

**Dart Side Structure:**
```
lib/src/rust/
├── api/                  # Generated API wrappers
├── models/               # Generated data models
├── error.dart            # Error type mappings
├── frb_generated.dart    # AUTO-GENERATED (DO NOT EDIT)
├── frb_generated.io.dart # Platform-specific (AUTO-GENERATED)
└── frb_generated.web.dart # Web-specific (AUTO-GENERATED)
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

**Rust Core** (`rust/src/`):
- **HTTP Client**: reqwest with tokio async runtime
- **Storage**: sqlx with SQLite for persistent data
- **Serialization**: serde for efficient JSON parsing
- **Error Handling**: thiserror for typed errors
- **Bridge**: flutter_rust_bridge for FFI communication

**Flutter-Rust Bridge** (`lib/src/rust/` + `rust/src/api/`):
- High-performance FFI bridge between Dart and Rust
- Automatic code generation via `flutter_rust_bridge_codegen`
- Mark bridge functions with `#[frb]` attribute in Rust
- Generated Dart bindings in `lib/src/rust/`
- Configuration in `flutter_rust_bridge.yaml`

**Networking Layer** (`lib/http/`):
- Dio-based HTTP client with HTTP/2 support
- Custom `AccountManager` interceptor for multi-account cookie management
- Brotli and GZIP decompression support
- Request/response interceptors for authentication
- **Facade Pattern**: `VideoApiFacade` routes between Rust/Flutter implementations

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

**Dart-only path:**
1. User interaction triggers Controller action
2. Controller calls Service/HTTP layer
3. HTTP layer makes API request via Dio (with account context)
4. Response parsed into Models (`models_new/`)
5. Controller updates state via reactive programming (`Rx` variables, `update()`)
6. View rebuilds automatically

**Rust-accelerated path (e.g., Video API):**
1. User interaction triggers Controller action
2. Controller calls Service/Facade (e.g., `VideoApiFacade`)
3. Facade routes to Rust implementation (when feature flag enabled)
4. FFI bridge call to `rust/src/api/` via `flutter_rust_bridge`
5. Rust code:
   - Makes HTTP request via reqwest
   - Parses JSON with serde
   - Processes data with business logic
6. Results converted to Dart models via adapters
7. Controller updates state
8. View rebuilds automatically

## Important Dependencies

### Flutter/Dart Dependencies

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
- **flutter_rust_bridge**: FFI bridge to Rust code (2.11.1)

### Rust Dependencies

Key crates (see `rust/Cargo.toml`):
- **flutter_rust_bridge** (2.11.1): FFI code generation
- **tokio** (1.35): Async runtime
- **reqwest** (0.11): HTTP client with JSON/cookies/brotli
- **sqlx** (0.7): Database access with SQLite
- **serde** (1.0): Serialization/deserialization
- **thiserror** (1.0): Error handling
- **tracing** (0.1): Logging and instrumentation

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

**Pre-commit validation:**
- Run `flutter analyze` for Dart code
- Run `cargo clippy` for Rust code
- **Do NOT run tests** - this project does not use automated tests

## Multi-Account Considerations

When working with authenticated features:
- Use `AccountService` to access current account info
- HTTP requests automatically include appropriate cookies via `AccountManager`
- Account switching is handled transparently by the interceptor
- Store account-specific data with account context

## Development Guidelines

**IMPORTANT: Do NOT write tests**

To save time and focus on feature development:
- **Do NOT write unit tests** for new code
- **Do NOT write integration tests**
- **Do NOT add test files** or test modules
- Focus on manual testing and code review
- Use `flutter analyze` and `cargo check` for basic validation

This project prioritizes rapid development over comprehensive test coverage.

## Rust Development Workflow

### Adding New Rust API Functions

**1. Define Rust function with bridge attribute:**

```rust
// In rust/src/api/my_feature.rs
use flutter_rust_bridge::frb;

#[frb]
pub async fn my_rust_function(param: String) -> Result<MyModel, ApiError> {
    // Your Rust logic here
    Ok(MyModel { field: "value".to_string() })
}
```

**2. Add to api module:**

```rust
// In rust/src/api/mod.rs
pub mod my_feature;
```

**3. Generate Dart bindings:**

```bash
flutter_rust_bridge_codegen --config-file flutter_rust_bridge.yaml
dart format lib/src/rust/
```

**4. Use in Dart:**

```dart
import 'package:PiliPlus/src/rust/api/my_feature.dart';

final result = await myRustFunction('param');
```

### Important Rules

**✅ DO:**
- Edit files in `rust/src/api/`, `rust/src/models/`, `rust/src/services/`, etc.
- Mark bridge functions with `#[frb]` or `#[frb(sync)]`
- Run `cargo fmt` to format Rust code
- Regenerate bindings after modifying bridge code
- Add feature flags in Dart for gradual rollout

**❌ DO NOT:**
- Write tests (unit tests, integration tests, or any test code)
- Add `#[cfg(test)]` modules or test files
- Edit `rust/src/frb_generated.rs` (auto-generated)
- Edit `lib/src/rust/frb_generated*.dart` (auto-generated)
- Edit `lib/src/rust/api/*.dart` (auto-generated from Rust)
- Edit `lib/src/rust/models/*.dart` (auto-generated from Rust)
- Manually modify generated files - changes will be lost

**Generated Files (DO NOT EDIT):**
```
rust/src/frb_generated.rs
lib/src/rust/frb_generated.dart
lib/src/rust/frb_generated.io.dart
lib/src/rust/frb_generated.web.dart
lib/src/rust/api/*.dart
lib/src/rust/models/*.dart
```

### Debugging Rust Code

**Enable Rust Logging:**
```rust
// In Rust
use tracing::{info, debug, error};

#[frb]
pub async fn my_function() {
    info!("Function called");
    debug!("Debug info: {:?}", data);
}
```

**View Logs:**
```bash
# Set RUST_LOG environment variable
RUST_LOG=debug flutter run
```

**Common Issues:**
1. **Bridge not initialized**: Ensure `initCore()` is called in `main()`
2. **Type mismatch**: Check serde serialization and FRB type mappings
3. **Async issues**: Use `#[frb]` for async, `#[frb(sync)]` for sync functions
4. **Memory leaks**: Ensure proper stream/Channel handling

### Performance Best Practices

**When to use Rust:**
- CPU-intensive tasks (JSON parsing, encryption)
- Large data processing (video metadata, bulk operations)
- Network requests with complex parsing
- Background processing (downloads, stream handling)

**When to use Dart:**
- UI updates and state management
- Simple business logic
- Quick prototypes
- Small, infrequent operations

**Performance Monitoring:**
```dart
import 'package:PiliPlus/utils/rust_api_metrics.dart';

// Track performance
final stopwatch = Stopwatch()..start();
await rustFunction();
stopwatch.stop();

RustApiMetrics.recordCall('rustFunction', stopwatch.elapsedMilliseconds);
```

## Special Features

- **Danmaku System**: Bullet comment rendering with filtering/blocking
- **Download Manager**: Offline video viewing
- **Live Streaming**: TCP-based real-time communication
- **DLNA Support**: Video casting to compatible devices
- **WebDAV Backup**: Settings backup/restore
- **Multi-language**: Chinese-language interface (Bilibili-specific)
