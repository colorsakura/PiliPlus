use crate::models::VideoQuality;
use serde::{Deserialize, Serialize};

/// Download task representation for bridge compatibility
#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct DownloadTaskData {
    pub id: String,
    pub video_id: String,
    pub title: String,
    pub quality: VideoQuality,
    pub total_bytes: u64,
    pub downloaded_bytes: u64,
    pub status: DownloadStatusData,
    pub file_path: String,
    pub can_resume: bool,
    pub created_at: i64,
    pub completed_at: Option<i64>,
}

/// Simplified download status for bridge compatibility
#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub enum DownloadStatusData {
    Pending,
    Downloading { speed: f64, eta: Option<f64> },
    Paused,
    Completed,
    Failed { error: String },
    Cancelled,
}
