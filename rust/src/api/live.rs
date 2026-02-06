use flutter_rust_bridge::frb;
use crate::models::{LiveRoomInfo, LivePlayUrl};
use crate::error::{SerializableError, ApiError};
use crate::services::get_services;

/// Get live room information
#[frb]
pub async fn get_live_room_info(_room_id: i64) -> Result<LiveRoomInfo, SerializableError> {
    let _services = get_services().await;

    // TODO: Add LiveApi to service container
    Err(SerializableError {
        code: "NOT_IMPLEMENTED".to_string(),
        message: "Live room info API not yet implemented".to_string(),
    })
}

/// Get live stream play URLs
#[frb]
pub async fn get_live_play_url(_room_id: i64, _quality: i32) -> Result<LivePlayUrl, SerializableError> {
    let _services = get_services().await;

    // TODO: Add LiveApi to service container
    Err(SerializableError {
        code: "NOT_IMPLEMENTED".to_string(),
        message: "Live play URL API not yet implemented".to_string(),
    })
}
