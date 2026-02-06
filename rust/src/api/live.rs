use flutter_rust_bridge::frb;
use crate::models::{LiveRoomInfo, LivePlayUrl};
use crate::error::{BridgeResult, ApiError};

/// Get live room information from Bilibili API
#[frb]
pub async fn get_live_room_info(room_id: i64) -> BridgeResult<LiveRoomInfo> {
    // TODO: Add LiveApi to service container
    // For now, return mock data
    Ok(LiveRoomInfo {
        room_id,
        uid: 123456,
        title: "Test Live".to_string(),
        description: "Test Description".to_string(),
        cover: crate::models::Image {
            url: "https://test.com/cover.jpg".to_string(),
            width: Some(1280),
            height: Some(720),
        },
        status: crate::models::LiveStatus::Live,
        online_count: 1000,
        area_name: "Gaming".to_string(),
    })
}

/// Get live playback URL from Bilibili API
#[frb]
pub async fn get_live_play_url(room_id: i64) -> BridgeResult<LivePlayUrl> {
    // TODO: Add LiveApi to service container
    Err(ApiError::ApiError {
        code: -1,
        message: "Not yet implemented".to_string(),
    }.into())
}
