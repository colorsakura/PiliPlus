use crate::download::service::DownloadService;
use crate::error::ApiError;
use crate::http::service::HttpService;
use crate::models::{DownloadStatusData, DownloadTaskData, VideoQuality};
use flutter_rust_bridge::frb;
use std::sync::Arc;
use std::sync::Mutex;
use tokio::sync::RwLock;

/// Global download manager instance
static DOWNLOAD_MANAGER: Mutex<Option<Arc<DownloadManager>>> = Mutex::new(None);

/// Internal download manager wrapper
struct DownloadManager {
    download_dir: String,
    service: Arc<DownloadService>,
    http: Arc<HttpService>,
}

impl DownloadManager {
    fn new(download_dir: String) -> Result<Self, ApiError> {
        let http = Arc::new(HttpService::new("https://api.bilibili.com".to_string())?);
        let service = Arc::new(DownloadService::new(
            Arc::new(crate::storage::StorageService::in_memory()?),
            http.clone(),
        ));

        Ok(Self {
            download_dir,
            service,
            http,
        })
    }
}

/// Initialize the download manager with a download directory
#[frb]
pub async fn initDownloadManager(download_dir: String) -> Result<(), ApiError> {
    let manager = Arc::new(DownloadManager::new(download_dir)?);
    DOWNLOAD_MANAGER.lock().unwrap().replace(manager);
    Ok(())
}

/// Create a new download task
#[frb]
pub async fn createDownloadTask(
    video_id: String,
    title: String,
    quality: VideoQuality,
) -> Result<DownloadTaskData, ApiError> {
    let manager = get_manager()?;
    let output_dir = &manager.download_dir;

    let task_id = manager
        .service
        .start_download(&video_id, &title, quality, output_dir)
        .await
        .map_err(|e| ApiError::DownloadError(e.to_string()))?;

    // Get the created task
    let tasks = manager.service.all_downloads().await;
    let task = tasks
        .into_iter()
        .find(|t| t.id == task_id)
        .ok_or_else(|| ApiError::DownloadError("Failed to create task".to_string()))?;

    Ok(convert_task_to_bridge(task))
}

/// Start downloading a task
#[frb]
pub async fn startDownload(_task_id: String) -> Result<(), ApiError> {
    let _manager = get_manager()?;
    // Task is already started in createDownloadTask
    // This is a no-op for now, but kept for API compatibility
    Ok(())
}

/// Pause an in-progress download
#[frb]
pub async fn pauseDownload(task_id: String) -> Result<(), ApiError> {
    let manager = get_manager()?;
    manager
        .service
        .pause_download(&task_id)
        .await
        .map_err(|e| ApiError::DownloadError(e.to_string()))?;
    Ok(())
}

/// Resume a paused download
#[frb]
pub async fn resumeDownload(task_id: String) -> Result<(), ApiError> {
    let manager = get_manager()?;
    manager
        .service
        .resume_download(&task_id)
        .await
        .map_err(|e| ApiError::DownloadError(e.to_string()))?;
    Ok(())
}

/// Cancel a download
#[frb]
pub async fn cancelDownload(task_id: String) -> Result<(), ApiError> {
    let manager = get_manager()?;
    manager
        .service
        .cancel_download(&task_id)
        .await
        .map_err(|e| ApiError::DownloadError(e.to_string()))?;
    Ok(())
}

/// Get a specific download task
#[frb]
pub async fn getDownloadTask(task_id: String) -> Option<DownloadTaskData> {
    let manager = get_manager().ok()?;
    let tasks = manager.service.all_downloads().await;
    tasks
        .into_iter()
        .find(|t| t.id == task_id)
        .map(convert_task_to_bridge)
}

/// List all download tasks
#[frb]
pub async fn listDownloadTasks() -> Vec<DownloadTaskData> {
    let manager = match get_manager() {
        Ok(m) => m,
        Err(_) => return vec![],
    };

    manager
        .service
        .all_downloads()
        .await
        .into_iter()
        .map(convert_task_to_bridge)
        .collect()
}

/// Helper function to get the download manager
fn get_manager() -> Result<Arc<DownloadManager>, ApiError> {
    DOWNLOAD_MANAGER
        .lock()
        .unwrap()
        .as_ref()
        .cloned()
        .ok_or_else(|| ApiError::DownloadError("Download manager not initialized".to_string()))
}

/// Helper function to convert internal task to bridge-compatible format
fn convert_task_to_bridge(task: crate::download::task::DownloadTask) -> DownloadTaskData {
    DownloadTaskData {
        id: task.id,
        video_id: task.video_id,
        title: task.title,
        quality: task.quality,
        total_bytes: task.total_bytes,
        downloaded_bytes: task.downloaded_bytes,
        status: match task.status {
            crate::download::task::DownloadStatus::Pending => DownloadStatusData::Pending,
            crate::download::task::DownloadStatus::Downloading { speed, eta } => {
                DownloadStatusData::Downloading { speed, eta }
            }
            crate::download::task::DownloadStatus::Paused => DownloadStatusData::Paused,
            crate::download::task::DownloadStatus::Completed => DownloadStatusData::Completed,
            crate::download::task::DownloadStatus::Failed { error } => {
                DownloadStatusData::Failed { error }
            }
            crate::download::task::DownloadStatus::Cancelled => DownloadStatusData::Cancelled,
        },
        file_path: task.file_path.to_string_lossy().to_string(),
        can_resume: task.can_resume,
        created_at: task.created_at.timestamp(),
        completed_at: task.completed_at.map(|dt| dt.timestamp()),
    }
}
