use flutter_rust_bridge::frb;
use crate::models::*;

/// Initialize the Rust core
#[frb(sync)]
pub fn init_core() {
    // Initialize logging
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
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

// Temporarily disabled - User API has codegen issues
// /// Expose UserInfo type to bridge
// #[frb]
// pub async fn _expose_user_info_type() -> UserInfo {
//     panic!("This function should never be called - it only exists for type registration");
// }
//
// /// Expose UserStats type to bridge
// #[frb]
// pub async fn _expose_user_stats_type() -> UserStats {
//     panic!("This function should never be called - it only exists for type registration");
// }

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

// Re-export API functions for use by Dart
pub use crate::api::video::*;
pub use crate::api::account::*;
// All other APIs temporarily disabled due to flutter_rust_bridge codegen issues
// pub use crate::api::user::*;
// pub use crate::api::comments::*;
// pub use crate::api::dynamics::*;
// pub use crate::api::live::*;
// pub use crate::api::search::*;