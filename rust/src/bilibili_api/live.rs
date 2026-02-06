use crate::models::{LiveRoomInfo, LivePlayUrl};
use crate::http::HttpService;
use crate::error::ApiError;

pub struct LiveApi {
    http: std::sync::Arc<HttpService>,
}

impl LiveApi {
    pub fn new(http: std::sync::Arc<HttpService>) -> Self {
        Self { http }
    }

    pub async fn get_room_info(&self, room_id: i64) -> Result<LiveRoomInfo, ApiError> {
        let url = format!("/xlive/web-room/v1/index/getInfoByRoom?room_id={}", room_id);
        self.http.get(&url).await
    }

    pub async fn get_play_url(&self, room_id: i64) -> Result<LivePlayUrl, ApiError> {
        let url = format!("/xlive/web-room/v2/index/getRoomPlayInfo?room_id={}", room_id);
        self.http.get(&url).await
    }
}
