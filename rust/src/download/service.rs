use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};
use crate::download::task::{DownloadTask, DownloadStatus, DownloadEvent};
use crate::download::retry::RetryPolicy;
use crate::storage::StorageService;
use crate::http::HttpService;
use crate::error::DownloadError;

pub struct DownloadService {
    active_downloads: Arc<RwLock<std::collections::HashMap<String, DownloadTask>>>,
    storage: Arc<StorageService>,
    http: Arc<HttpService>,
    download_tx: broadcast::Sender<DownloadEvent>,
}

impl DownloadService {
    pub fn new(
        storage: Arc<StorageService>,
        http: Arc<HttpService>,
    ) -> Self {
        let (tx, _) = broadcast::channel(100);

        Self {
            active_downloads: Arc::new(RwLock::new(std::collections::HashMap::new())),
            storage,
            http,
            download_tx: tx,
        }
    }

    pub async fn start_download(
        &self,
        video_id: &str,
        title: &str,
        quality: crate::models::VideoQuality,
        output_dir: &str,
    ) -> Result<String, DownloadError> {
        let task_id = uuid::Uuid::new_v4().to_string();
        let file_path = std::path::PathBuf::from(output_dir).join(format!("{}.mp4", video_id));

        let task = DownloadTask {
            id: task_id.clone(),
            video_id: video_id.to_string(),
            title: title.to_string(),
            quality,
            total_bytes: 0,
            downloaded_bytes: 0,
            status: DownloadStatus::Pending,
            file_path: file_path.clone(),
            created_at: chrono::Utc::now(),
            completed_at: None,
        };

        self.active_downloads.write().await.insert(task_id.clone(), task.clone());

        // Spawn download task
        let service = self.clone();
        let task_id_spawn = task_id.clone();
        tokio::spawn(async move {
            service.do_download(&task_id_spawn, &file_path).await;
        });

        Ok(task_id)
    }

    async fn do_download(&self, task_id: &str, output_path: &std::path::Path) {
        // Update status to downloading
        {
            let mut tasks = self.active_downloads.write().await;
            if let Some(task) = tasks.get_mut(task_id) {
                task.status = DownloadStatus::Downloading {
                    speed: 0.0,
                    eta: None,
                };
            }
        }

        let retry_policy = RetryPolicy::default();
        let mut attempt = 0;

        loop {
            attempt += 1;

            match self.attempt_download(task_id, output_path).await {
                Ok(_) => {
                    // Mark as completed
                    let mut tasks = self.active_downloads.write().await;
                    if let Some(task) = tasks.get_mut(task_id) {
                        task.status = DownloadStatus::Completed;
                        task.completed_at = Some(chrono::Utc::now());
                    }

                    let _ = self.download_tx.send(DownloadEvent {
                        task_id: task_id.to_string(),
                        event_type: crate::download::task::DownloadEventType::Completed,
                    });
                    break;
                }
                Err(e) => {
                    if retry_policy.should_retry(attempt) {
                        tracing::warn!(
                            task_id = %task_id,
                            attempt = attempt,
                            max_attempts = retry_policy.max_attempts,
                            error = %e,
                            "Download attempt failed, retrying..."
                        );

                        // Send retry event
                        let _ = self.download_tx.send(DownloadEvent {
                            task_id: task_id.to_string(),
                            event_type: crate::download::task::DownloadEventType::Failed {
                                error: format!("Attempt {}/{} failed: {}", attempt, retry_policy.max_attempts, e),
                            },
                        });

                        // Calculate delay and wait before retry
                        let delay = retry_policy.delay_for_attempt(attempt);
                        tokio::time::sleep(delay).await;
                    } else {
                        tracing::error!(
                            task_id = %task_id,
                            attempt = attempt,
                            max_attempts = retry_policy.max_attempts,
                            error = %e,
                            "Download failed after maximum attempts"
                        );

                        // Mark as failed
                        let mut tasks = self.active_downloads.write().await;
                        if let Some(task) = tasks.get_mut(task_id) {
                            task.status = DownloadStatus::Failed {
                                error: e.to_string(),
                            };
                        }

                        // Send final failed event
                        let _ = self.download_tx.send(DownloadEvent {
                            task_id: task_id.to_string(),
                            event_type: crate::download::task::DownloadEventType::Failed {
                                error: format!("Failed after {} attempts: {}", attempt, e),
                            },
                        });
                        break;
                    }
                }
            }
        }
    }

    /// Perform a single download attempt
    /// TODO: Implement actual HTTP download logic in a future task
    async fn attempt_download(
        &self,
        _task_id: &str,
        _output_path: &std::path::Path,
    ) -> Result<(), DownloadError> {
        // Placeholder: Simulate download attempt
        // In a real implementation, this would:
        // 1. Make HTTP request to download URL
        // 2. Stream response to file
        // 3. Handle network errors
        // 4. Return Ok(()) on success, Err on failure

        // For now, simulate a successful download
        tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
        Ok(())
    }

    pub async fn pause_download(&self, task_id: &str) -> Result<(), DownloadError> {
        let mut tasks = self.active_downloads.write().await;
        if let Some(task) = tasks.get_mut(task_id) {
            task.status = DownloadStatus::Paused;
            let _ = self.download_tx.send(DownloadEvent {
                task_id: task_id.to_string(),
                event_type: crate::download::task::DownloadEventType::Paused,
            });
            Ok(())
        } else {
            Err(DownloadError::NotFound(task_id.to_string()))
        }
    }

    pub fn events(&self) -> broadcast::Receiver<DownloadEvent> {
        self.download_tx.subscribe()
    }

    pub async fn all_downloads(&self) -> Vec<DownloadTask> {
        self.active_downloads.read().await.values().cloned().collect()
    }
}

impl Clone for DownloadService {
    fn clone(&self) -> Self {
        Self {
            active_downloads: self.active_downloads.clone(),
            storage: self.storage.clone(),
            http: self.http.clone(),
            download_tx: self.download_tx.clone(),
        }
    }
}