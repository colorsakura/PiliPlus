use crate::error::ApiError;
use crate::http::HttpService;
use crate::models::{VideoInfo, VideoQuality, VideoUrl};
use serde::Deserialize;

pub struct VideoApi {
    http: std::sync::Arc<HttpService>,
}

// Bilibili API response wrapper
#[derive(Deserialize)]
struct BiliResponse<T> {
    code: i32,
    message: Option<String>,
    data: T,
}

impl VideoApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_video_info(&self, bvid: &str) -> Result<VideoInfo, ApiError> {
        let url = format!("/x/web-interface/view?bvid={}", bvid);

        // Get wrapped response
        let response: BiliResponse<VideoInfo> = self.http.get(&url).await?;

        // Check API response code
        if response.code != 0 {
            return Err(ApiError::ApiError {
                code: response.code,
                message: response
                    .message
                    .unwrap_or_else(|| "Unknown error".to_string()),
            });
        }

        Ok(response.data)
    }

    pub async fn get_video_url(
        &self,
        bvid: &str,
        cid: i64,
        quality: VideoQuality,
    ) -> Result<VideoUrl, ApiError> {
        let url = format!(
            "/x/player/playurl?bvid={}&cid={}&qn={}",
            bvid, cid, quality as i32
        );

        // Get wrapped response
        let response: BiliResponse<VideoUrl> = self.http.get(&url).await?;

        // Check API response code
        if response.code != 0 {
            return Err(ApiError::ApiError {
                code: response.code,
                message: response
                    .message
                    .unwrap_or_else(|| "Unknown error".to_string()),
            });
        }

        Ok(response.data)
    }
}
