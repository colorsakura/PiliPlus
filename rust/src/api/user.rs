use flutter_rust_bridge::frb;
use crate::models::{UserInfo, UserStats};
use crate::error::BridgeResult;
use crate::services::get_services;


/// Get user information
#[frb]
pub async fn get_user_info(mid: i64) -> BridgeResult<UserInfo> {
    let services = get_services();

    services.user_api.get_user_info(mid).await
        .map_err(|e| e.into())
}

/// Get user statistics
#[frb]
pub async fn get_user_stats(mid: i64) -> BridgeResult<UserStats> {
    let services = get_services();

    services.user_api.get_user_stats(mid).await
        .map_err(|e| e.into())
}