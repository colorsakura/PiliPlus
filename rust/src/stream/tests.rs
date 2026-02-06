/// Integration tests for stream adapters
///
/// These tests verify the end-to-end functionality of stream adapters
/// with the service layer and bridge API.

use crate::stream::{DownloadStream, AccountStream};
use crate::download::{DownloadEvent, DownloadTask, DownloadStatus};
use crate::models::Account;
use tokio::sync::broadcast;

#[cfg(test)]
mod integration_tests {
    use super::*;

    #[tokio::test]
    async fn test_download_stream_with_service() {
        // Create a broadcast channel similar to DownloadService
        let (tx, rx) = broadcast::channel(100);
        let mut stream = DownloadStream::new(rx);

        // Simulate download service sending events
        tokio::spawn(async move {
            for i in 0..5 {
                let event = DownloadEvent {
                    task_id: format!("task-{}", i),
                    event_type: crate::download::task::DownloadEventType::Progress {
                        downloaded: i * 100,
                        total: 500,
                        speed: 100.0,
                    },
                };
                tx.send(event).unwrap();
                tokio::time::sleep(tokio::time::Duration::from_millis(10)).await;
            }
        });

        // Receive events
        let mut count = 0;
        while let Some(_event) = stream.next().await {
            count += 1;
            if count >= 5 {
                break;
            }
        }

        assert_eq!(count, 5);
    }

    #[tokio::test]
    async fn test_account_stream_with_service() {
        // Create a broadcast channel similar to AccountService
        let (tx, rx) = broadcast::channel(16);
        let mut stream = AccountStream::new(rx);

        // Simulate account service sending changes
        let account1 = Account {
            id: "acc-1".to_string(),
            name: "User 1".to_string(),
            avatar: "avatar1.jpg".to_string(),
            cookies: std::collections::HashMap::new(),
            auth_tokens: crate::models::AuthTokens {
                access_token: Some("token1".to_string()),
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: true,
        };

        let account2 = Account {
            id: "acc-2".to_string(),
            name: "User 2".to_string(),
            avatar: "avatar2.jpg".to_string(),
            cookies: std::collections::HashMap::new(),
            auth_tokens: crate::models::AuthTokens {
                access_token: Some("token2".to_string()),
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: true,
        };

        tokio::spawn(async move {
            tx.send(account1).unwrap();
            tokio::time::sleep(tokio::time::Duration::from_millis(10)).await;
            tx.send(account2).unwrap();
        });

        // Receive first account
        let received1 = stream.next().await;
        assert_eq!(received1.unwrap().id, "acc-1");

        // Receive second account
        let received2 = stream.next().await;
        assert_eq!(received2.unwrap().id, "acc-2");
    }

    #[tokio::test]
    async fn test_multiple_download_streams() {
        // Test that multiple subscribers can receive the same events
        let (tx, rx1) = broadcast::channel(100);
        let rx2 = tx.subscribe();

        let mut stream1 = DownloadStream::new(rx1);
        let mut stream2 = DownloadStream::new(rx2);

        let event = DownloadEvent {
            task_id: "shared-task".to_string(),
            event_type: crate::download::task::DownloadEventType::Paused,
        };

        tx.send(event.clone()).unwrap();

        // Both streams should receive the event
        let received1 = stream1.next().await;
        let received2 = stream2.next().await;

        assert_eq!(received1, Some(event.clone()));
        assert_eq!(received2, Some(event));
    }

    #[tokio::test]
    async fn test_stream_independent_subscribers() {
        // Test that multiple independent subscribers can be created from the same sender
        let (tx, rx1) = broadcast::channel(100);
        let rx2 = tx.subscribe();

        let mut stream1 = DownloadStream::new(rx1);
        let mut stream2 = DownloadStream::new(rx2);

        let event = DownloadEvent {
            task_id: "shared-task".to_string(),
            event_type: crate::download::task::DownloadEventType::Completed,
        };

        tx.send(event.clone()).unwrap();

        // Both streams should receive the event independently
        let received1 = stream1.next().await;
        let received2 = stream2.next().await;

        assert_eq!(received1, Some(event.clone()));
        assert_eq!(received2, Some(event));
    }
}
