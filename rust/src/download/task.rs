use serde::{Serialize, Deserialize};
use crate::models::VideoQuality;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct DownloadTask {
    pub id: String,
    pub video_id: String,
    pub title: String,
    pub quality: VideoQuality,
    pub total_bytes: u64,
    pub downloaded_bytes: u64,
    pub status: DownloadStatus,
    pub file_path: std::path::PathBuf,
    pub created_at: chrono::DateTime<chrono::Utc>,
    pub completed_at: Option<chrono::DateTime<chrono::Utc>>,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub enum DownloadStatus {
    Pending,
    Downloading { speed: f64, eta: Option<f64> },
    Paused,
    Completed,
    Failed { error: String },
    Cancelled,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct DownloadEvent {
    pub task_id: String,
    pub event_type: DownloadEventType,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub enum DownloadEventType {
    Progress { downloaded: u64, total: u64, speed: f64 },
    Paused,
    Completed,
    Failed { error: String },
    Cancelled,
}