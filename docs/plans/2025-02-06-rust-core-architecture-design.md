# Rust Core Architecture Design

**Date**: 2025-02-06
**Status**: Approved
**Author**: Claude Code + User Collaboration

## Overview

This document describes the architecture for rewriting PiliPlus's core functionality in Rust, with Flutter serving as a pure UI display layer. The migration will be a full rewrite of all non-UI business logic.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Flutter UI Layer (Pure View)                │
│  - Stateless widgets                                     │
│  - StreamBuilder consuming Rust streams                  │
│  - User interaction → Bridge calls to Rust              │
└─────────────────────┬───────────────────────────────────┘
                      │ flutter_rust_bridge
                      │ (async streams + FFI)
┌─────────────────────┴───────────────────────────────────┐
│              Rust Core Layer                             │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Bridge API (FFI boundary)                       │   │
│  │  - Serialization/Deserialization                 │   │
│  │  - Stream adapters (Rust Stream → Dart Stream)   │   │
│  └──────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Services Layer (Tokio async)                    │   │
│  │  - HttpService (reqwest + HTTP/2)                │   │
│  │  - AccountService (multi-account mgmt)          │   │
│  │  - DownloadService (async download manager)      │   │
│  │  - StorageService (embedded DB)                  │   │
│  └──────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Data Models                                     │   │
│  │  - Shared structs with serde                     │   │
│  │  - Protobuf integration                          │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### State Management
- **Rust-centric**: All business logic and state owned by Rust
- **Flutter as view**: UI only subscribes to streams and sends commands
- **No logic in controllers**: GetX controllers are thin wrappers

### Concurrency Model
- **Full async**: Tokio runtime with async/await
- **Bridge async support**: Use flutter_rust_bridge's async capabilities
- **Streaming architecture**: Rust channels → Dart streams

### Architecture Principles
1. **Single source of truth**: All data in Rust
2. **Reactive UI**: Flutter rebuilds based on Rust state changes
3. **Type safety**: Compile-time checks across FFI boundary
4. **Zero-copy where possible**: Avoid serialization overhead

## Core Services

### 1. HTTP/Networking Layer

**Responsibilities**: HTTP client, API calls, authentication, cookie management

**Technology**: reqwest + Tokio

**Key Features**:
- HTTP/2 with connection pooling
- Automatic Brotli/GZIP decompression
- Account-based cookie injection
- Streaming downloads for large files
- Retry logic with exponential backoff

**API Structure**:
```rust
pub struct HttpService {
    client: Client,
    account_manager: Arc<AccountManager>,
}

impl HttpService {
    pub async fn request<T: DeserializeOwned>(
        &self,
        method: Method,
        url: &str,
        with_auth: bool,
    ) -> Result<T, ApiError>;

    pub async fn download_stream(
        &self,
        url: &str,
    ) -> Result<impl Stream<Item = Result<Bytes, Error>>, ApiError>;
}
```

**API Modules**:
- `video.rs`: Video info, playback URLs
- `live.rs`: Live room info, chat
- `dynamics.rs`: User posts/feeds
- `login.rs`: Authentication flows
- `user.rs`: User profiles, following
- 20+ more modules

### 2. Account Service

**Responsibilities**: Multi-account management, authentication, session handling

**Technology**: Tokio channels, async state

**Key Features**:
- QR code login with real-time status streaming
- Multi-account support with seamless switching
- Cookie management with automatic refresh
- Broadcast notifications for account changes
- Persistent session storage

**API Structure**:
```rust
pub struct AccountService {
    current_account: Arc<RwLock<Option<Account>>>,
    storage: Arc<StorageService>,
    account_change_tx: broadcast::Sender<Account>,
}

impl AccountService {
    pub async fn login_qr(&self) -> impl Stream<Item = QrState>;
    pub async fn switch_account(&self, account_id: &str) -> Result<(), AccountError>;
    pub async fn logout(&self) -> Result<(), AccountError>;
    pub fn account_changes(&self) -> broadcast::Receiver<Account>;
}
```

**Account Model**:
```rust
pub struct Account {
    pub id: String,
    pub name: String,
    pub avatar: String,
    pub cookies: HashMap<String, String>,
    pub auth_tokens: AuthTokens,
    pub is_logged_in: bool,
}
```

### 3. Download Service

**Responsibilities**: Video download management, progress tracking, pause/resume

**Technology**: Tokio async tasks, channels

**Key Features**:
- Concurrent downloads with configurable limits
- Real-time progress (speed, ETA, bytes)
- Pause/resume with byte-offset resume
- Error recovery and retry
- Persistent task state across restarts

**API Structure**:
```rust
pub struct DownloadService {
    active_downloads: Arc<RwLock<HashMap<String, DownloadTask>>>,
    storage: Arc<StorageService>,
    http: Arc<HttpService>,
    download_tx: broadcast::Sender<DownloadEvent>,
}

impl DownloadService {
    pub async fn start_download(
        &self,
        video_id: &str,
        quality: VideoQuality,
        output_dir: &str,
    ) -> Result<String, DownloadError>;

    pub async fn pause_download(&self, task_id: &str) -> Result<(), DownloadError>;
    pub async fn resume_download(&self, task_id: &str) -> Result<(), DownloadError>;
    pub fn events(&self) -> broadcast::Receiver<DownloadEvent>;
}
```

**Download States**:
```rust
pub enum DownloadStatus {
    Pending,
    Downloading { speed: f64, eta: Option<Duration> },
    Paused,
    Completed,
    Failed { error: String },
    Cancelled,
}
```

### 4. Storage Service

**Responsibilities**: Data persistence, caching, settings

**Technology**: SQLite via sqlx (async)

**Key Features**:
- Async database operations
- JSON column support for complex types
- Schema migrations
- Type-safe queries with compile-time checks

**Database Schema**:
```sql
-- Accounts table
CREATE TABLE accounts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    avatar TEXT,
    cookies_json TEXT NOT NULL,
    auth_tokens_json TEXT NOT NULL,
    is_logged_in INTEGER NOT NULL DEFAULT 0
);

-- Settings table (key-value with JSON values)
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value_json TEXT NOT NULL
);

-- Watch progress
CREATE TABLE watch_progress (
    video_id TEXT PRIMARY KEY,
    progress_ms INTEGER NOT NULL,
    total_duration_ms INTEGER NOT NULL,
    updated_at TEXT NOT NULL
);

-- Search history
CREATE TABLE search_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    keyword TEXT NOT NULL,
    created_at TEXT NOT NULL
);
```

**API Structure**:
```rust
pub struct StorageService {
    db: Arc<SqlitePool>,
    storage_dir: PathBuf,
}

impl StorageService {
    pub async fn save_account(&self, account: &Account) -> Result<(), StorageError>;
    pub async fn load_account(&self, id: &str) -> Result<Account, StorageError>;
    pub async fn set_setting<T: Serialize>(&self, key: &str, value: &T) -> Result<(), StorageError>;
    pub async fn get_setting<T: DeserializeOwned>(&self, key: &str) -> Result<Option<T>, StorageError>;
}
```

## Bridge Integration

### Flutter-Rust-Bridge Configuration

**Config**: `flutter_rust_bridge.yaml`
```yaml
rust_input: crate::api
rust_root: rust/
dart_output: lib/src/rust
```

### Stream Adapters

Convert Rust channels to Dart streams:

```rust
pub struct QrLoginStream {
    receiver: mpsc::Receiver<QrState>,
}

impl QrLoginStream {
    pub fn new(receiver: mpsc::Receiver<QrState>) -> Self;
    pub async fn next(&mut self) -> Option<QrState>;
}
```

### Service Singleton Pattern

```rust
static SERVICES: Lazy<Arc<Services>> = Lazy::new(|| {
    // Initialize all services
    Arc::new(Services {
        http,
        account,
        storage,
        download,
    })
});

#[frb(sync)]
pub fn services() -> Arc<Services> {
    SERVICES.clone()
}
```

### Flutter Usage

```dart
// Access services
final services = services();
final accountService = services.account;

// Subscribe to stream
final loginStream = loginQr(accountService);
StreamBuilder<QrState>(
  stream: loginStream.stream,
  builder: (context, snapshot) {
    // UI based on state
  },
);
```

## Data Models

Shared between Rust and Dart via serde serialization:

```rust
#[derive(Clone, Serialize, Deserialize)]
pub struct VideoInfo {
    pub bvid: String,
    pub aid: i64,
    pub title: String,
    pub description: String,
    pub owner: VideoOwner,
    pub cover: Image,
    pub duration: u32,
    pub view_count: u64,
    pub cid: i64,
    pub pages: Vec<VideoPage>,
}

#[derive(Clone, Copy, Serialize, Deserialize)]
pub enum VideoQuality {
    Low = 16,
    Medium = 32,
    High = 64,
    Ultra = 80,
    FourK = 112,
}
```

## Error Handling

Comprehensive error types with serialization for Flutter:

```rust
#[derive(thiserror::Error, Debug)]
pub enum ApiError {
    #[error("HTTP request failed: {0}")]
    HttpError(#[from] reqwest::Error),
    #[error("API returned error: code={code}, msg={message}")]
    ApiError { code: i32, message: String },
    #[error("Authentication required")]
    Unauthorized,
    // ... more variants
}

// Serializable version for bridge
#[derive(Clone, Serialize, Deserialize)]
pub struct SerializableError {
    pub code: String,
    pub message: String,
}
```

## Testing Strategy

### Unit Tests
- Test business logic in isolation
- Use `wiremock` for HTTP mocking
- Property-based testing with `proptest`

### Integration Tests
- Full workflow tests across modules
- Test database migrations
- Test concurrent operations

### Flutter Integration Tests
- Test UI integration with bridge
- End-to-end user flows
- Performance benchmarks

## Performance Considerations

1. **Lazy initialization**: Don't block UI startup
2. **Zero-copy**: Use `bytes::Bytes` for large data
3. **Connection pooling**: Reuse HTTP connections
4. **Async file I/O**: Use tokio::fs
5. **Memory efficiency**: Rust uses less memory than Dart

## Migration Phases

### Phase 1: Foundation (2-3 weeks)
- Set up Rust infrastructure
- Basic bridge communication
- Storage service implementation

### Phase 2: Core Services (4-6 weeks)
- Account service migration
- HTTP service migration
- Parallel running with Flutter code

### Phase 3: Network Layer (6-8 weeks)
- Migrate all HTTP API modules
- Replace Dio-based calls
- Update controllers to use Rust

### Phase 4: Download Service (3-4 weeks)
- Migrate download manager
- Implement progress tracking
- Test resume functionality

### Phase 5: Remaining Services (4-6 weeks)
- Audio handler
- Danmaku processing
- Other remaining services

### Phase 6: Cleanup (2 weeks)
- Remove old Flutter code
- Remove unused dependencies
- Optimize bundle size

**Total Timeline**: 21-29 weeks (5-7 months)

## Benefits

✅ **Performance**: Tokio async, zero-copy, efficient memory
✅ **Safety**: Rust ownership prevents data races
✅ **Maintainability**: Type-safe, compile-time checks
✅ **Cross-platform**: Shared logic across platforms
✅ **Code sharing**: Reusable in native apps/backend
✅ **Bundle size**: ~5-7 MB smaller after migration

## Dependencies

### Rust
```toml
flutter_rust_bridge = "2.11.1"
tokio = { version = "1.35", features = ["full"] }
reqwest = { version = "0.11", features = ["json", "cookies", "http2", "brotli"] }
sqlx = { version = "0.7", features = ["runtime-tokio", "sqlite"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
thiserror = "1.0"
uuid = { version = "1.6", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
```

### Flutter (After Migration)
- Keep: GetX, media_kit, UI packages
- Remove: dio, hive, cookie_jar
- Add: flutter_rust_bridge, pilicore

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Long migration timeline | Incremental migration with parallel running |
| FFI bugs | Comprehensive testing, gradual rollout |
| Performance regression | Benchmark at each phase |
| Developer learning curve | Pair programming, documentation |

## Next Steps

1. Create detailed implementation plan
2. Set up development environment (git worktree)
3. Begin Phase 1: Foundation
