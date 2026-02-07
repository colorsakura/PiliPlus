use crate::error::AccountError;
use crate::http::HttpService;
use crate::models::{Account, CookieJar};
use crate::storage::StorageService;
use reqwest::header::HeaderValue;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tokio::sync::{RwLock, broadcast};
use tracing::warn;

#[derive(Clone, Serialize, Deserialize, Debug)]
pub enum AccountChange {
    Added(Account),
    Switched(Account),
    Removed(String),
}

/// Account service for managing user authentication and account switching
pub struct AccountService {
    storage: Arc<StorageService>,
    http: Arc<HttpService>,
    current_account: Arc<RwLock<Option<Account>>>,
    all_accounts: Arc<RwLock<Vec<Account>>>,
    cookie_jar: Arc<RwLock<CookieJar>>,
    change_tx: broadcast::Sender<AccountChange>,
}

impl AccountService {
    pub fn new(storage: Arc<StorageService>, http: Arc<HttpService>) -> Self {
        let (change_tx, _) = broadcast::channel(100);

        Self {
            storage,
            http,
            current_account: Arc::new(RwLock::new(None)),
            all_accounts: Arc::new(RwLock::new(Vec::new())),
            cookie_jar: Arc::new(RwLock::new(CookieJar::new())),
            change_tx,
        }
    }

    /// Initialize the account service by loading all accounts from storage
    pub async fn initialize(&self) -> Result<(), AccountError> {
        let accounts = self
            .storage
            .all_accounts()
            .await
            .map_err(|e| AccountError::StorageError(e.to_string()))?;
        *self.all_accounts.write().await = accounts;

        if let Ok(Some(last_id)) = self
            .storage
            .get_last_used_account()
            .await
            .map_err(|e| AccountError::StorageError(e.to_string()))
        {
            for acc in self.all_accounts.read().await.iter() {
                if acc.id == last_id {
                    *self.current_account.write().await = Some(acc.clone());
                    break;
                }
            }
        }
        Ok(())
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
    pub async fn switch_account(&self, account_id: &str) -> Result<(), AccountError> {
        // Find account in storage
        let account = self
            .storage
            .load_account(account_id)
            .await
            .map_err(|e| AccountError::StorageError(e.to_string()))?;

        // Update last_used timestamp
        let mut updated_account = account.clone();
        updated_account.last_used = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map(|d| d.as_secs() as i64)
            .unwrap_or_else(|e| {
                warn!("Failed to get system time: {}", e);
                0
            });

        // Save updated account
        self.storage
            .save_account(&updated_account)
            .await
            .map_err(|e| AccountError::StorageError(e.to_string()))?;

        // Set as current
        self.set_account(updated_account.clone()).await;

        // Update last used account in settings
        self.storage
            .set_last_used_account(account_id)
            .await
            .map_err(|e| AccountError::StorageError(e.to_string()))?;

        // Send change event
        let _ = self
            .change_tx
            .send(AccountChange::Switched(updated_account));

        Ok(())
    }

    /// Get all accounts from storage
    pub async fn all_accounts(&self) -> Result<Vec<Account>, AccountError> {
        Ok(self.all_accounts.read().await.clone())
    }

    /// Add a new account
    pub async fn add_account(&self, account: Account) -> Result<(), AccountError> {
        // Save to storage
        self.storage
            .save_account(&account)
            .await
            .map_err(|e| AccountError::StorageError(e.to_string()))?;

        // Add to in-memory list
        let mut accounts = self.all_accounts.write().await;
        accounts.push(account.clone());

        // Send change event
        let _ = self.change_tx.send(AccountChange::Added(account));

        Ok(())
    }

    /// Remove an account
    pub async fn remove_account(&self, account_id: &str) -> Result<(), AccountError> {
        // Delete from storage
        self.storage
            .delete_account(account_id)
            .await
            .map_err(|e| AccountError::StorageError(e.to_string()))?;

        // Remove from in-memory list
        let mut accounts = self.all_accounts.write().await;
        accounts.retain(|a| a.id != account_id);

        // Clear current account if it was the removed one
        let mut current = self.current_account.write().await;
        if let Some(acc) = current.as_ref() {
            if acc.id == account_id {
                *current = None;
            }
        }

        // Send change event
        let _ = self
            .change_tx
            .send(AccountChange::Removed(account_id.to_string()));

        Ok(())
    }

    /// Get current account ID
    pub async fn current_account_id(&self) -> Option<String> {
        self.current_account
            .read()
            .await
            .as_ref()
            .map(|a| a.id.clone())
    }

    /// Inject cookies from current account into HTTP request
    pub async fn inject_cookies(&self, request: &mut reqwest::Request) -> Result<(), AccountError> {
        if let Some(account) = self.current_account.read().await.as_ref() {
            let header = account
                .cookies
                .iter()
                .map(|(k, v)| format!("{}={}", k, v))
                .collect::<Vec<_>>()
                .join("; ");
            let header_value = HeaderValue::from_str(&header)
                .map_err(|e| AccountError::InvalidCookie(e.to_string()))?;
            request
                .headers_mut()
                .insert("Cookie", header_value);
        }
        Ok(())
    }

    /// Subscribe to account change events
    pub fn account_changes(&self) -> broadcast::Receiver<AccountChange> {
        self.change_tx.subscribe()
    }
}
