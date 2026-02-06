use flutter_rust_bridge::frb;
use crate::models::{VideoInfo, VideoUrl, VideoQuality};
use crate::error::BridgeResult;
use crate::services::get_services;
use crate::bilibili_api::VideoApi;

/// Get video information from Bilibili API
#[frb]
pub async fn get_video_info(bvid: String) -> BridgeResult<VideoInfo> {
    let services = get_services();

    // Use real VideoApi to fetch data
    services.video_api.get_video_info(&bvid).await
        .map_err(|e| e.into())
}

/// Get video playback URL from Bilibili API
#[frb]
pub async fn get_video_url(bvid: String, cid: i64, quality: VideoQuality) -> BridgeResult<VideoUrl> {
    let services = get_services();

    services.video_api.get_video_url(&bvid, cid, quality).await
        .map_err(|e| e.into())
}