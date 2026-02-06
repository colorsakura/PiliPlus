use flutter_rust_bridge::frb;
use crate::models::SearchResults;
use crate::error::BridgeResult;
use crate::services::get_services;

/// Search for videos on Bilibili
#[frb]
pub async fn search_videos(keyword: String, page: u32, page_size: u32) -> BridgeResult<SearchResults> {
    let services = get_services();

    // TODO: Add SearchApi to service container
    Ok(SearchResults {
        items: vec![],
        page,
        page_size,
        total_count: 0,
    })
}
