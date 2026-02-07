use super::common::Image;
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct LiveRoomInfo {
    pub room_id: i64,
    pub uid: i64,
    pub title: String,
    pub description: String,
    pub cover: Image,
    pub status: LiveStatus,
    pub online_count: u64,
    pub area_name: String,
}

#[derive(Clone, Copy, Serialize, Deserialize, Debug, PartialEq)]
pub enum LiveStatus {
    Live = 1,
    Preview = 0,
    Round = 2,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct LivePlayUrl {
    pub quality: LiveQuality,
    pub urls: Vec<String>,
}

#[derive(Clone, Copy, Serialize, Deserialize, Debug, PartialEq)]
pub enum LiveQuality {
    Low = 10000,
    Medium = 20000,
    High = 30000,
    Ultra = 40000,
}
