use super::common::Image;
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoInfo {
    pub bvid: String,
    pub aid: i64,
    pub title: String,
    #[serde(rename = "desc")]
    pub description: String,
    pub owner: VideoOwner,
    pub pic: Image,
    pub duration: u32,
    #[serde(rename = "stat")]
    pub stats: VideoStats,
    pub cid: i64,
    pub pages: Vec<VideoPage>,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoOwner {
    pub mid: i64,
    pub name: String,
    pub face: Image,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoStats {
    #[serde(rename = "view")]
    pub view_count: u64,
    #[serde(rename = "like")]
    pub like_count: u64,
    #[serde(rename = "coin")]
    pub coin_count: u64,
    #[serde(rename = "favorite")]
    pub collect_count: u64,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoPage {
    pub cid: i64,
    pub page: i32,
    pub part: String,
    pub duration: u32,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoUrl {
    pub quality: VideoQuality,
    pub format: VideoFormat,
    #[serde(rename = "durl")]
    pub segments: Vec<VideoSegment>,
}

#[derive(Clone, Copy, Serialize, Deserialize, Debug, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum VideoQuality {
    Low = 16,
    Medium = 32,
    High = 64,
    Ultra = 80,
    FourK = 112,
}

#[derive(Clone, Copy, Serialize, Deserialize, Debug, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum VideoFormat {
    Mp4,
    Dash,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VideoSegment {
    pub url: String,
    pub size: u64,
    #[serde(rename = "length")]
    pub duration: u32,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct DynamicsItem {
    pub id: String,
    pub uid: i64,
    pub username: String,
    pub avatar: Image,
    pub content: String,
    pub images: Vec<Image>,
    pub publish_time: i64,
    pub like_count: u64,
    pub reply_count: u64,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct DynamicsList {
    pub items: Vec<DynamicsItem>,
    pub has_more: bool,
    pub offset: Option<String>,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct SearchResult {
    pub bvid: String,
    pub title: String,
    pub description: String,
    pub owner: VideoOwner,
    pub cover: Image,
    pub duration: u32,
    pub view_count: u64,
    pub publish_time: String,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct SearchResults {
    pub items: Vec<SearchResult>,
    pub page: u32,
    pub page_size: u32,
    pub total_count: u32,
}
