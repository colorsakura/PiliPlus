use std::sync::Arc;
use tokio::sync::RwLock;
use crate::models::Account;
use crate::http::HttpService;
use crate::storage::StorageService;

/// Account service for managing user authentication and account switching
pub struct AccountService {
    storage: Arc<StorageService>,
    http: Arc<HttpService>,
    current_account: Arc<RwLock<Option<Account>>>,
}

impl AccountService {
    pub fn new(storage: Arc<StorageService>, http: Arc<HttpService>) -> Self {
        Self {
            storage,
            http,
            current_account: Arc::new(RwLock::new(None)),
        }
    }

    /// Get current logged-in account
    pub async fn current_account(&self) -> Option<Account> {
        self.current_account.read().await.clone()
    }

    /// Set current account
    pub async fn set_account(&self, account: Account) {
        let mut current = self.current_account.write().await;
        *current = Some(account);
    }

    /// Clear current account (logout)
    pub async fn clear_account(&self) {
        let mut current = self.current_account.write().await;
        *current = None;
    }

    /// Switch to a different account
    pub async fn switch_account(&self, account_id: &str) -> Result<(), crate::error::ApiError> {
        // Find account in storage
        let account = self.storage.load_account(account_id).await
            .map_err(|e| crate::error::ApiError::ApiError {
                code: 500,
                message: e.to_string(),
            })?;

        // Set as current
        self.set_account(account).await;

        Ok(())
    }

    /// Get all accounts from storage
    pub async fn all_accounts(&self) -> Result<Vec<Account>, crate::error::ApiError> {
        self.storage.all_accounts().await
            .map_err(|e| crate::error::ApiError::ApiError {
                code: 500,
                message: e.to_string(),
            })
    }

    /// Save account to storage
    pub async fn save_account(&self, account: Account) -> Result<(), crate::error::ApiError> {
        self.storage.save_account(&account).await
            .map_err(|e| crate::error::ApiError::ApiError {
                code: 500,
                message: e.to_string(),
            })
    }

    /// Delete account from storage
    pub async fn delete_account(&self, account_id: &str) -> Result<(), crate::error::ApiError> {
        self.storage.delete_account(account_id).await
            .map_err(|e| crate::error::ApiError::ApiError {
                code: 500,
                message: e.to_string(),
            })
    }

    /// Get current account ID
    pub async fn current_account_id(&self) -> Option<String> {
        self.current_account.read().await.as_ref().map(|a| a.id.clone())
    }
}
