use crate::error::StorageError;
use crate::models::Account;
use chrono::Utc;
use sqlx::{Row, SqlitePool};

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

    /// Create an in-memory storage service (for testing or download service)
    pub fn in_memory() -> Result<Self, StorageError> {
        // For download service, we don't need persistent storage
        // Use a simple in-memory implementation
        let pool = SqlitePool::connect_lazy(":memory:")?;

        Ok(Self { db: pool })
    }

    // Account operations
    pub async fn save_account(&self, account: &Account) -> Result<(), StorageError> {
        let cookies_json = serde_json::to_string(&account.cookies)?;
        let tokens_json = serde_json::to_string(&account.auth_tokens)?;
        let now = Utc::now().to_rfc3339();

        sqlx::query(
            r#"
            INSERT INTO accounts (id, name, avatar, cookies_json, auth_tokens_json, is_logged_in, created_at, updated_at, last_used)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                name = excluded.name,
                avatar = excluded.avatar,
                cookies_json = excluded.cookies_json,
                auth_tokens_json = excluded.auth_tokens_json,
                is_logged_in = excluded.is_logged_in,
                updated_at = excluded.updated_at,
                last_used = excluded.last_used
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
        .bind(&account.last_used)
        .execute(&self.db)
        .await?;

        Ok(())
    }

    pub async fn load_account(&self, id: &str) -> Result<Account, StorageError> {
        let row = sqlx::query(
            "SELECT id, name, avatar, cookies_json, auth_tokens_json, is_logged_in, created_at, updated_at, last_used
             FROM accounts WHERE id = ?"
        )
        .bind(id)
        .fetch_optional(&self.db)
        .await?;

        match row {
            Some(row) => {
                let account = AccountRow {
                    id: row.get("id"),
                    name: row.get("name"),
                    avatar: row.get("avatar"),
                    cookies_json: row.get("cookies_json"),
                    auth_tokens_json: row.get("auth_tokens_json"),
                    is_logged_in: row.get("is_logged_in"),
                    created_at: row.get("created_at"),
                    updated_at: row.get("updated_at"),
                    last_used: row.get("last_used"),
                };
                account.into_account()
            }
            None => Err(StorageError::AccountNotFound(id.to_string())),
        }
    }

    pub async fn all_accounts(&self) -> Result<Vec<Account>, StorageError> {
        let rows = sqlx::query(
            "SELECT id, name, avatar, cookies_json, auth_tokens_json, is_logged_in, created_at, updated_at, last_used
             FROM accounts ORDER BY updated_at DESC"
        )
        .fetch_all(&self.db)
        .await?;

        let mut accounts = Vec::new();
        for row in rows {
            let account_row = AccountRow {
                id: row.get("id"),
                name: row.get("name"),
                avatar: row.get("avatar"),
                cookies_json: row.get("cookies_json"),
                auth_tokens_json: row.get("auth_tokens_json"),
                is_logged_in: row.get("is_logged_in"),
                created_at: row.get("created_at"),
                updated_at: row.get("updated_at"),
                last_used: row.get("last_used"),
            };
            accounts.push(account_row.into_account()?);
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

    pub async fn get_last_used_account(&self) -> Result<Option<String>, StorageError> {
        let row = sqlx::query("SELECT value_json FROM settings WHERE key = 'last_used_account_id'")
            .fetch_optional(&self.db)
            .await?;

        match row {
            Some(r) => {
                let json: String = r.get("value_json");
                let value: String = serde_json::from_str(&json)?;
                Ok(Some(value))
            }
            None => Ok(None),
        }
    }

    pub async fn set_last_used_account(&self, account_id: &str) -> Result<(), StorageError> {
        let json = serde_json::to_string(account_id)?;
        let now = Utc::now().to_rfc3339();

        sqlx::query(
            "INSERT INTO settings (key, value_json, updated_at) VALUES ('last_used_account_id', ?, ?)
             ON CONFLICT(key) DO UPDATE SET value_json = excluded.value_json, updated_at = excluded.updated_at"
        )
        .bind(&json)
        .bind(&now)
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
    last_used: i64,
}

impl AccountRow {
    fn into_account(self) -> Result<Account, StorageError> {
        // Parse created_at timestamp
        let created_at = self
            .created_at
            .parse::<chrono::DateTime<chrono::Utc>>()
            .map(|dt| dt.timestamp())
            .map_err(|_| {
                StorageError::DatabaseError(sqlx::Error::Decode(Box::new(
                    std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("Invalid created_at format: {}", self.created_at)
                    )
                )))
            })?;

        Ok(Account {
            id: self.id,
            name: self.name,
            avatar: self.avatar,
            cookies: serde_json::from_str(&self.cookies_json)?,
            auth_tokens: serde_json::from_str(&self.auth_tokens_json)?,
            is_logged_in: self.is_logged_in,
            created_at,
            last_used: self.last_used,
        })
    }
}
