use crate::api::wbi::{HTTP_CLIENT, enc_wbi, get_wbi_keys_cached};
use crate::error::SerializableError;
use crate::models::rcmd::{RcmdResponse, RcmdVideoInfo};
use flutter_rust_bridge::frb;
use std::collections::HashMap;
use tracing::{debug, error, info, warn};

/// Helper macro to log to both tracing and stdout
macro_rules! log_info {
    ($($arg:tt)*) => {
        println!($($arg)*);
        info!($($arg)*);
    };
}

macro_rules! log_debug {
    ($($arg:tt)*) => {
        println!($($arg)*);
        debug!($($arg)*);
    };
}

macro_rules! log_warn {
    ($($arg:tt)*) => {
        eprintln!($($arg)*);
        warn!($($arg)*);
    };
}

macro_rules! log_error {
    ($($arg:tt)*) => {
        eprintln!($($arg)*);
        error!($($arg)*);
    };
}

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
pub async fn get_recommend_list(
    ps: i32,
    fresh_idx: i32,
) -> Result<Vec<RcmdVideoInfo>, SerializableError> {
    log_info!(
        "[RustRcmd] Fetching Web recommendations: ps={}, fresh_idx={}",
        ps,
        fresh_idx
    );

    // Build request parameters
    let mut params = HashMap::new();
    params.insert("ps".to_string(), ps.to_string());
    params.insert("fresh_idx".to_string(), fresh_idx.to_string());

    // Get WBI keys (cached version)
    log_debug!("[RustRcmd] Getting WBI keys...");
    let (_, _, mixin_key) = get_wbi_keys_cached().await.map_err(|e| {
        log_error!("[RustRcmd] Failed to get WBI keys: {}", e);
        SerializableError {
            code: "WBI_ERROR".to_string(),
            message: format!("Failed to get WBI keys: {}", e),
        }
    })?;

    log_debug!("[RustRcmd] WBI keys obtained, signing request...");

    // Sign parameters with WBI
    enc_wbi(&mut params, &mixin_key);

    // Build query string
    let query_string: Vec<String> = params
        .iter()
        .map(|(key, value)| format!("{}={}", key, value))
        .collect();
    let query_string = query_string.join("&");

    let url = format!(
        "https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd?{}",
        query_string
    );
    log_debug!("[RustRcmd] Request URL prepared (length: {})", url.len());

    // Make HTTP GET request - clone client to avoid holding lock across await
    let client = HTTP_CLIENT
        .lock()
        .expect("Failed to lock HTTP client")
        .clone();

    log_debug!("[RustRcmd] Sending HTTP GET request...");
    let response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .send()
        .await
        .map_err(|e| {
            log_error!("[RustRcmd] Network error: {}", e);
            SerializableError {
                code: "NETWORK_ERROR".to_string(),
                message: format!("Network error: {}", e),
            }
        })?;

    // Check HTTP status
    if !response.status().is_success() {
        let status = response.status();
        log_error!("[RustRcmd] HTTP error: {}", status);
        match status.as_u16() {
            401 => {
                log_warn!("[RustRcmd] Unauthorized access (401)");
                return Err(SerializableError {
                    code: "UNAUTHORIZED".to_string(),
                    message: "Unauthorized access".to_string(),
                });
            }
            _ => {
                return Err(SerializableError {
                    code: "HTTP_ERROR".to_string(),
                    message: format!("HTTP error: {}", status),
                });
            }
        }
    }

    log_debug!(
        "[RustRcmd] Response received, status: {}",
        response.status()
    );

    // Parse response
    let text = response.text().await.map_err(|e| {
        log_error!("[RustRcmd] Failed to read response body: {}", e);
        SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: format!("Failed to read response: {}", e),
        }
    })?;

    log_debug!("[RustRcmd] Response body length: {} bytes", text.len());

    let rcmd_response: RcmdResponse = serde_json::from_str(&text).map_err(|e| {
        log_error!("[RustRcmd] JSON parsing error: {}", e);
        SerializableError {
            code: "SERIALIZATION_ERROR".to_string(),
            message: format!("JSON parsing error: {}", e),
        }
    })?;

    // Check API response code
    if rcmd_response.code != 0 {
        log_error!(
            "[RustRcmd] API error: code={}, message={}",
            rcmd_response.code,
            rcmd_response.message
        );
        return Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: rcmd_response.message.clone(),
        });
    }

    // Extract videos and filter for goto='av'
    let videos = if let Some(data) = rcmd_response.data {
        let total_items = data.item.len();
        let videos: Vec<RcmdVideoInfo> = data
            .item
            .into_iter()
            .filter(|video| video.goto.as_deref() == Some("av"))
            .collect();

        log_info!(
            "[RustRcmd] Successfully fetched {} video recommendations (filtered from {} items)",
            videos.len(),
            total_items
        );

        // Log first video for debugging
        if !videos.is_empty() {
            log_debug!(
                "[RustRcmd] First video: {} - {}",
                videos[0].bvid,
                videos[0].title
            );
        }

        videos
    } else {
        log_warn!("[RustRcmd] Response data is null, returning empty list");
        Vec::new()
    };

    log_info!("[RustRcmd] Web recommendations completed successfully");
    Ok(videos)
}
