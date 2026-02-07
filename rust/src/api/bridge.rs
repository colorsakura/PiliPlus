use crate::models::*;
use flutter_rust_bridge::frb;

/// Initialize the Rust core
#[frb(sync)]
pub fn init_core() {
    // Initialize logging with proper formatter to show logs
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_target(false) // Don't show module path
        .with_thread_ids(false) // Don't show thread IDs
        .with_file(false) // Don't show file path
        .with_line_number(false) // Don't show line number
        .compact() // Use compact format for single-line logs
        .init();

    tracing::info!("PiliPlus Rust core initialized");
}

/// Get version information
#[frb(sync)]
pub fn get_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// Health check
#[frb(sync)]
pub fn health_check() -> bool {
    true
}

// Type registration - these functions exist solely to expose types to flutter_rust_bridge
// The actual functions are in other modules

/// Expose VideoInfo type to bridge
#[frb]
pub async fn _expose_video_info_type() -> VideoInfo {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose VideoUrl type to bridge
#[frb]
pub async fn _expose_video_url_type() -> VideoUrl {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose VideoOwner type to bridge
#[frb]
pub async fn _expose_video_owner_type() -> VideoOwner {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose VideoStats type to bridge
#[frb]
pub async fn _expose_video_stats_type() -> VideoStats {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose VideoPage type to bridge
#[frb]
pub async fn _expose_video_page_type() -> VideoPage {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose VideoSegment type to bridge
#[frb]
pub async fn _expose_video_segment_type() -> VideoSegment {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose Image type to bridge
#[frb]
pub async fn _expose_image_type() -> Image {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose Account type to bridge
#[frb]
pub async fn _expose_account_type() -> Account {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose DynamicsList type to bridge
#[frb]
pub async fn _expose_dynamics_list_type() -> DynamicsList {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose DynamicsItem type to bridge
#[frb]
pub async fn _expose_dynamics_item_type() -> DynamicsItem {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose LiveRoomInfo type to bridge
#[frb]
pub async fn _expose_live_room_info_type() -> LiveRoomInfo {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose LivePlayUrl type to bridge
#[frb]
pub async fn _expose_live_play_url_type() -> LivePlayUrl {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose CommentList type to bridge
#[frb]
pub async fn _expose_comment_list_type() -> CommentList {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose SearchResults type to bridge
#[frb]
pub async fn _expose_search_results_type() -> SearchResults {
    panic!("This function should never be called - it only exists for type registration");
}

/// Expose SearchResult type to bridge
#[frb]
pub async fn _expose_search_result_type() -> SearchResult {
    panic!("This function should never be called - it only exists for type registration");
}

// Recommendation API wrapper for flutter_rust_bridge
#[frb]
pub async fn get_recommend_list(
    ps: i32,
    fresh_idx: i32,
) -> Result<Vec<crate::models::rcmd::RcmdVideoInfo>, crate::error::SerializableError> {
    crate::api::rcmd::get_recommend_list(ps, fresh_idx).await
}

// App Recommendation API wrapper for flutter_rust_bridge
#[frb]
pub async fn get_recommend_list_app(
    ps: i32,
    fresh_idx: i32,
) -> Result<Vec<crate::models::rcmd::RcmdVideoInfo>, crate::error::SerializableError> {
    crate::api::rcmd_app::get_recommend_list_app(ps, fresh_idx).await
}

// User API wrapper for flutter_rust_bridge
#[frb]
pub async fn get_user_info() -> Result<crate::models::UserInfo, crate::error::SerializableError> {
    crate::api::user::get_user_info().await
}

#[frb]
pub async fn get_user_stats() -> Result<crate::models::UserStats, crate::error::SerializableError> {
    crate::api::user::get_user_stats().await
}

// Video API wrapper for flutter_rust_bridge
#[frb]
pub async fn get_video_info(
    bvid: String,
) -> Result<crate::models::VideoInfo, crate::error::SerializableError> {
    crate::api::video::get_video_info(bvid).await
}

#[frb]
pub async fn get_video_url(
    bvid: String,
    cid: i64,
    quality: crate::models::VideoQuality,
) -> Result<crate::models::VideoUrl, crate::error::SerializableError> {
    crate::api::video::get_video_url(bvid, cid, quality).await
}

// Search API wrapper for flutter_rust_bridge
#[frb]
pub async fn search_videos(
    keyword: String,
    page: i32,
    order: Option<String>,
    duration: Option<i32>,
    tids: Option<i32>,
) -> Result<crate::models::SearchVideoResult, crate::error::SerializableError> {
    crate::api::search::search_videos(keyword, page, order, duration, tids).await
}

// Re-export API functions for use by Dart
pub use crate::api::account::*;
pub use crate::api::comments::*;
pub use crate::api::dynamics::*;
pub use crate::api::live::*;
pub use crate::api::search::*;
pub use crate::api::user::*;
pub use crate::api::video::*;
// download module not yet implemented - requires DownloadTask model
// pub use crate::api::download::*;
