use tokio::sync::broadcast;
use crate::download::DownloadEvent;
use crate::models::Account;

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
        match tokio::time::timeout(tokio::time::Duration::from_secs(5), self.receiver.recv()).await {
            Ok(Ok(event)) => Some(event),
            Ok(Err(broadcast::error::RecvError::Lagged(n))) => {
                tracing::warn!("Download stream lagged, skipped {} events", n);
                // Try to receive the next available event after lag
                match tokio::time::timeout(tokio::time::Duration::from_millis(100), self.receiver.recv()).await {
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
        match tokio::time::timeout(tokio::time::Duration::from_secs(5), self.receiver.recv()).await {
            Ok(Ok(account)) => Some(account),
            Ok(Err(broadcast::error::RecvError::Lagged(n))) => {
                tracing::warn!("Account stream lagged, skipped {} events", n);
                // Try to receive the next available event after lag
                match tokio::time::timeout(tokio::time::Duration::from_millis(100), self.receiver.recv()).await {
                    Ok(Ok(account)) => Some(account),
                    _ => None,
                }
            }
            Ok(Err(broadcast::error::RecvError::Closed)) => None,
            Err(_) => None, // Timeout
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::download::task::DownloadEventType;

    #[tokio::test]
    async fn test_download_stream_next() {
        let (tx, rx) = broadcast::channel(10);
        let mut stream = DownloadStream::new(rx);

        // Send an event
        let event = DownloadEvent {
            task_id: "test-123".to_string(),
            event_type: DownloadEventType::Progress {
                downloaded: 100,
                total: 1000,
                speed: 50.0,
            },
        };
        tx.send(event.clone()).unwrap();

        // Receive it
        let received = stream.next().await;
        assert_eq!(received, Some(event));
    }

    #[tokio::test]
    async fn test_download_stream_lag_handling() {
        let (tx, rx) = broadcast::channel(2);
        let mut stream = DownloadStream::new(rx);

        // Send events that exceed buffer
        let event1 = DownloadEvent {
            task_id: "1".to_string(),
            event_type: DownloadEventType::Paused,
        };
        let event2 = DownloadEvent {
            task_id: "2".to_string(),
            event_type: DownloadEventType::Paused,
        };
        let event3 = DownloadEvent {
            task_id: "3".to_string(),
            event_type: DownloadEventType::Completed,
        };

        tx.send(event1).unwrap();
        tx.send(event2).unwrap();
        tx.send(event3).unwrap();

        // Should get event2 after lag (buffer size is 2, so event1 is dropped)
        let received = stream.next().await;
        assert_eq!(received.unwrap().task_id, "2");
    }

    #[tokio::test]
    async fn test_download_stream_closed() {
        let (_tx, rx) = broadcast::channel(10);
        let mut stream = DownloadStream::new(rx);

        // Drop sender to close channel
        drop(_tx);

        // Should return None
        let received = stream.next().await;
        assert_eq!(received, None);
    }

    #[tokio::test]
    async fn test_account_stream_next() {
        let (tx, rx) = broadcast::channel(10);
        let mut stream = AccountStream::new(rx);

        // Send an account
        let account = Account {
            id: "acc-123".to_string(),
            name: "Test User".to_string(),
            avatar: "https://example.com/avatar.jpg".to_string(),
            cookies: std::collections::HashMap::new(),
            auth_tokens: crate::models::AuthTokens {
                access_token: Some("token".to_string()),
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: true,
        };
        tx.send(account.clone()).unwrap();

        // Receive it
        let received = stream.next().await;
        assert_eq!(received, Some(account));
    }

    #[tokio::test]
    async fn test_account_stream_closed() {
        let (_tx, rx) = broadcast::channel(10);
        let mut stream = AccountStream::new(rx);

        // Drop sender to close channel
        drop(_tx);

        // Should return None
        let received = stream.next().await;
        assert_eq!(received, None);
    }
}
