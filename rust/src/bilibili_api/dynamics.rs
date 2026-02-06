use crate::models::{DynamicsList, DynamicsItem};
use crate::http::HttpService;
use crate::error::ApiError;

pub struct DynamicsApi {
    http: std::sync::Arc<HttpService>,
}

impl DynamicsApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_user_dynamics(
        &self,
        uid: i64,
        offset: Option<&str>,
    ) -> Result<DynamicsList, ApiError> {
        let mut url = format!("/x/space/arc/search?mid={}", uid);
        if let Some(off) = offset {
            url.push_str(&format!("&offset={}", off));
        }
        self.http.get(&url).await
    }

    pub async fn get_dynamics_detail(&self, dynamic_id: &str) -> Result<DynamicsItem, ApiError> {
        let url = format!("/x/polymer/web-dynamics/v1/detail?id={}", dynamic_id);
        self.http.get(&url).await
    }
}
