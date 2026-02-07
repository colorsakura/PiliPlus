use thiserror::Error;
use crate::error::storage_error::StorageError;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("HTTP request failed: {0}")]
    HttpError(#[from] reqwest::Error),

    #[error("API returned error: code={code}, msg={message}")]
    ApiError { code: i32, message: String },

    #[error("Authentication required")]
    Unauthorized,

    #[error("Network unavailable")]
    NetworkUnavailable,

    #[error("Serialization error: {0}")]
    SerializationError(#[from] serde_json::Error),

    #[error("Invalid URL: {0}")]
    InvalidUrl(String),

    #[error("Request timeout")]
    Timeout,

    #[error("Download error: {0}")]
    DownloadError(String),

    #[error("Storage error: {0}")]
    StorageError(#[from] StorageError),
}
