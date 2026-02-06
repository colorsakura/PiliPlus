use flutter_rust_bridge::frb;
use crate::models::{VideoInfo, VideoUrl, VideoQuality};
use crate::error::BridgeResult;

/// Get video information
#[frb]
pub async fn get_video_info(bvid: String) -> BridgeResult<VideoInfo> {
    // TODO: Implement actual API call
    // For now, return mock data
    let mock_info = VideoInfo {
        bvid: bvid.clone(),
        aid: 123456,
        title: "Test Video".to_string(),
        description: "Test Description".to_string(),
        owner: crate::models::VideoOwner {
            mid: 789,
            name: "Test User".to_string(),
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

/// Get video playback URL
#[frb]
pub async fn get_video_url(_bvid: String, _cid: i64, quality: VideoQuality) -> BridgeResult<VideoUrl> {
    // TODO: Implement actual API call
    Ok(VideoUrl {
        quality,
        format: crate::models::VideoFormat::Dash,
        segments: vec![],
    })
}