use flutter_rust_bridge::frb;
use crate::models::{DynamicsList, DynamicsItem};
use crate::error::{BridgeResult, ApiError};

/// Get user dynamics/posts from Bilibili API
#[frb]
pub async fn get_user_dynamics(_uid: i64, _offset: Option<String>) -> BridgeResult<DynamicsList> {
    // TODO: Add DynamicsApi to service container
    // For now, return mock data
    Ok(DynamicsList {
        items: vec![],
        has_more: false,
        offset: None,
    })
}

/// Get dynamics detail by ID from Bilibili API
#[frb]
pub async fn get_dynamics_detail(_dynamic_id: String) -> BridgeResult<DynamicsItem> {
    // TODO: Add DynamicsApi to service container
    Err(ApiError::ApiError {
        code: -1,
        message: "Not yet implemented".to_string(),
    }.into())
}
