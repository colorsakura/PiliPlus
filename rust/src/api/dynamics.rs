use flutter_rust_bridge::frb;
use crate::models::{DynamicsList, DynamicsItem};
use crate::error::{SerializableError, ApiError};
use crate::services::get_services;

/// Get user dynamics/posts from Bilibili API
#[frb]
pub async fn get_user_dynamics(_uid: i64, _offset: Option<String>) -> Result<DynamicsList, SerializableError> {
    let _services = get_services().await;

    // TODO: Add DynamicsApi to service container
    Err(SerializableError {
        code: "NOT_IMPLEMENTED".to_string(),
        message: "Dynamics API not yet implemented".to_string(),
    })
}

/// Get dynamics detail by ID from Bilibili API
#[frb]
pub async fn get_dynamics_detail(_dynamic_id: String) -> Result<DynamicsItem, SerializableError> {
    let _services = get_services().await;

    // TODO: Add DynamicsApi to service container
    Err(SerializableError {
        code: "NOT_IMPLEMENTED".to_string(),
        message: "Dynamics detail API not yet implemented".to_string(),
    })
}
