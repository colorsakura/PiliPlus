#[cfg(test)]
mod tests {
    use crate::error::{SerializableError, ApiError, StorageError, AccountError, DownloadError};

    #[test]
    fn test_api_error_to_serializable() {
        let err = ApiError::Unauthorized;
        let serializable: SerializableError = err.into();
        assert_eq!(serializable.code, "UNAUTHORIZED");
        assert!(serializable.message.contains("Authentication"));
    }

    #[test]
    fn test_http_error_to_serializable() {
        let http_err = reqwest::Error::from(
            reqwest::Error::Request(#[from] std::io::Error::new(
                std::io::ErrorKind::NotFound,
                "not found"
            ))
        );
        let err = ApiError::HttpError(http_err);
        let serializable: SerializableError = err.into();
        assert_eq!(serializable.code, "HTTP_ERROR");
    }

    #[test]
    fn test_storage_error_to_serializable() {
        let err = StorageError::AccountNotFound("test_id".to_string());
        let serializable: SerializableError = err.into();
        assert_eq!(serializable.code, "STORAGE_ERROR");
        assert!(serializable.message.contains("Account not found"));
    }

    #[test]
    fn test_account_error_to_serializable() {
        let err = AccountError::QrExpired;
        let serializable: SerializableError = err.into();
        assert_eq!(serializable.code, "ACCOUNT_ERROR");
        assert!(serializable.message.contains("QR code expired"));
    }

    #[test]
    fn test_download_error_to_serializable() {
        let err = DownloadError::Paused;
        let serializable: SerializableError = err.into();
        assert_eq!(serializable.code, "DOWNLOAD_ERROR");
        assert!(serializable.message.contains("Download paused"));
    }
}