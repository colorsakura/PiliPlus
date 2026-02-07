use thiserror::Error;

#[derive(Error, Debug)]
pub enum DownloadError {
    #[error("Download failed: {0}")]
    DownloadFailed(String),

    #[error("Download not found: {0}")]
    NotFound(String),

    #[error("Download paused")]
    Paused,

    #[error("File system error: {0}")]
    FileSystemError(#[from] std::io::Error),

    #[error("HTTP error: {0}")]
    HttpError(#[from] reqwest::Error),
}
