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

impl std::fmt::Display for SerializableError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.code, self.message)
    }
}

impl std::error::Error for SerializableError {}

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

impl From<String> for SerializableError {
    fn from(err: String) -> Self {
        SerializableError {
            code: "UNKNOWN_ERROR".to_string(),
            message: err,
        }
    }
}

impl From<reqwest::Error> for SerializableError {
    fn from(err: reqwest::Error) -> Self {
        SerializableError {
            code: "HTTP_ERROR".to_string(),
            message: err.to_string(),
        }
    }
}

impl From<serde_json::Error> for SerializableError {
    fn from(err: serde_json::Error) -> Self {
        SerializableError {
            code: "SERIALIZATION_ERROR".to_string(),
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

// Result type for bridge functions (legacy - still used in services)
pub type BridgeResult<T> = Result<T, SerializableError>;

// Serializable result wrapper for Flutter bridge
// This replaces BridgeResult for all #[frb] functions
#[derive(Clone, serde::Serialize, serde::Deserialize, Debug)]
pub struct ApiResult<T> {
    pub success: bool,
    pub data: Option<T>,
    pub error: Option<String>,
}

impl<T> From<Result<T, SerializableError>> for ApiResult<T> {
    fn from(result: Result<T, SerializableError>) -> Self {
        match result {
            Ok(data) => ApiResult {
                success: true,
                data: Some(data),
                error: None,
            },
            Err(err) => ApiResult {
                success: false,
                data: None,
                error: Some(format!("{}: {}", err.code, err.message)),
            },
        }
    }
}

impl<T> From<Result<T, ApiError>> for ApiResult<T> {
    fn from(result: Result<T, ApiError>) -> Self {
        match result {
            Ok(data) => ApiResult {
                success: true,
                data: Some(data),
                error: None,
            },
            Err(err) => ApiResult {
                success: false,
                data: None,
                error: Some(err.to_string()),
            },
        }
    }
}

// Removed generic From impl to avoid conflict with ApiError impl
// impl<T, E> From<Result<T, E>> for ApiResult<T>
// where
//     E: std::fmt::Display,
// {
//     fn from(result: Result<T, E>) -> Self {
//         match result {
//             Ok(data) => ApiResult {
//                 success: true,
//             Ok(data) => ApiResult {
//                 success: true,
//                 data: Some(data),
//                 error: None,
//             },
//             Err(err) => ApiResult {
//                 success: false,
//                 data: None,
//                 error: Some(err.to_string()),
//             },
//         }
//     }
// }