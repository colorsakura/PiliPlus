pub mod task;
pub mod service;

pub use service::DownloadService;
pub use task::{DownloadTask, DownloadStatus, DownloadEvent};