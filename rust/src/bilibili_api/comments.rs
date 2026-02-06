use crate::models::CommentList;
use crate::http::HttpService;
use crate::error::ApiError;

pub struct CommentsApi {
    http: std::sync::Arc<HttpService>,
}

impl CommentsApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_video_comments(
        &self,
        oid: i64,
        page: u32,
        page_size: u32,
    ) -> Result<CommentList, ApiError> {
        let url = format!(
            "/x/v2/reply/main?oid={}&type=1&pn={}&ps={}",
            oid, page, page_size
        );
        self.http.get(&url).await
    }
}
