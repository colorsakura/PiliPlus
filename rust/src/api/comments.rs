use flutter_rust_bridge::frb;
use crate::models::CommentList;
use crate::error::{SerializableError, ApiError};
use crate::services::get_services;

/// Get video comments
#[frb]
pub async fn get_video_comments(_oid: i64, _page: u32, _page_size: u32) -> Result<CommentList, SerializableError> {
    let _services = get_services().await;

    // TODO: Add CommentsApi to service container
    Err(SerializableError {
        code: "NOT_IMPLEMENTED".to_string(),
        message: "Comments API not yet implemented".to_string(),
    })
}
