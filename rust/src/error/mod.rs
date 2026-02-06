pub mod api_error;
pub mod storage_error;
pub mod account_error;
pub mod download_error;

pub use api_error::ApiError;
pub use storage_error::StorageError;
pub use account_error::AccountError;
pub use download_error::DownloadError;

// Serializable error for Flutter bridge
#[derive(Clone, serde::Serialize, serde::Deserialize, Debug)]
pub struct SerializableError {
    pub code: String,
    pub message: String,
}

impl From<ApiError> for SerializableError {
    fn from(err: ApiError) -> Self {
        SerializableError {
            code: error_code(&err),
            message: err.to_string(),
        }
    }
}

impl From<StorageError> for SerializableError {
    fn from(err: StorageError) -> Self {
        SerializableError {
            code: "STORAGE_ERROR".to_string(),
            message: err.to_string(),
        }
    }
}

impl From<AccountError> for SerializableError {
    fn from(err: AccountError) -> Self {
        SerializableError {
            code: "ACCOUNT_ERROR".to_string(),
            message: err.to_string(),
        }
    }
}

impl From<DownloadError> for SerializableError {
    fn from(err: DownloadError) -> Self {
        SerializableError {
            code: "DOWNLOAD_ERROR".to_string(),
            message: err.to_string(),
        }
    }
}

fn error_code(err: &ApiError) -> String {
    match err {
        ApiError::HttpError(_) => "HTTP_ERROR".to_string(),
        ApiError::ApiError { .. } => "API_ERROR".to_string(),
        ApiError::Unauthorized => "UNAUTHORIZED".to_string(),
        ApiError::NetworkUnavailable => "NETWORK_UNAVAILABLE".to_string(),
        ApiError::SerializationError(_) => "SERIALIZATION_ERROR".to_string(),
        _ => "UNKNOWN_ERROR".to_string(),
    }
}

// Result type for bridge functions
pub type BridgeResult<T> = Result<T, SerializableError>;