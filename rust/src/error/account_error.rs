use thiserror::Error;

#[derive(Error, Debug)]
pub enum AccountError {
    #[error("Login failed: {0}")]
    LoginFailed(String),

    #[error("QR code expired")]
    QrExpired,

    #[error("Account not found: {0}")]
    AccountNotFound(String),

    #[error("No active account")]
    NoActiveAccount,

    #[error("Session expired")]
    SessionExpired,

    #[error("Storage error: {0}")]
    StorageError(String),
}
