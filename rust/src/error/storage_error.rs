use thiserror::Error;

#[derive(Error, Debug)]
pub enum StorageError {
    #[error("Database error: {0}")]
    DatabaseError(#[from] sqlx::Error),

    #[error("Account not found: {0}")]
    AccountNotFound(String),

    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),

    #[error("Serialization error: {0}")]
    SerializationError(#[from] serde_json::Error),
}
