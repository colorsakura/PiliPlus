use crate::models::{VideoInfo, VideoUrl, VideoQuality};
use crate::http::HttpService;
use crate::error::ApiError;

pub struct VideoApi {
    http: std::sync::Arc<HttpService>,
}

impl VideoApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_video_info(&self, bvid: &str) -> Result<VideoInfo, ApiError> {
        // Real Bilibili API endpoint
        let url = format!("/x/web-interface/view?bvid={}", bvid);
        self.http.get(&url).await
    }

    pub async fn get_video_url(
        &self,
        bvid: &str,
        cid: i64,
        quality: VideoQuality,
    ) -> Result<VideoUrl, ApiError> {
        let url = format!(
            "/x/player/playurl?bvid={}&cid={}&qn={}",
            bvid,
            cid,
            quality as i32
        );
        self.http.get(&url).await
    }
}