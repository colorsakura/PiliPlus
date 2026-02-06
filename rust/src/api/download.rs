use flutter_rust_bridge::frb;
use crate::models::VideoQuality;
use crate::download::{DownloadTask, DownloadEvent};
use crate::error::BridgeResult;
use crate::services::get_services;
use crate::stream::DownloadStream;

/// Start a new download
#[frb]
pub async fn start_download(
    video_id: String,
    title: String,
    quality: VideoQuality,
    output_dir: String,
) -> BridgeResult<String> {
    let services = get_services();

    services.download.start_download(&video_id, &title, quality, &output_dir).await
        .map_err(|e| e.into())
}

/// Get all download tasks
#[frb(sync)]
pub fn get_all_downloads_sync() -> Vec<DownloadTask> {
    let services = get_services();

    // For sync bridge, we need to block on tokio runtime
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        services.download.all_downloads().await
    })
}

/// Pause a download
#[frb]
pub async fn pause_download(task_id: String) -> BridgeResult<()> {
    let services = get_services();

    services.download.pause_download(&task_id).await
        .map_err(|e| e.into())
}

/// Subscribe to download events (simplified version)
#[frb(sync)]
pub fn download_events() -> flume::Receiver<DownloadEvent> {
    // For now, return an empty receiver
    // TODO: Implement proper event forwarding from broadcast::Receiver to flume::Receiver
    let (_tx, rx) = flume::unbounded();
    rx
}

/// Subscribe to download events stream
///
/// Returns a stream adapter that provides async access to download events.
/// Multiple subscribers can call this function to receive independent streams.
#[frb]
pub fn subscribe_download_events() -> DownloadStream {
    let services = get_services();
    let receiver = services.download.events();
    DownloadStream::new(receiver)
}

/// Poll for the next download event
///
/// Helper function for Flutter to poll events synchronously.
/// Returns None if no event is available or stream is closed.
///
/// TODO: Replace with proper async stream support in flutter_rust_bridge
#[frb(sync)]
pub fn poll_download_event(stream: &mut DownloadStream) -> Option<DownloadEvent> {
    // For sync bridge, we need to block on tokio runtime
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        // Use a timeout to avoid blocking indefinitely
        match tokio::time::timeout(tokio::time::Duration::from_millis(100), stream.next()).await {
            Ok(event) => event,
            Err(_) => None, // Timeout
        }
    })
}