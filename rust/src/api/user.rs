use flutter_rust_bridge::frb;
use crate::models::{UserInfo, UserStats};
use crate::error::{BridgeResult, SerializableError};


/// Get user information
#[frb]
pub async fn get_user_info(_mid: i64) -> BridgeResult<UserInfo> {
    // TODO: Integrate with UserApi
    Err(SerializableError {
        code: "NOT_IMPLEMENTED".to_string(),
        message: "Not yet implemented".to_string(),
    })
}

/// Get user statistics
#[frb]
pub async fn get_user_stats(_mid: i64) -> BridgeResult<UserStats> {
    // TODO: Integrate with UserApi
    Err(SerializableError {
        code: "NOT_IMPLEMENTED".to_string(),
        message: "Not yet implemented".to_string(),
    })
}