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
        let row = sqlx::query(
            "SELECT id, name, avatar, cookies_json, auth_tokens_json, is_logged_in, created_at, updated_at
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
                };
                account.into_account()
            }
            None => Err(StorageError::AccountNotFound(id.to_string())),
        }
    }

    pub async fn all_accounts(&self) -> Result<Vec<Account>, StorageError> {
        let rows = sqlx::query(
            "SELECT id, name, avatar, cookies_json, auth_tokens_json, is_logged_in, created_at, updated_at
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