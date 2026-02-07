use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RcmdVideoInfo {
    pub id: Option<i64>, // Corresponds to aid
    pub bvid: String,
    pub cid: Option<i64>,
    pub goto: Option<String>, // 'av', 'bangumi', etc.
    pub uri: Option<String>,
    pub pic: Option<String>, // Cover URL
    pub title: String,
    pub duration: i32,
    pub pubdate: Option<i64>,
    pub owner: RcmdOwner,
    pub stat: RcmdStat,
    pub is_followed: bool,
    pub rcmd_reason: Option<String>, // Recommendation reason content
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RcmdOwner {
    pub mid: i64,
    pub name: String,
    pub face: Option<String>, // Avatar URL
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RcmdStat {
    pub view: Option<i64>,
    pub like: Option<i64>,
    pub danmaku: Option<i64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RcmdResponse {
    pub code: i32,
    pub message: String,
    pub data: Option<RcmdData>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RcmdData {
    pub item: Vec<RcmdVideoInfo>,
}
