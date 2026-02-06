use std::sync::Arc;
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

    pub async fn clear_account(&self) {
        *self.account.write().await = None;
    }

    pub async fn get_current_account(&self) -> Option<Account> {
        self.account.read().await.clone()
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
        let account = self.account.read().await;
        if let Some(acc) = account.as_ref() {
            self.client.get_with_auth(path, &acc.cookie_header()).await
        } else {
            Err(ApiError::Unauthorized)
        }
    }

    pub async fn post<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        body: serde_json::Value,
    ) -> Result<T, ApiError> {
        self.client.post(path, body).await
    }

    pub async fn post_with_auth<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        body: serde_json::Value,
    ) -> Result<T, ApiError> {
        let account = self.account.read().await;
        if let Some(acc) = account.as_ref() {
            self.client.post_with_auth(path, body, &acc.cookie_header()).await
        } else {
            Err(ApiError::Unauthorized)
        }
    }
}