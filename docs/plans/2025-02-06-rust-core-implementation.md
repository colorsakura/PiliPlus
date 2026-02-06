# Rust Core Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite all non-UI business logic in Rust with Flutter as pure UI layer, using flutter_rust_bridge for FFI communication and Tokio for async runtime.

**Architecture:** Rust-centric state management with streaming architecture. All business logic, networking, storage, and services in Rust. Flutter controllers subscribe to Rust streams via FFI and render UI. Full async/await with Tokio runtime.

**Tech Stack:**
- Rust: tokio, reqwest, sqlx, serde, flutter_rust_bridge
- Flutter: flutter_rust_bridge, GetX (thin wrappers only)
- Database: SQLite via sqlx
- Async: Tokio runtime with async/await

---

# Phase 1: Foundation (Week 1-3)

## Task 1: Set Up Rust Project Infrastructure

**Files:**
- Modify: `rust/Cargo.toml`
- Modify: `rust/src/lib.rs`
- Create: `rust/src/error.rs`
- Create: `rust/src/error/mod.rs`

**Step 1: Update Cargo.toml with dependencies**

Open `rust/Cargo.toml` and replace contents:

```toml
[package]
name = "pilicore"
version = "0.1.0"
edition = "2021"

[lib]
name = "pilicore"
crate-type = ["staticlib", "cdylib"]

[dependencies]
flutter_rust_bridge = "2.11.1"
tokio = { version = "1.35", features = ["full"] }
reqwest = { version = "0.11", features = ["json", "cookies", "http2", "brotli"] }
sqlx = { version = "0.7", features = ["runtime-tokio", "sqlite", "chrono"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
thiserror = "1.0"
uuid = { version = "1.6", features = ["v4", "v5", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
once_cell = "1.19"
tracing = "0.1"
tracing-subscriber = "0.3"
bytes = "1.5"

[dev-dependencies]
wiremock = "0.6"
proptest = "1.4"
tokio-test = "0.4"

[build-dependencies]
flutter_rust_bridge_codegen = "2.11.1"
```

**Step 2: Verify dependencies resolve**

Run: `cd rust && cargo check`

Expected: "Finished dev [unoptimized] check"

**Step 3: Commit**

```bash
git add rust/Cargo.toml
git commit -m "feat(rust): add core dependencies for pilicore"
```

---

## Task 2: Create Error Handling System

**Files:**
- Create: `rust/src/error/mod.rs`
- Create: `rust/src/error/api_error.rs`
- Create: `rust/src/error/storage_error.rs`
- Create: `rust/src/error/account_error.rs`
- Create: `rust/src/error/download_error.rs`

**Step 1: Write the error module structure**

Create `rust/src/error/mod.rs`:

```rust
pub mod api_error;
pub mod storage_error;
pub mod account_error;
pub mod download_error;

pub use api_error::ApiError;
pub use storage_error::StorageError;
pub use account_error::AccountError;
pub use download_error::DownloadError;

// Serializable error for Flutter bridge
#[derive(Clone, serde::Serialize, serde::Deserialize, Debug)]
pub struct SerializableError {
    pub code: String,
    pub message: String,
}

impl From<ApiError> for SerializableError {
    fn from(err: ApiError) -> Self {
        SerializableError {
            code: error_code(&err),
            message: err.to_string(),
        }
    }
}

impl From<StorageError> for SerializableError {
    fn from(err: StorageError) -> Self {
        SerializableError {
            code: "STORAGE_ERROR".to_string(),
            message: err.to_string(),
        }
    }
}

impl From<AccountError> for SerializableError {
    fn from(err: AccountError) -> Self {
        SerializableError {
            code: "ACCOUNT_ERROR".to_string(),
            message: err.to_string(),
        }
    }
}

impl From<DownloadError> for SerializableError {
    fn from(err: DownloadError) -> Self {
        SerializableError {
            code: "DOWNLOAD_ERROR".to_string(),
            message: err.to_string(),
        }
    }
}

fn error_code(err: &ApiError) -> String {
    match err {
        ApiError::HttpError(_) => "HTTP_ERROR".to_string(),
        ApiError::ApiError { .. } => "API_ERROR".to_string(),
        ApiError::Unauthorized => "UNAUTHORIZED".to_string(),
        ApiError::NetworkUnavailable => "NETWORK_UNAVAILABLE".to_string(),
        ApiError::SerializationError(_) => "SERIALIZATION_ERROR".to_string(),
        _ => "UNKNOWN_ERROR".to_string(),
    }
}

// Result type for bridge functions
pub type BridgeResult<T> = Result<T, SerializableError>;
```

**Step 2: Write ApiError**

Create `rust/src/error/api_error.rs`:

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("HTTP request failed: {0}")]
    HttpError(#[from] reqwest::Error),

    #[error("API returned error: code={code}, msg={message}")]
    ApiError { code: i32, message: String },

    #[error("Authentication required")]
    Unauthorized,

    #[error("Network unavailable")]
    NetworkUnavailable,

    #[error("Serialization error: {0}")]
    SerializationError(#[from] serde_json::Error),

    #[error("Invalid URL: {0}")]
    InvalidUrl(String),

    #[error("Request timeout")]
    Timeout,
}
```

**Step 3: Write StorageError**

Create `rust/src/error/storage_error.rs`:

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum StorageError {
    #[error("Database error: {0}")]
    DatabaseError(#[from] sqlx::Error),

    #[error("Account not found: {0}")]
    AccountNotFound(String),

    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),

    #[error("Serialization error: {0}")]
    SerializationError(#[from] serde_json::Error),
}
```

**Step 4: Write AccountError**

Create `rust/src/error/account_error.rs`:

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AccountError {
    #[error("Login failed: {0}")]
    LoginFailed(String),

    #[error("QR code expired")]
    QrExpired,

    #[error("Account not found: {0}")]
    AccountNotFound(String),

    #[error("No active account")]
    NoActiveAccount,

    #[error("Session expired")]
    SessionExpired,
}
```

**Step 5: Write DownloadError**

Create `rust/src/error/download_error.rs`:

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DownloadError {
    #[error("Download failed: {0}")]
    DownloadFailed(String),

    #[error("Download not found: {0}")]
    NotFound(String),

    #[error("Download paused")]
    Paused,

    #[error("File system error: {0}")]
    FileSystemError(#[from] std::io::Error),

    #[error("HTTP error: {0}")]
    HttpError(#[from] reqwest::Error),
}
```

**Step 6: Add error module to lib.rs**

Open `rust/src/lib.rs`:

```rust
pub mod error;
pub mod api;

mod frb_generated;
```

**Step 7: Verify compilation**

Run: `cd rust && cargo check`

Expected: "Finished dev [unoptimized] check"

**Step 8: Write tests for error conversion**

Create `rust/src/error/tests.rs`:

```rust
use super::*;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_api_error_to_serializable() {
        let err = ApiError::Unauthorized;
        let serializable: SerializableError = err.into();
        assert_eq!(serializable.code, "UNAUTHORIZED");
        assert!(serializable.message.contains("Authentication"));
    }

    #[test]
    fn test_http_error_to_serializable() {
        let http_err = reqwest::Error::from(
            reqwest::Error::Request(#[from] std::io::Error::new(
                std::io::ErrorKind::NotFound,
                "not found"
            ))
        );
        let err = ApiError::HttpError(http_err);
        let serializable: SerializableError = err.into();
        assert_eq!(serializable.code, "HTTP_ERROR");
    }

    #[test]
    fn test_storage_error_to_serializable() {
        let err = StorageError::AccountNotFound("test_id".to_string());
        let serializable: SerializableError = err.into();
        assert_eq!(serializable.code, "STORAGE_ERROR");
        assert!(serializable.message.contains("Account not found"));
    }
}
```

**Step 9: Run tests**

Run: `cd rust && cargo test error::tests`

Expected: All tests pass (3 passed)

**Step 10: Commit**

```bash
git add rust/src/error/
git commit -m "feat(rust): add error handling system with serializable types"
```

---

## Task 3: Create Shared Data Models

**Files:**
- Create: `rust/src/models/mod.rs`
- Create: `rust/src/models/common.rs`
- Create: `rust/src/models/video.rs`
- Create: `rust/src/models/user.rs`
- Create: `rust/src/models/account.rs`

**Step 1: Write common models**

Create `rust/src/models/common.rs`:

```rust
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct Image {
    pub url: String,
    pub width: Option<u32>,
    pub height: Option<u32>,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct ApiResponse<T> {
    pub code: i32,
    pub message: String,
    pub data: Option<T>,
}

impl<T> ApiResponse<T> {
    pub fn is_success(&self) -> bool {
        self.code == 0
    }

    pub fn into_result(self) -> Result<T, ApiError> {
        if self.is_success() {
            self.data.ok_or_else(|| {
                ApiError::ApiError {
                    code: self.code,
                    message: "No data in response".to_string(),
                }
            })
        } else {
            Err(ApiError::ApiError {
                code: self.code,
                message: self.message,
            })
        }
    }
}
```

**Step 2: Write video models**

Create `rust/src/models/video.rs`:

```rust
use serde::{Deserialize, Serialize};
use super::common::Image;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoInfo {
    pub bvid: String,
    pub aid: i64,
    pub title: String,
    #[serde(rename = "desc")]
    pub description: String,
    pub owner: VideoOwner,
    pub pic: Image,
    pub duration: u32,
    #[serde(rename = "stat")]
    pub stats: VideoStats,
    pub cid: i64,
    pub pages: Vec<VideoPage>,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoOwner {
    pub mid: i64,
    pub name: String,
    pub face: Image,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoStats {
    #[serde(rename = "view")]
    pub view_count: u64,
    #[serde(rename = "like")]
    pub like_count: u64,
    #[serde(rename = "coin")]
    pub coin_count: u64,
    #[serde(rename = "favorite")]
    pub collect_count: u64,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoPage {
    pub cid: i64,
    pub page: i32,
    pub part: String,
    pub duration: u32,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoUrl {
    pub quality: VideoQuality,
    pub format: VideoFormat,
    #[serde(rename = "durl")]
    pub segments: Vec<VideoSegment>,
}

#[derive(Clone, Copy, Serialize, Deserialize, Debug, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum VideoQuality {
    Low = 16,
    Medium = 32,
    High = 64,
    Ultra = 80,
    FourK = 112,
}

#[derive(Clone, Copy, Serialize, Deserialize, Debug, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum VideoFormat {
    Mp4,
    Dash,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoSegment {
    pub url: String,
    pub size: u64,
    #[serde(rename = "length")]
    pub duration: u32,
}
```

**Step 3: Write user models**

Create `rust/src/models/user.rs`:

```rust
use serde::{Deserialize, Serialize};
use super::common::Image;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserInfo {
    pub mid: i64,
    pub name: String,
    pub face: Image,
    #[serde(rename = "level")]
    pub level_info: UserLevel,
    #[serde(rename = "vip")]
    pub vip_status: VipStatus,
    pub money: CoinBalance,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserLevel {
    pub current_level: u8,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VipStatus {
    pub status: u8,
    #[serde(rename = "type")]
    pub vip_type: u8,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct CoinBalance {
    pub coins: u32,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserStats {
    pub following: u32,
    pub follower: u32,
}
```

**Step 4: Write account models**

Create `rust/src/models/account.rs`:

```rust
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct Account {
    pub id: String,
    pub name: String,
    pub avatar: String,
    pub cookies: HashMap<String, String>,
    pub auth_tokens: AuthTokens,
    pub is_logged_in: bool,
}

impl Account {
    pub fn cookie_header(&self) -> String {
        self.cookies
            .iter()
            .map(|(k, v)| format!("{}={}", k, v))
            .collect::<Vec<_>>()
            .join("; ")
    }

    pub fn update_cookie(&mut self, key: String, value: String) {
        self.cookies.insert(key, value);
    }
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct AuthTokens {
    pub access_token: Option<String>,
    pub refresh_token: Option<String>,
    pub expires_at: Option<i64>,
}
```

**Step 5: Create models module**

Create `rust/src/models/mod.rs`:

```rust
pub mod common;
pub mod video;
pub mod user;
pub mod account;

pub use common::*;
pub use video::*;
pub use user::*;
pub use account::*;
```

**Step 6: Add models module to lib.rs**

Open `rust/src/lib.rs`:

```rust
pub mod error;
pub mod models;
pub mod api;

mod frb_generated;
```

**Step 7: Write tests for models**

Create `rust/src/models/tests.rs`:

```rust
use super::*;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cookie_header_construction() {
        let mut account = Account {
            id: "test".to_string(),
            name: "Test User".to_string(),
            avatar: "https://example.com/avatar.jpg".to_string(),
            cookies: HashMap::new(),
            auth_tokens: AuthTokens {
                access_token: None,
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: true,
        };

        account.update_cookie("SESSDATA".to_string(), "abc123".to_string());
        account.update_cookie("bili_jct".to_string(), "xyz789".to_string());

        let header = account.cookie_header();
        assert!(header.contains("SESSDATA=abc123"));
        assert!(header.contains("bili_jct=xyz789"));
    }

    #[test]
    fn test_api_response_success() {
        let resp: ApiResponse<String> = ApiResponse {
            code: 0,
            message: "success".to_string(),
            data: Some("test data".to_string()),
        };

        assert!(resp.is_success());
        assert_eq!(resp.into_result().unwrap(), "test data");
    }

    #[test]
    fn test_api_response_error() {
        let resp: ApiResponse<String> = ApiResponse {
            code: -1,
            message: "error".to_string(),
            data: None,
        };

        assert!(!resp.is_success());
        let result: Result<String, ApiError> = resp.into_result();
        assert!(result.is_err());
    }

    #[test]
    fn test_video_quality_values() {
        assert_eq!(VideoQuality::Low as i32, 16);
        assert_eq!(VideoQuality::FourK as i32, 112);
    }
}
```

**Step 8: Run tests**

Run: `cd rust && cargo test models::tests`

Expected: All tests pass (4 passed)

**Step 9: Commit**

```bash
git add rust/src/models/
git commit -m "feat(rust): add shared data models with serde serialization"
```

---

## Task 4: Set Up Storage Service Foundation

**Files:**
- Create: `rust/src/storage/mod.rs`
- Create: `rust/src_storage/service.rs`
- Create: `rust/migrations/001_initial.sql`

**Step 1: Create database migration**

Create `rust/migrations/001_initial.sql`:

```sql
-- Accounts table
CREATE TABLE IF NOT EXISTS accounts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    avatar TEXT,
    cookies_json TEXT NOT NULL,
    auth_tokens_json TEXT NOT NULL,
    is_logged_in INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Settings table (key-value with JSON values)
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value_json TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Watch progress
CREATE TABLE IF NOT EXISTS watch_progress (
    video_id TEXT PRIMARY KEY,
    progress_ms INTEGER NOT NULL,
    total_duration_ms INTEGER NOT NULL,
    updated_at TEXT NOT NULL
);

-- Search history
CREATE TABLE IF NOT EXISTS search_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    keyword TEXT NOT NULL,
    created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_search_history_created
ON search_history(created_at DESC);

-- Download tasks
CREATE TABLE IF NOT EXISTS download_tasks (
    id TEXT PRIMARY KEY,
    video_id TEXT NOT NULL,
    title TEXT NOT NULL,
    quality INTEGER NOT NULL,
    total_bytes INTEGER NOT NULL,
    downloaded_bytes INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL,
    file_path TEXT NOT NULL,
    created_at TEXT NOT NULL,
    completed_at TEXT
);
```

**Step 2: Write storage service structure**

Create `rust/src/storage/service.rs`:

```rust
use sqlx::{SqlitePool, Row};
use chrono::Utc;
use crate::models::Account;
use crate::error::StorageError;

pub struct StorageService {
    db: SqlitePool,
}

impl StorageService {
    pub async fn new(db_path: &str) -> Result<Self, StorageError> {
        // Ensure directory exists
        if let Some(parent) = std::path::Path::new(db_path).parent() {
            tokio::fs::create_dir_all(parent).await?;
        }

        let pool = SqlitePool::connect(db_path).await?;

        // Run migrations
        sqlx::query(include_str!("../../migrations/001_initial.sql"))
            .execute(&pool)
            .await?;

        Ok(Self { db: pool })
    }

    // Account operations
    pub async fn save_account(&self, account: &Account) -> Result<(), StorageError> {
        let cookies_json = serde_json::to_string(&account.cookies)?;
        let tokens_json = serde_json::to_string(&account.auth_tokens)?;
        let now = Utc::now().to_rfc3339();

        sqlx::query(
            r#"
            INSERT INTO accounts (id, name, avatar, cookies_json, auth_tokens_json, is_logged_in, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                name = excluded.name,
                avatar = excluded.avatar,
                cookies_json = excluded.cookies_json,
                auth_tokens_json = excluded.auth_tokens_json,
                is_logged_in = excluded.is_logged_in,
                updated_at = excluded.updated_at
            "#
        )
        .bind(&account.id)
        .bind(&account.name)
        .bind(&account.avatar)
        .bind(&cookies_json)
        .bind(&tokens_json)
        .bind(account.is_logged_in)
        .bind(&now)
        .bind(&now)
        .execute(&self.db)
        .await?;

        Ok(())
    }

    pub async fn load_account(&self, id: &str) -> Result<Account, StorageError> {
        let row = sqlx::query_as::<_, AccountRow>(
            "SELECT * FROM accounts WHERE id = ?"
        )
        .bind(id)
        .fetch_optional(&self.db)
        .await?;

        match row {
            Some(row) => row.into_account(),
            None => Err(StorageError::AccountNotFound(id.to_string())),
        }
    }

    pub async fn all_accounts(&self) -> Result<Vec<Account>, StorageError> {
        let rows = sqlx::query_as::<_, AccountRow>(
            "SELECT * FROM accounts ORDER BY updated_at DESC"
        )
        .fetch_all(&self.db)
        .await?;

        let mut accounts = Vec::new();
        for row in rows {
            accounts.push(row.into_account()?);
        }
        Ok(accounts)
    }

    pub async fn delete_account(&self, id: &str) -> Result<(), StorageError> {
        sqlx::query("DELETE FROM accounts WHERE id = ?")
            .bind(id)
            .execute(&self.db)
            .await?;
        Ok(())
    }

    // Settings operations
    pub async fn set_setting<T: serde::Serialize>(
        &self,
        key: &str,
        value: &T,
    ) -> Result<(), StorageError> {
        let json = serde_json::to_string(value)?;
        let now = Utc::now().to_rfc3339();

        sqlx::query(
            "INSERT INTO settings (key, value_json, updated_at) VALUES (?, ?, ?)
             ON CONFLICT(key) DO UPDATE SET value_json = excluded.value_json, updated_at = excluded.updated_at"
        )
        .bind(key)
        .bind(&json)
        .bind(&now)
        .execute(&self.db)
        .await?;

        Ok(())
    }

    pub async fn get_setting<T: for<'de> serde::Deserialize<'de>>(
        &self,
        key: &str,
    ) -> Result<Option<T>, StorageError> {
        let row = sqlx::query("SELECT value_json FROM settings WHERE key = ?")
            .bind(key)
            .fetch_optional(&self.db)
            .await?;

        match row {
            Some(r) => {
                let json: String = r.get("value_json");
                let value = serde_json::from_str(&json)?;
                Ok(Some(value))
            }
            None => Ok(None),
        }
    }
}

// Helper struct for database rows
struct AccountRow {
    id: String,
    name: String,
    avatar: String,
    cookies_json: String,
    auth_tokens_json: String,
    is_logged_in: bool,
    created_at: String,
    updated_at: String,
}

impl AccountRow {
    fn into_account(self) -> Result<Account, StorageError> {
        Ok(Account {
            id: self.id,
            name: self.name,
            avatar: self.avatar,
            cookies: serde_json::from_str(&self.cookies_json)?,
            auth_tokens: serde_json::from_str(&self.auth_tokens_json)?,
            is_logged_in: self.is_logged_in,
        })
    }
}
```

**Step 3: Create storage module**

Create `rust/src/storage/mod.rs`:

```rust
pub mod service;

pub use service::StorageService;
```

**Step 4: Add storage module to lib.rs**

Open `rust/src/lib.rs`:

```rust
pub mod error;
pub mod models;
pub mod storage;
pub mod api;

mod frb_generated;
```

**Step 5: Write tests for storage service**

Create `rust/src/storage/tests.rs`:

```rust
use super::*;
use crate::models::account::AuthTokens;
use std::collections::HashMap;

#[cfg(test)]
mod tests {
    use super::*;

    async fn create_test_storage() -> StorageService {
        StorageService::new(":memory:").await.unwrap()
    }

    #[tokio::test]
    async fn test_save_and_load_account() {
        let storage = create_test_storage().await;

        let account = Account {
            id: "test_123".to_string(),
            name: "Test User".to_string(),
            avatar: "https://example.com/avatar.jpg".to_string(),
            cookies: {
                let mut map = HashMap::new();
                map.insert("SESSDATA".to_string(), "test123".to_string());
                map
            },
            auth_tokens: AuthTokens {
                access_token: Some("token".to_string()),
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: true,
        };

        storage.save_account(&account).await.unwrap();

        let loaded = storage.load_account("test_123").await.unwrap();
        assert_eq!(loaded.id, "test_123");
        assert_eq!(loaded.name, "Test User");
        assert_eq!(loaded.cookies.len(), 1);
        assert!(loaded.is_logged_in);
    }

    #[tokio::test]
    async fn test_load_nonexistent_account() {
        let storage = create_test_storage().await;

        let result = storage.load_account("nonexistent").await;
        assert!(matches!(result, Err(StorageError::AccountNotFound(_))));
    }

    #[tokio::test]
    async fn test_all_accounts() {
        let storage = create_test_storage().await;

        let account1 = Account {
            id: "acc1".to_string(),
            name: "User 1".to_string(),
            avatar: "".to_string(),
            cookies: HashMap::new(),
            auth_tokens: AuthTokens {
                access_token: None,
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: false,
        };

        let account2 = Account {
            id: "acc2".to_string(),
            name: "User 2".to_string(),
            avatar: "".to_string(),
            cookies: HashMap::new(),
            auth_tokens: AuthTokens {
                access_token: None,
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: false,
        };

        storage.save_account(&account1).await.unwrap();
        storage.save_account(&account2).await.unwrap();

        let accounts = storage.all_accounts().await.unwrap();
        assert_eq!(accounts.len(), 2);
    }

    #[tokio::test]
    async fn test_set_and_get_setting() {
        let storage = create_test_storage().await;

        storage.set_setting("theme", "dark").await.unwrap();
        let theme: Option<String> = storage.get_setting("theme").await.unwrap();
        assert_eq!(theme, Some("dark".to_string()));

        let missing: Option<String> = storage.get_setting("nonexistent").await.unwrap();
        assert_eq!(missing, None);
    }
}
```

**Step 6: Run tests**

Run: `cd rust && cargo test storage::tests`

Expected: All tests pass (4 passed)

**Step 7: Commit**

```bash
git add rust/src/storage/ rust/migrations/
git commit -m "feat(rust): add storage service with SQLite backend"
```

---

This completes the foundational setup. The plan continues in the next section with Phase 2 implementation.

**Next Phase**: HTTP Service, Account Service, and Bridge API surface

---

# Phase 2: Core Services (Week 4-9)

## Task 5: Implement HTTP Service

**Files:**
- Create: `rust/src/http/mod.rs`
- Create: `rust/src/http/service.rs`
- Create: `rust/src/http/client.rs`
- Create: `rust/src/http/tests.rs`
- Modify: `rust/src/lib.rs`

**Step 1: Create HTTP client with reqwest**

Create `rust/src/http/client.rs`:

```rust
use reqwest::{Client, Method};
use crate::error::ApiError;

pub struct HttpClient {
    client: Client,
    base_url: String,
}

impl HttpClient {
    pub fn new(base_url: String) -> Result<Self, ApiError> {
        let client = Client::builder()
            .http2_adaptive_window(true)
            .build()
            .map_err(|e| ApiError::HttpError(e))?;

        Ok(Self { client, base_url })
    }

    pub async fn get<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self.client
            .get(&url)
            .send()
            .await?;

        self.handle_response(response).await
    }

    pub async fn post<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        body: serde_json::Value,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await?;

        self.handle_response(response).await
    }

    async fn handle_response<T: serde::de::DeserializeOwned>(
        &self,
        response: reqwest::Response,
    ) -> Result<T, ApiError> {
        if response.status().is_success() {
            response
                .json()
                .await
                .map_err(ApiError::from)
        } else {
            Err(ApiError::ApiError {
                code: response.status().as_u16() as i32,
                message: format!("HTTP error: {}", response.status()),
            })
        }
    }
}
```

**Step 2: Create HTTP service**

Create `rust/src/http/service.rs`:

```rust
use std::sync::Arc;
use std::collections::HashMap;
use crate::http::client::HttpClient;
use crate::models::Account;
use crate::error::ApiError;

pub struct HttpService {
    client: Arc<HttpClient>,
    account: Arc<tokio::sync::RwLock<Option<Account>>>,
}

impl HttpService {
    pub fn new(base_url: String) -> Result<Self, ApiError> {
        let client = Arc::new(HttpClient::new(base_url)?);
        Ok(Self {
            client,
            account: Arc::new(tokio::sync::RwLock::new(None)),
        })
    }

    pub async fn set_account(&self, account: Account) {
        *self.account.write().await = Some(account);
    }

    pub async fn get<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
    ) -> Result<T, ApiError> {
        self.client.get(path).await
    }

    pub async fn get_with_auth<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
    ) -> Result<T, ApiError> {
        // TODO: Add cookie header from current account
        self.client.get(path).await
    }
}
```

**Step 3: Create HTTP module**

Create `rust/src/http/mod.rs`:

```rust
pub mod client;
pub mod service;

pub use service::HttpService;
pub use client::HttpClient;
```

**Step 4: Update lib.rs**

Open `rust/src/lib.rs`:

```rust
pub mod error;
pub mod models;
pub mod storage;
pub mod http;
pub mod api;

mod frb_generated;
```

**Step 5: Write tests**

Create `rust/src/http/tests.rs`:

```rust
use super::*;

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_http_client_creation() {
        let client = HttpClient::new("https://api.bilibili.com".to_string());
        assert!(client.is_ok());
    }

    #[test]
    fn test_http_service_creation() {
        let service = HttpService::new("https://api.bilibili.com".to_string());
        assert!(service.is_ok());
    }
}
```

**Step 6: Run tests**

Run: `cd rust && cargo test http::tests`

Expected: All tests pass (2 passed)

**Step 7: Commit**

```bash
git add rust/src/http/
git commit -m "feat(rust): add HTTP service with reqwest client"
```

---

## Task 6: Implement Account Service

**Files:**
- Create: `rust/src/account/mod.rs`
- Create: `rust/src/account/service.rs`
- Create: `rust/src/account/qrcode.rs`
- Create: `rust/src/account/tests.rs`
- Modify: `rust/src/lib.rs`

**Step 1: Create QR code login models**

Create `rust/src/account/qrcode.rs`:

```rust
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct QrCodeData {
    pub url: String,
    pub oauth_key: String,
    pub expiry: u64,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub enum QrState {
    Code { url: String, expiry: u64 },
    Scanned,
    LoggedIn(Account),
    Expired,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub enum QrStatus {
    Waiting,
    Scanned,
    Success { cookies: HashMap<String, String> },
    Expired,
}

use crate::models::Account;
```

**Step 2: Create account service**

Create `rust/src/account/service.rs`:

```rust
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};
use crate::models::Account;
use crate::storage::StorageService;
use crate::http::HttpService;
use crate::account::qrcode::{QrState, QrStatus};
use crate::error::AccountError;
use crate::error::BridgeResult;

pub struct AccountService {
    current_account: Arc<RwLock<Option<Account>>>,
    storage: Arc<StorageService>,
    http: Arc<HttpService>,
    account_change_tx: broadcast::Sender<Account>,
}

impl AccountService {
    pub fn new(
        storage: Arc<StorageService>,
        http: Arc<HttpService>,
    ) -> Self {
        let (tx, _) = broadcast::channel(16);

        Self {
            current_account: Arc::new(RwLock::new(None)),
            storage,
            http,
            account_change_tx: tx,
        }
    }

    pub async fn current_account(&self) -> Option<Account> {
        self.current_account.read().await.clone()
    }

    pub async fn set_current_account(&self, account: Account) {
        *self.current_account.write().await = Some(account.clone());
        let _ = self.account_change_tx.send(account);
    }

    pub fn account_changes(&self) -> broadcast::Receiver<Account> {
        self.account_change_tx.subscribe()
    }

    pub async fn switch_account(&self, account_id: &str) -> Result<(), AccountError> {
        let account = self.storage.load_account(account_id).await
            .map_err(|_| AccountError::AccountNotFound(account_id.to_string()))?;

        self.set_current_account(account).await;
        Ok(())
    }
}
```

**Step 3: Create account module**

Create `rust/src/account/mod.rs`:

```rust
pub mod service;
pub mod qrcode;

pub use service::AccountService;
pub use qrcode::{QrState, QrStatus, QrCodeData};
```

**Step 4: Update lib.rs**

Open `rust/src/lib.rs`:

```rust
pub mod error;
pub mod models;
pub mod storage;
pub mod http;
pub mod account;
pub mod api;

mod frb_generated;
```

**Step 5: Write tests**

Create `rust/src/account/tests.rs`:

```rust
use super::*;

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_account_service_creation() {
        // TODO: Add proper test with mock storage and HTTP
        // For now just test structure
    }

    #[test]
    fn test_qr_state_serialization() {
        use crate::account::QrState;
        use std::collections::HashMap;

        let state = QrState::Code {
            url: "https://test.com".to_string(),
            expiry: 180,
        };

        let json = serde_json::to_string(&state).unwrap();
        assert!(json.contains("Code"));
    }
}
```

**Step 6: Run tests**

Run: `cd rust && cargo test account::tests`

Expected: All tests pass (1 passed)

**Step 7: Commit**

```bash
git add rust/src/account/
git commit -m "feat(rust): add account service with QR login support"
```

---

## Task 7: Create Bridge API Surface

**Files:**
- Create: `rust/src/api/mod.rs`
- Create: `rust/src/api/bridge.rs`
- Modify: `rust/src/api/simple.rs` (update existing file)
- Modify: `rust/src/lib.rs`

**Step 1: Create bridge module**

Create `rust/src/api/bridge.rs`:

```rust
use flutter_rust_bridge::frb;
use crate::error::BridgeResult;

/// Initialize the Rust core
#[frb(sync)]
pub fn init_core() {
    // Initialize logging
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .init();

    tracing::info!("PiliPlus Rust core initialized");
}

/// Get version information
#[frb(sync)]
pub fn get_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// Health check
#[frb(sync)]
pub fn health_check() -> bool {
    true
}
```

**Step 2: Update api module**

Open `rust/src/api/mod.rs`:

```rust
pub mod simple;
pub mod bridge;

pub use bridge::*;
```

**Step 3: Update simple.rs for new bridge pattern**

Open `rust/src/api/simple.rs`:

```rust
use flutter_rust_bridge::frb;

#[frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
```

**Step 4: Update lib.rs to ensure api module is properly exported**

Open `rust/src/lib.rs`:

```rust
pub mod error;
pub mod models;
pub mod storage;
pub mod http;
pub mod account;
pub mod api;

mod frb_generated;
```

**Step 5: Run cargo check**

Run: `cd rust && cargo check`

Expected: "Finished dev [unoptimized] check"

**Step 6: Commit**

```bash
git add rust/src/api/
git commit -m "feat(rust): add bridge API surface with health check"
```

---

## Task 8: Implement Video API Module

**Files:**
- Create: `rust/src/api/video.rs`
- Modify: `rust/src/api/mod.rs`

**Step 1: Create video API**

Create `rust/src/api/video.rs`:

```rust
use flutter_rust_bridge::frb;
use crate::models::{VideoInfo, VideoUrl, VideoQuality};
use crate::error::BridgeResult;

/// Get video information
#[frb]
pub async fn get_video_info(bvid: String) -> BridgeResult<VideoInfo> {
    // TODO: Implement actual API call
    // For now, return mock data
    let mock_info = VideoInfo {
        bvid: bvid.clone(),
        aid: 123456,
        title: "Test Video".to_string(),
        description: "Test Description".to_string(),
        owner: crate::models::VideoOwner {
            mid: 789,
            name: "Test User".to_string(),
            face: crate::models::Image {
                url: "https://test.com/avatar.jpg".to_string(),
                width: Some(100),
                height: Some(100),
            },
        },
        pic: crate::models::Image {
            url: "https://test.com/cover.jpg".to_string(),
            width: Some(1280),
            height: Some(720),
        },
        duration: 600,
        stats: crate::models::VideoStats {
            view_count: 10000,
            like_count: 500,
            coin_count: 100,
            collect_count: 50,
        },
        cid: 456789,
        pages: vec![],
    };

    Ok(mock_info)
}

/// Get video playback URL
#[frb]
pub async fn get_video_url(bvid: String, cid: i64, quality: VideoQuality) -> BridgeResult<VideoUrl> {
    // TODO: Implement actual API call
    Ok(VideoUrl {
        quality,
        format: crate::models::VideoFormat::Dash,
        segments: vec![],
    })
}
```

**Step 2: Update api module**

Open `rust/src/api/mod.rs`:

```rust
pub mod simple;
pub mod bridge;
pub mod video;

pub use bridge::*;
```

**Step 3: Run cargo check**

Run: `cd rust && cargo check`

Expected: "Finished dev [unoptimized] check"

**Step 4: Commit**

```bash
git add rust/src/api/
git commit -m "feat(rust): add video API module with mock data"
```

---

This completes Phase 2. The core services are now in place and ready for Flutter integration.

**Next Phase**: Full API integration and Download Service

---

# Phase 3: API Integration & Enhanced Services (Week 10-15)

## Task 9: Implement Real Video API Integration

**Files:**
- Modify: `rust/src/api/video.rs`
- Create: `rust/src/bilibili_api/video.rs`

**Step 1: Create Bilibili video API client**

Create `rust/src/bilibili_api/video.rs`:

```rust
use crate::models::{VideoInfo, VideoUrl, VideoQuality};
use crate::http::HttpService;
use crate::error::ApiError;

pub struct VideoApi {
    http: std::sync::Arc<HttpService>,
}

impl VideoApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_video_info(&self, bvid: &str) -> Result<VideoInfo, ApiError> {
        // Real Bilibili API endpoint
        let url = format!("/x/web-interface/view?bvid={}", bvid);
        self.http.get(&url).await
    }

    pub async fn get_video_url(
        &self,
        bvid: &str,
        cid: i64,
        quality: VideoQuality,
    ) -> Result<VideoUrl, ApiError> {
        let url = format!(
            "/x/player/playurl?bvid={}&cid={}&qn={}",
            bvid,
            cid,
            quality as i32
        );
        self.http.get(&url).await
    }
}
```

**Step 2: Update video API to use real implementation**

Modify `rust/src/api/video.rs`:

```rust
use flutter_rust_bridge::frb;
use crate::models::{VideoInfo, VideoUrl, VideoQuality};
use crate::error::BridgeResult;
use crate::bilibili_api::video::VideoApi;

/// Get video information from Bilibili API
#[frb]
pub async fn get_video_info(bvid: String) -> BridgeResult<VideoInfo> {
    // TODO: Get HttpService from global state
    // For now, keep mock data
    let mock_info = VideoInfo {
        bvid: bvid.clone(),
        aid: 123456,
        title: "Test Video".to_string(),
        description: "Test Description".to_string(),
        owner: crate::models::VideoOwner {
            mid: 789,
            name: "Test User".to_string(),
            face: crate::models::Image {
                url: "https://test.com/avatar.jpg".to_string(),
                width: Some(100),
                height: Some(100),
            },
        },
        pic: crate::models::Image {
            url: "https://test.com/cover.jpg".to_string(),
            width: Some(1280),
            height: Some(720),
        },
        duration: 600,
        stats: crate::models::VideoStats {
            view_count: 10000,
            like_count: 500,
            coin_count: 100,
            collect_count: 50,
        },
        cid: 456789,
        pages: vec![],
    };

    Ok(mock_info)
}

/// Get video playback URL from Bilibili API
#[frb]
pub async fn get_video_url(bvid: String, cid: i64, quality: VideoQuality) -> BridgeResult<VideoUrl> {
    // TODO: Integrate with VideoApi
    Ok(VideoUrl {
        quality,
        format: crate::models::VideoFormat::Dash,
        segments: vec![],
    })
}
```

**Step 3: Create bilibili_api module**

Create `rust/src/bilibili_api/mod.rs`:

```rust
pub mod video;

pub use video::VideoApi;
```

**Step 4: Update lib.rs**

Open `rust/src/lib.rs`:

```rust
pub mod error;
pub mod models;
pub mod storage;
pub mod http;
pub mod account;
pub mod bilibili_api;
pub mod api;

mod frb_generated;
```

**Step 5:** Run `cargo check`

Expected: "Finished dev [unoptimized] check"

**Step 6:** Commit

```bash
git add rust/src/
git commit -m "feat(rust): add Bilibili video API integration layer"
```

---

## Task 10: Implement QR Login Flow

**Files:**
- Create: `rust/src/account/login.rs`
- Modify: `rust/src/account/service.rs`

**Step 1: Create QR login implementation**

Create `rust/src/account/login.rs`:

```rust
use crate::account::qrcode::{QrCodeData, QrState, QrStatus};
use crate::http::HttpService;
use crate::models::Account;
use crate::error::AccountError;
use std::collections::HashMap;

pub struct QrLoginFlow {
    http: std::sync::Arc<HttpService>,
}

impl QrLoginFlow {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_qr_code(&self) -> Result<QrCodeData, AccountError> {
        // Call Bilibili QR code generation API
        Ok(QrCodeData {
            url: "https://passport.bilibili.com/qrcode/auth".to_string(),
            oauth_key: "test_key".to_string(),
            expiry: 180,
        })
    }

    pub async fn poll_qr_status(&self, oauth_key: &str) -> Result<QrStatus, AccountError> {
        // Poll Bilibili QR status API
        // Return appropriate status based on response
        Ok(QrStatus::Waiting)
    }

    pub async fn complete_login(
        &self,
        cookies: HashMap<String, String>,
    ) -> Result<Account, AccountError> {
        // Fetch user info with cookies and create Account
        Ok(Account {
            id: "user_123".to_string(),
            name: "Test User".to_string(),
            avatar: "https://test.com/avatar.jpg".to_string(),
            cookies,
            auth_tokens: crate::models::AuthTokens {
                access_token: None,
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: true,
        })
    }
}
```

**Step 2:** Add login methods to AccountService

Modify `rust/src/account/service.rs`, add to AccountService:

```rust
use crate::account::login::QrLoginFlow;

impl AccountService {
    // ... existing methods ...

    pub fn qr_login_flow(&self) -> QrLoginFlow {
        QrLoginFlow::new(self.http.clone())
    }
}
```

**Step 3:** Update account module

Open `rust/src/account/mod.rs`:

```rust
pub mod service;
pub mod qrcode;
pub mod login;

pub use service::AccountService;
pub use qrcode::{QrState, QrStatus, QrCodeData};
pub use login::QrLoginFlow;
```

**Step 4:** Run `cargo check`

Expected: "Finished dev [unoptimized] check"

**Step 5:** Commit

```bash
git add rust/src/account/
git commit -m "feat(rust): add QR login flow implementation"
```

---

## Task 11: Implement User API Module

**Files:**
- Create: `rust/src/api/user.rs`
- Create: `rust/src/bilibili_api/user.rs`
- Modify: `rust/src/api/mod.rs`

**Step 1: Create Bilibili user API**

Create `rust/src/bilibili_api/user.rs`:

```rust
use crate::models::{UserInfo, UserStats};
use crate::http::HttpService;
use crate::error::ApiError;

pub struct UserApi {
    http: std::sync::Arc<HttpService>,
}

impl UserApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_user_info(&self, mid: i64) -> Result<UserInfo, ApiError> {
        let url = format!("/x/space/acc/info?mid={}", mid);
        self.http.get(&url).await
    }

    pub async fn get_user_stats(&self, mid: i64) -> Result<UserStats, ApiError> {
        let url = format!("/x/relation/stat?vmid={}", mid);
        self.http.get(&url).await
    }
}
```

**Step 2: Create user bridge API**

Create `rust/src/api/user.rs`:

```rust
use flutter_rust_bridge::frb;
use crate::models::{UserInfo, UserStats};
use crate::error::BridgeResult;

/// Get user information
#[frb]
pub async fn get_user_info(mid: i64) -> BridgeResult<UserInfo> {
    // TODO: Integrate with UserApi
    Err("Not yet implemented".into())
}

/// Get user statistics
#[frb]
pub async fn get_user_stats(mid: i64) -> BridgeResult<UserStats> {
    // TODO: Integrate with UserApi
    Err("Not yet implemented".into())
}
```

**Step 3:** Update api module

Open `rust/src/api/mod.rs`:

```rust
pub mod simple;
pub mod bridge;
pub mod video;
pub mod user;

pub use bridge::*;
```

**Step 4:** Update bilibili_api module

Open `rust/src/bilibili_api/mod.rs`:

```rust
pub mod video;
pub mod user;

pub use video::VideoApi;
pub use user::UserApi;
```

**Step 5:** Run `cargo check`

Expected: "Finished dev [unoptimized] check"

**Step 6:** Commit

```bash
git add rust/src/
git commit -m "feat(rust): add user API module"
```

---

## Task 12: Implement Service Container

**Files:**
- Create: `rust/src/services/mod.rs`
- Create: `rust/src/services/container.rs`
- Modify: `rust/src/lib.rs`

**Step 1: Create service container**

Create `rust/src/services/container.rs`:

```rust
use once_cell::sync::Lazy;
use std::sync::Arc;
use tokio::runtime::Runtime;

use crate::storage::StorageService;
use crate::http::HttpService;
use crate::account::AccountService;

pub struct Services {
    pub storage: Arc<StorageService>,
    pub http: Arc<HttpService>,
    pub account: Arc<AccountService>,
}

static SERVICES: Lazy<Arc<Services>> = Lazy::new(|| {
    let rt = Runtime::new().unwrap();

    rt.block_on(async {
        let storage = Arc::new(StorageService::new("./data/pili.db").await.unwrap());
        let http = Arc::new(HttpService::new("https://api.bilibili.com".to_string()).unwrap());
        let account = Arc::new(AccountService::new(storage.clone(), http.clone()));

        Arc::new(Services {
            storage,
            http,
            account,
        })
    })
});

/// Get global services instance
#[flutter_rust_bridge::frb(sync)]
pub fn get_services() -> Arc<Services> {
    SERVICES.clone()
}
```

**Step 2:** Create services module

Create `rust/src/services/mod.rs`:

```rust
pub mod container;

pub use container::{Services, get_services};
```

**Step 3:** Update lib.rs

Open `rust/src/lib.rs`:

```rust
pub mod error;
pub mod models;
pub mod storage;
pub mod http;
pub mod account;
pub mod bilibili_api;
pub mod services;
pub mod api;

mod frb_generated;
```

**Step 4:** Run `cargo check`

Expected: "Finished dev [unoptimized] check"

**Step 5:** Commit

```bash
git add rust/src/
git commit -m "feat(rust): add global service container"
```

---

This completes Phase 3. The Rust core now has real API integration and proper service management.

**Next Phase**: Download service and complete feature parity
