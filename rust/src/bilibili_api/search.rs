use crate::models::SearchResults;
use crate::http::HttpService;
use crate::error::ApiError;

pub struct SearchApi {
    http: std::sync::Arc<HttpService>,
}

impl SearchApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn search_videos(
        &self,
        keyword: &str,
        page: u32,
        page_size: u32,
    ) -> Result<SearchResults, ApiError> {
        let url = format!(
            "/x/web-interface/search/type?search_type=video&keyword={}&page={}",
            urlencoding::encode(keyword),
            page
        );
        self.http.get(&url).await
    }
}
