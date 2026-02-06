use serde::{Deserialize, Serialize};
use super::common::Image;

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