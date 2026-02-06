use flutter_rust_bridge::frb;
use crate::models::CommentList;
use crate::error::BridgeResult;
use crate::services::get_services;

#[frb]
pub async fn get_video_comments(oid: i64, page: u32, page_size: u32) -> BridgeResult<CommentList> {
    let services = get_services();

    // TODO: Add CommentsApi to service container
    Ok(CommentList {
        comments: vec![],
        page,
        page_size,
        total_count: 0,
    })
}
