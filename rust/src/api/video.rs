use flutter_rust_bridge::frb;
use crate::models::{VideoInfo, VideoUrl, VideoQuality};
use crate::error::{SerializableError, ApiError};
use crate::services::get_services;
use crate::bilibili_api::VideoApi;

/// Get video information from Bilibili API
#[frb]
pub async fn get_video_info(bvid: String) -> Result<VideoInfo, SerializableError> {
    let services = get_services().await;

    // Use real VideoApi to fetch data
    match services.video_api.get_video_info(&bvid).await {
        Ok(video) => Ok(video),
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

/// Get video playback URL from Bilibili API
#[frb]
pub async fn get_video_url(bvid: String, cid: i64, quality: VideoQuality) -> Result<VideoUrl, SerializableError> {
    let services = get_services().await;

    match services.video_api.get_video_url(&bvid, cid, quality).await {
        Ok(url) => Ok(url),
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