use flutter_rust_bridge::frb;
use crate::models::{UserInfo, UserStats};
use crate::error::BridgeResult;
use crate::services::get_services;


/// Get user information
#[frb]
pub async fn get_user_info(mid: i64) -> BridgeResult<UserInfo> {
    let services = get_services();

    // TODO: Use account service to get current user info
    // For now, return mock data
    Ok(UserInfo {
        mid,
        name: "Test User".to_string(),
        face: crate::models::Image {
            url: "https://test.com/avatar.jpg".to_string(),
            width: Some(100),
            height: Some(100),
        },
        level_info: crate::models::UserLevel {
            current_level: 6,
        },
        vip_status: crate::models::VipStatus {
            status: 1,
            vip_type: 1,
        },
        money: crate::models::CoinBalance {
            coins: 100,
        },
    })
}

/// Get user statistics
#[frb]
pub async fn get_user_stats(mid: i64) -> BridgeResult<UserStats> {
    let _services = get_services();

    // TODO: Use HTTP service to fetch real stats
    Ok(UserStats {
        following: 50,
        follower: 100,
    })
}