use flutter_rust_bridge::frb;
use crate::models::{UserInfo, UserStats};
use crate::error::{SerializableError, ApiError};
use crate::services::get_services;

/// Get current user information (uses auth cookie from HTTP client)
#[frb]
pub async fn get_user_info() -> Result<UserInfo, SerializableError> {
    let services = get_services().await;

    // Call Bilibili API with current user's auth
    match services.user_api.get_user_info(0).await {
        Ok(user) => Ok(user),
        Err(ApiError::NetworkUnavailable) => Err(SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: "Network unavailable".to_string(),
        }),
        Err(err) => Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: err.to_string(),
        }),
    }
}

/// Get current user statistics (uses auth cookie from HTTP client)
#[frb]
pub async fn get_user_stats() -> Result<UserStats, SerializableError> {
    let services = get_services().await;

    match services.user_api.get_user_stats(0).await {
        Ok(stats) => Ok(stats),
        Err(ApiError::NetworkUnavailable) => Err(SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: "Network unavailable".to_string(),
        }),
        Err(err) => Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: err.to_string(),
        }),
    }
}
