use crate::download::DownloadEvent;
use crate::models::Account;
use tokio::sync::broadcast;

/// Stream adapter for download events
///
/// Wraps a tokio broadcast receiver to provide async iteration
/// compatible with flutter_rust_bridge's streaming support.
pub struct DownloadStream {
    receiver: broadcast::Receiver<DownloadEvent>,
}

impl DownloadStream {
    /// Create a new download stream from a broadcast receiver
    pub fn new(receiver: broadcast::Receiver<DownloadEvent>) -> Self {
        Self { receiver }
    }

    /// Get the next download event asynchronously
    ///
    /// Returns None if the stream is closed or lagged
    pub async fn next(&mut self) -> Option<DownloadEvent> {
        // TODO: Implement proper async stream with backpressure handling
        // For now, use async recv with timeout to avoid blocking indefinitely
        match tokio::time::timeout(tokio::time::Duration::from_secs(5), self.receiver.recv()).await
        {
            Ok(Ok(event)) => Some(event),
            Ok(Err(broadcast::error::RecvError::Lagged(n))) => {
                tracing::warn!("Download stream lagged, skipped {} events", n);
                // Try to receive the next available event after lag
                match tokio::time::timeout(
                    tokio::time::Duration::from_millis(100),
                    self.receiver.recv(),
                )
                .await
                {
                    Ok(Ok(event)) => Some(event),
                    _ => None,
                }
            }
            Ok(Err(broadcast::error::RecvError::Closed)) => None,
            Err(_) => None, // Timeout
        }
    }
}

/// Stream adapter for account change events
///
/// Wraps a tokio broadcast receiver to provide async iteration
/// compatible with flutter_rust_bridge's streaming support.
pub struct AccountStream {
    receiver: broadcast::Receiver<Account>,
}

impl AccountStream {
    /// Create a new account stream from a broadcast receiver
    pub fn new(receiver: broadcast::Receiver<Account>) -> Self {
        Self { receiver }
    }

    /// Get the next account change event asynchronously
    ///
    /// Returns None if the stream is closed or lagged
    pub async fn next(&mut self) -> Option<Account> {
        // TODO: Implement proper async stream with backpressure handling
        // For now, use async recv with timeout to avoid blocking indefinitely
        match tokio::time::timeout(tokio::time::Duration::from_secs(5), self.receiver.recv()).await
        {
            Ok(Ok(account)) => Some(account),
            Ok(Err(broadcast::error::RecvError::Lagged(n))) => {
                tracing::warn!("Account stream lagged, skipped {} events", n);
                // Try to receive the next available event after lag
                match tokio::time::timeout(
                    tokio::time::Duration::from_millis(100),
                    self.receiver.recv(),
                )
                .await
                {
                    Ok(Ok(account)) => Some(account),
                    _ => None,
                }
            }
            Ok(Err(broadcast::error::RecvError::Closed)) => None,
            Err(_) => None, // Timeout
        }
    }
}
