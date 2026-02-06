use serde::{Deserialize, Serialize};
use super::common::Image;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct Comment {
    pub id: i64,
    pub oid: i64,
    pub uid: i64,
    pub username: String,
    pub avatar: Image,
    pub content: String,
    pub like_count: u64,
    pub reply_count: u64,
    pub publish_time: i64,
    pub replies: Vec<Comment>,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct CommentList {
    pub comments: Vec<Comment>,
    pub page: u32,
    pub page_size: u32,
    pub total_count: u32,
}
