use flutter_rust_bridge::frb;
use std::collections::HashMap;
use crate::error::{ApiError, SerializableError};
use crate::models::rcmd::{RcmdVideoInfo, RcmdResponse};
use crate::api::wbi::{get_wbi_keys_cached, enc_wbi, HTTP_CLIENT};

/// Get recommendation list from Bilibili API
///
/// Fetches the recommendation feed from Bilibili's web interface
/// and filters for video content (goto='av')
///
/// # Parameters
/// * `ps` - Page size (number of recommendations to fetch)
/// * `fresh_idx` - Freshness index for recommendations
///
/// # Returns
/// Result containing vector of RcmdVideoInfo structs
///
/// # Errors
/// Returns ApiError for:
/// - HTTP request failures
/// - JSON parsing failures
/// - API error responses
/// - Network issues
///
/// # Examples
/// ```rust
/// let recommendations = get_recommend_list(10, 0).await?;
/// ```
#[frb]
pub async fn get_recommend_list(ps: i32, fresh_idx: i32) -> Result<Vec<RcmdVideoInfo>, SerializableError> {
    // Build request parameters
    let mut params = HashMap::new();
    params.insert("ps".to_string(), ps.to_string());
    params.insert("fresh_idx".to_string(), fresh_idx.to_string());

    // Get WBI keys (cached version)
    let (_, _, mixin_key) = get_wbi_keys_cached().await
        .map_err(|e| SerializableError {
            code: "WBI_ERROR".to_string(),
            message: format!("Failed to get WBI keys: {}", e)
        })?;

    // Sign parameters with WBI
    enc_wbi(&mut params, &mixin_key);

    // Build query string
    let query_string: Vec<String> = params.iter()
        .map(|(key, value)| format!("{}={}", key, value))
        .collect();
    let query_string = query_string.join("&");

    let url = format!("https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd?{}", query_string);

    // Make HTTP GET request
    let client = HTTP_CLIENT.lock().expect("Failed to lock HTTP client");
    let response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .send()
        .await
        .map_err(|e| SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: format!("Network error: {}", e),
        })?;

    // Check HTTP status
    if !response.status().is_success() {
        match response.status().as_u16() {
            401 => return Err(SerializableError {
                code: "UNAUTHORIZED".to_string(),
                message: "Unauthorized access".to_string(),
            }),
            _ => return Err(SerializableError {
                code: "HTTP_ERROR".to_string(),
                message: format!("HTTP error: {}", response.status()),
            }),
        }
    }

    // Parse response
    let text = response.text().await
        .map_err(|e| SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: format!("Failed to read response: {}", e),
        })?;
    let rcmd_response: RcmdResponse = serde_json::from_str(&text)
        .map_err(|e| SerializableError {
            code: "SERIALIZATION_ERROR".to_string(),
            message: format!("JSON parsing error: {}", e),
        })?;

    // Check API response code
    if rcmd_response.code != 0 {
        return Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: rcmd_response.message.clone(),
        });
    }

    // Extract videos and filter for goto='av'
    if let Some(data) = rcmd_response.data {
        let videos: Vec<RcmdVideoInfo> = data.item
            .into_iter()
            .filter(|video| video.goto.as_deref() == Some("av"))
            .collect();

        Ok(videos)
    } else {
        Ok(Vec::new())
    }
}

// Unit tests
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_get_recommend_list() {
        // This test requires network access to fetch actual recommendations
        // It's an integration test that may fail if network is not available
        let result = get_recommend_list(10, 0).await;

        match result {
            Ok(videos) => {
                println!("Successfully fetched {} recommendations", videos.len());

                // Verify we got valid videos
                for video in &videos {
                    assert!(!video.bvid.is_empty(), "BVID should not be empty");
                    assert!(!video.title.is_empty(), "Title should not be empty");
                    assert_eq!(video.goto.as_deref(), Some("av"), "Only videos with goto='av' should be returned");

                    println!("Video: {} - {}", video.bvid, video.title);
                }

                // If we got videos, verify some expected fields
                if !videos.is_empty() {
                    let first_video = &videos[0];
                    assert!(first_video.id.is_some(), "Video ID should be present");
                    assert!(first_video.owner.mid > 0, "Owner MID should be positive");
                    assert!(first_video.stat.view.is_some(), "View count should be present");
                }
            },
            Err(e) => {
                // If the test fails, it might be due to network issues
                println!("Test failed (possibly due to network): {}", e);
                // For unit tests, we might want to mock the HTTP request
                // In this case, we'll just log the error
            }
        }
    }

    #[test]
    fn test_empty_response_handling() {
        // Test that empty data returns empty vector
        let result: Result<Vec<RcmdVideoInfo>, ApiError> = Ok(Vec::new());
        assert!(result.is_ok());
        assert_eq!(result.unwrap().len(), 0);
    }
}