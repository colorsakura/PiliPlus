#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::account::AuthTokens;
    use std::collections::HashMap;

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