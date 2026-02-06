pub mod client;
pub mod service;

pub use service::HttpService;
pub use client::HttpClient;

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::Account;

    #[tokio::test]
    async fn test_http_client_creation() {
        let client = HttpClient::new("https://api.bilibili.com".to_string());
        assert!(client.is_ok());
    }

    #[tokio::test]
    async fn test_http_service_creation() {
        let service = HttpService::new("https://api.bilibili.com".to_string());
        assert!(service.is_ok());
    }

    #[tokio::test]
    async fn test_http_service_account_management() {
        let service = HttpService::new("https://api.bilibili.com".to_string()).unwrap();

        let account = Account {
            id: "test_id".to_string(),
            name: "test_user".to_string(),
            avatar: "test_avatar".to_string(),
            cookies: std::collections::HashMap::new(),
            auth_tokens: crate::models::AuthTokens {
                access_token: Some("token".to_string()),
                refresh_token: Some("refresh".to_string()),
                expires_at: Some(9999999999),
            },
            is_logged_in: true,
        };

        service.set_account(account.clone()).await;
        let current = service.get_current_account().await;
        assert_eq!(current, Some(account));
    }

    #[tokio::test]
    async fn test_http_service_clear_account() {
        let service = HttpService::new("https://api.bilibili.com".to_string()).unwrap();

        let account = Account {
            id: "test_id".to_string(),
            name: "test_user".to_string(),
            avatar: "test_avatar".to_string(),
            cookies: std::collections::HashMap::new(),
            auth_tokens: crate::models::AuthTokens {
                access_token: Some("token".to_string()),
                refresh_token: Some("refresh".to_string()),
                expires_at: Some(9999999999),
            },
            is_logged_in: true,
        };

        service.set_account(account).await;
        service.clear_account().await;
        let current = service.get_current_account().await;
        assert_eq!(current, None);
    }

    #[tokio::test]
    async fn test_unauthorized_request() {
        let service = HttpService::new("https://api.biligame.com".to_string()).unwrap();

        // This should fail since no account is set
        let result = service.get_with_auth::<serde_json::Value>("/test").await;
        assert!(matches!(result, Err(crate::error::ApiError::Unauthorized)));
    }
}