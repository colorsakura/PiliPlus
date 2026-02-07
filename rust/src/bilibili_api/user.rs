use crate::error::ApiError;
use crate::http::HttpService;
use crate::models::{UserInfo, UserStats};

pub struct UserApi {
    http: std::sync::Arc<HttpService>,
}

impl UserApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_user_info(&self, mid: i64) -> Result<UserInfo, ApiError> {
        let url = format!("/x/space/acc/info?mid={}", mid);
        self.http.get(&url).await
    }

    pub async fn get_user_stats(&self, mid: i64) -> Result<UserStats, ApiError> {
        let url = format!("/x/relation/stat?vmid={}", mid);
        self.http.get(&url).await
    }
}
