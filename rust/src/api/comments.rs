use flutter_rust_bridge::frb;
use crate::models::CommentList;
use crate::error::ApiResult;
use crate::services::get_services;

/// Get video comments
#[frb]
pub async fn get_video_comments(oid: i64, page: u32, page_size: u32) -> ApiResult<CommentList> {
    let _services = get_services().await;

    // TODO: Add CommentsApi to service container
    ApiResult {
        success: true,
        data: Some(CommentList {
            comments: vec![],
            page,
            page_size,
            total_count: 0,
        }),
        error: None,
    }
}
