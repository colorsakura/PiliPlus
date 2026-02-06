use flutter_rust_bridge::frb;
use crate::models::{VideoInfo, VideoUrl, VideoQuality};
use crate::error::BridgeResult;
use crate::services::get_services;

/// Get video information from Bilibili API
#[frb]
pub async fn get_video_info(bvid: String) -> BridgeResult<VideoInfo> {
    let services = get_services();

    // TODO: Integrate with bilibili_api::VideoApi
    // For now, return improved mock data
    let mock_info = VideoInfo {
        bvid: bvid.clone(),
        aid: 123456,
        title: format!("Video {}", bvid),
        description: "Mock video from Rust API with service integration".to_string(),
        owner: crate::models::VideoOwner {
            mid: 789,
            name: "Mock User".to_string(),
            face: crate::models::Image {
                url: "https://test.com/avatar.jpg".to_string(),
                width: Some(100),
                height: Some(100),
            },
        },
        pic: crate::models::Image {
            url: "https://test.com/cover.jpg".to_string(),
            width: Some(1280),
            height: Some(720),
        },
        duration: 600,
        stats: crate::models::VideoStats {
            view_count: 10000,
            like_count: 500,
            coin_count: 100,
            collect_count: 50,
        },
        cid: 456789,
        pages: vec![],
    };

    Ok(mock_info)
}

/// Get video playback URL from Bilibili API
#[frb]
pub async fn get_video_url(bvid: String, cid: i64, quality: VideoQuality) -> BridgeResult<VideoUrl> {
    let _services = get_services();

    // TODO: Use VideoApi to fetch real playback URL
    Ok(VideoUrl {
        quality,
        format: crate::models::VideoFormat::Dash,
        segments: vec![],
    })
}