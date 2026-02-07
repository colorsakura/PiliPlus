use crate::account::login::QrLoginFlow;
use crate::error::AccountError;
use crate::http::HttpService;
use crate::models::Account;
use crate::storage::StorageService;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};

pub struct AccountService {
    current_account: Arc<RwLock<Option<Account>>>,
    storage: Arc<StorageService>,
    http: Arc<HttpService>,
    account_change_tx: broadcast::Sender<Account>,
}

impl AccountService {
    pub fn new(storage: Arc<StorageService>, http: Arc<HttpService>) -> Self {
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
        let account = self
            .storage
            .load_account(account_id)
            .await
            .map_err(|_| AccountError::AccountNotFound(account_id.to_string()))?;

        self.set_current_account(account).await;
        Ok(())
    }

    pub fn qr_login_flow(&self) -> QrLoginFlow {
        QrLoginFlow::new(self.http.clone())
    }
}
