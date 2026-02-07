use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};
use crate::download::task::{DownloadTask, DownloadStatus, DownloadEvent, DownloadEventType};
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
            can_resume: true,
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
    /// Downloads file from URL to output path with progress tracking
    async fn attempt_download(
        &self,
        task_id: &str,
        output_path: &std::path::Path,
    ) -> Result<(), DownloadError> {
        // Get task details to retrieve URL
        let (download_url, start_offset) = {
            let tasks = self.active_downloads.read().await;
            let task = tasks.get(task_id).ok_or_else(|| DownloadError::NotFound(task_id.to_string()))?;
            // For now, we'll use a placeholder URL since DownloadTask doesn't have a URL field yet
            // In production, this would come from the task struct
            (format!("https://example.com/download/{}", task.video_id), 0u64)
        };

        // Create parent directory if it doesn't exist
        if let Some(parent) = output_path.parent() {
            tokio::fs::create_dir_all(parent).await?;
        }

        // Use HTTP service to download file
        let response = self.http
            .get_client()
            .get(&download_url)
            .send()
            .await
            .map_err(|e| DownloadError::DownloadFailed(format!("HTTP request failed: {}", e)))?;

        if !response.status().is_success() {
            return Err(DownloadError::DownloadFailed(
                format!("HTTP error: {}", response.status())
            ));
        }

        let total_size = response.content_length().unwrap_or(0);
        let bytes = response
            .bytes()
            .await
            .map_err(|e| DownloadError::DownloadFailed(format!("Failed to download: {}", e)))?;

        // Write to file
        tokio::fs::write(output_path, &bytes)
            .await
            .map_err(|e| DownloadError::FileSystemError(e))?;

        // Update task progress
        {
            let mut tasks = self.active_downloads.write().await;
            if let Some(task) = tasks.get_mut(task_id) {
                task.downloaded_bytes = bytes.len() as u64;
                task.total_bytes = total_size;

                // Send progress event
                let _ = self.download_tx.send(DownloadEvent {
                    task_id: task_id.to_string(),
                    event_type: DownloadEventType::Progress {
                        downloaded: bytes.len() as u64,
                        total: total_size,
                        speed: 0.0,
                    },
                });
            }
        }

        Ok(())
    }

    pub async fn pause_download(&self, task_id: &str) -> Result<(), DownloadError> {
        let mut tasks = self.active_downloads.write().await;
        if let Some(task) = tasks.get_mut(task_id) {
            task.status = DownloadStatus::Paused;
            task.can_resume = true;
            let _ = self.download_tx.send(DownloadEvent {
                task_id: task_id.to_string(),
                event_type: crate::download::task::DownloadEventType::Paused,
            });
            Ok(())
        } else {
            Err(DownloadError::NotFound(task_id.to_string()))
        }
    }

    pub async fn cancel_download(&self, task_id: &str) -> Result<(), DownloadError> {
        let mut tasks = self.active_downloads.write().await;
        if let Some(task) = tasks.get_mut(task_id) {
            task.status = DownloadStatus::Cancelled;
            task.can_resume = false;
            let _ = self.download_tx.send(DownloadEvent {
                task_id: task_id.to_string(),
                event_type: crate::download::task::DownloadEventType::Cancelled,
            });
            Ok(())
        } else {
            Err(DownloadError::NotFound(task_id.to_string()))
        }
    }

    pub async fn resume_download(&self, task_id: &str) -> Result<(), DownloadError> {
        // Get task details and check if resumable
        let (file_path, start_offset) = {
            let tasks = self.active_downloads.read().await;
            let task = tasks.get(task_id).ok_or_else(|| DownloadError::NotFound(task_id.to_string()))?;

            if !task.can_resume {
                return Err(DownloadError::DownloadFailed(
                    "Download cannot be resumed".to_string()
                ));
            }

            (task.file_path.clone(), task.downloaded_bytes)
        };

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

        // Spawn resume task
        let service = self.clone();
        let task_id_spawn = task_id.to_string();
        tokio::spawn(async move {
            service.do_resume_download(&task_id_spawn, &file_path, start_offset).await;
        });

        Ok(())
    }

    async fn do_resume_download(&self, task_id: &str, output_path: &std::path::Path, start_offset: u64) {
        tracing::info!(
            task_id = %task_id,
            start_offset = start_offset,
            "Resuming download from byte offset"
        );

        let retry_policy = RetryPolicy::default();
        let mut attempt = 0;

        loop {
            attempt += 1;

            match self.attempt_resume_download(task_id, output_path, start_offset).await {
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
                            "Resume attempt failed, retrying..."
                        );

                        // Send retry event
                        let _ = self.download_tx.send(DownloadEvent {
                            task_id: task_id.to_string(),
                            event_type: crate::download::task::DownloadEventType::Failed {
                                error: format!("Resume attempt {}/{} failed: {}", attempt, retry_policy.max_attempts, e),
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
                            "Resume failed after maximum attempts"
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
                                error: format!("Resume failed after {} attempts: {}", attempt, e),
                            },
                        });
                        break;
                    }
                }
            }
        }
    }

    /// Perform a single resume download attempt with Range header
    /// Resumes download from the specified byte offset
    async fn attempt_resume_download(
        &self,
        task_id: &str,
        output_path: &std::path::Path,
        start_offset: u64,
    ) -> Result<(), DownloadError> {
        // Get task details to retrieve URL
        let download_url = {
            let tasks = self.active_downloads.read().await;
            let task = tasks.get(task_id).ok_or_else(|| DownloadError::NotFound(task_id.to_string()))?;
            format!("https://example.com/download/{}", task.video_id)
        };

        // Create parent directory if it doesn't exist
        if let Some(parent) = output_path.parent() {
            tokio::fs::create_dir_all(parent).await?;
        }

        // Use HTTP service to download file with Range header
        let response = self.http
            .get_client()
            .get(&download_url)
            .header("Range", format!("bytes={}-", start_offset))
            .send()
            .await
            .map_err(|e| DownloadError::DownloadFailed(format!("HTTP request failed: {}", e)))?;

        // Check if server supports range requests
        if response.status() == 416 {
            // Range not satisfiable - file might be already complete
            return Err(DownloadError::DownloadFailed(
                "Invalid byte range".to_string()
            ));
        }

        if !response.status().is_success() && response.status().as_u16() != 206 {
            return Err(DownloadError::DownloadFailed(
                format!("HTTP error: {}", response.status())
            ));
        }

        let total_size = response.content_length().unwrap_or(0) + start_offset;
        let bytes = response
            .bytes()
            .await
            .map_err(|e| DownloadError::DownloadFailed(format!("Failed to download: {}", e)))?;

        // Append to file
        let mut file = tokio::fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(output_path)
            .await?;

        tokio::io::AsyncWriteExt::write_all(&mut file, &bytes)
            .await
            .map_err(|e| DownloadError::FileSystemError(e))?;

        // Update task progress
        {
            let mut tasks = self.active_downloads.write().await;
            if let Some(task) = tasks.get_mut(task_id) {
                task.downloaded_bytes = start_offset + bytes.len() as u64;
                task.total_bytes = total_size;

                // Send progress event
                let _ = self.download_tx.send(DownloadEvent {
                    task_id: task_id.to_string(),
                    event_type: DownloadEventType::Progress {
                        downloaded: start_offset + bytes.len() as u64,
                        total: total_size,
                        speed: 0.0,
                    },
                });
            }
        }

        Ok(())
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