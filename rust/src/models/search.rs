use super::common::Image;
use serde::{Deserialize, Serialize};

/// Search result for a single video
#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct SearchVideoItem {
    pub bvid: String,
    pub aid: i64,
    pub title: String,
    pub description: String,
    pub cover: String,
    pub duration: u32,
    pub pubdate: i64,
    pub ctime: i64,
    pub owner: SearchVideoOwner,
    pub stat: SearchVideoStat,
    #[serde(default)]
    pub is_union_video: i32,
    #[serde(default)]
    pub r#type: Option<String>,
    #[serde(default)]
    pub tag: Option<String>,
}

/// Owner information for search result
#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct SearchVideoOwner {
    pub mid: i64,
    pub name: String,
    pub face: String,
}

/// Statistics for search result
#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct SearchVideoStat {
    pub view: i64,
    #[serde(default)]
    pub like: i64,
    #[serde(default)]
    pub danmaku: i64,
}

/// Complete search results response
#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct SearchVideoResult {
    pub items: Vec<SearchVideoItem>,
    pub page: i32,
    pub page_size: i32,
    pub num_results: i32,
}
