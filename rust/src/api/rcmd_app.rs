use flutter_rust_bridge::frb;
use std::collections::HashMap;
use crate::error::SerializableError;
use crate::models::rcmd::RcmdVideoInfo;
use crate::api::wbi::HTTP_CLIENT;
use tracing::{info, warn, error, debug};

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

/// Get recommendation list from Bilibili APP API
///
/// Fetches the recommendation feed from Bilibili's APP interface
/// and filters for video content (card_goto='av')
///
/// # Parameters
/// * `ps` - Page size (number of recommendations to fetch)
/// * `fresh_idx` - Freshness index for recommendations (idx parameter)
///
/// # Returns
/// Result containing vector of RcmdVideoInfo structs
///
/// # Errors
/// Returns SerializableError for:
/// - HTTP request failures
/// - JSON parsing failures
/// - API error responses
/// - Network issues
///
/// # Examples
/// ```rust
/// let recommendations = get_recommend_list_app(10, 0).await?;
/// ```
#[frb]
pub async fn get_recommend_list_app(ps: i32, fresh_idx: i32) -> Result<Vec<RcmdVideoInfo>, SerializableError> {
    log_info!(
        "[RustRcmdApp] Fetching App recommendations: ps={}, fresh_idx={}",
        ps, fresh_idx
    );

    // Build request parameters for APP API
    let params: Vec<(&str, String)> = vec![
        ("c_locale", "zh_CN".to_string()),
        ("channel", "master".to_string()),
        ("column", "4".to_string()),
        ("device", "pad".to_string()),
        ("device_name", "android".to_string()),
        ("device_type", "0".to_string()),
        ("disable_rcmd", "0".to_string()),
        ("flush", "5".to_string()),
        ("fnval", "976".to_string()),
        ("fnver", "0".to_string()),
        ("force_host", "2".to_string()),
        ("fourk", "1".to_string()),
        ("guidance", "0".to_string()),
        ("https_url_req", "0".to_string()),
        ("idx", fresh_idx.to_string()),
        ("mobi_app", "android_hd".to_string()),
        ("network", "wifi".to_string()),
        ("platform", "android".to_string()),
        ("player_net", "1".to_string()),
        ("pull", if fresh_idx == 0 { "true".to_string() } else { "false".to_string() }),
        ("qn", "32".to_string()),
        ("recsys_mode", "0".to_string()),
        ("s_locale", "zh_CN".to_string()),
        ("splash_id", "".to_string()),
        ("voice_balance", "0".to_string()),
        ("ps", ps.to_string()),
    ];

    log_debug!("[RustRcmdApp] Built {} request parameters", params.len());

    // Build query string
    let query_string: Vec<String> = params.iter()
        .map(|(key, value)| format!("{}={}", key, value))
        .collect();
    let query_string = query_string.join("&");

    let url = format!("https://app.bilibili.com/x/v2/feed/index?{}", query_string);
    log_debug!("[RustRcmdApp] Request URL prepared (length: {})", url.len());

    // Make HTTP GET request - clone client to avoid holding lock across await
    let client = HTTP_CLIENT.lock().expect("Failed to lock HTTP client").clone();

    log_debug!("[RustRcmdApp] Sending HTTP GET request...");
    let response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .header("buvid", "placeholder")
        .header("fp_local", "1111111111111111111111111111111111111111111111111111111111111111")
        .header("fp_remote", "1111111111111111111111111111111111111111111111111111111111111111")
        .header("session_id", "11111111")
        .header("env", "prod")
        .header("app-key", "android_hd")
        .send()
        .await
        .map_err(|e| {
            log_error!("[RustRcmdApp] Network error: {}", e);
            SerializableError {
                code: "NETWORK_ERROR".to_string(),
                message: format!("Network error: {}", e),
            }
        })?;

    // Check HTTP status
    if !response.status().is_success() {
        let status = response.status();
        log_error!("[RustRcmdApp] HTTP error: {}", status);
        match status.as_u16() {
            401 => {
                log_warn!("[RustRcmdApp] Unauthorized access (401)");
                return Err(SerializableError {
                    code: "UNAUTHORIZED".to_string(),
                    message: "Unauthorized access".to_string(),
                });
            },
            _ => return Err(SerializableError {
                code: "HTTP_ERROR".to_string(),
                message: format!("HTTP error: {}", status),
            }),
        }
    }

    log_debug!("[RustRcmdApp] Response received, status: {}", response.status());

    // Parse response as JSON
    let text = response.text().await
        .map_err(|e| {
            log_error!("[RustRcmdApp] Failed to read response body: {}", e);
            SerializableError {
                code: "NETWORK_ERROR".to_string(),
                message: format!("Failed to read response: {}", e),
            }
        })?;

    log_debug!("[RustRcmdApp] Response body length: {} bytes", text.len());

    // Parse JSON manually to handle APP-specific structure
    let json: serde_json::Value = serde_json::from_str(&text)
        .map_err(|e| {
            log_error!("[RustRcmdApp] JSON parsing error: {}", e);
            SerializableError {
                code: "SERIALIZATION_ERROR".to_string(),
                message: format!("JSON parsing error: {}", e),
            }
        })?;

    // Check API response code
    if json["code"] != 0 {
        let message = json["message"].as_str().unwrap_or("Unknown error");
        log_error!(
            "[RustRcmdApp] API error: code={}, message={}",
            json["code"], message
        );
        return Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: message.to_string(),
        });
    }

    // Extract items from data
    let mut videos = Vec::new();
    let mut skipped_ads = 0;
    let mut skipped_non_video = 0;

    if let Some(data) = json.get("data") {
        if let Some(items) = data.get("items").and_then(|v| v.as_array()) {
            log_debug!("[RustRcmdApp] Processing {} items from response", items.len());

            for (idx, item) in items.iter().enumerate() {
                // Filter for videos only (card_goto == 'av')
                let card_goto = item.get("card_goto")
                    .and_then(|v| v.as_str())
                    .unwrap_or("");

                // Skip ads and non-video content
                if card_goto != "av" {
                    skipped_non_video += 1;
                    continue;
                }

                // Check for ad_info
                if item.get("ad_info").is_some() {
                    skipped_ads += 1;
                    continue;
                }

                // Extract video information
                let args = item.get("args").and_then(|v| v.as_object());

                let bvid = item.get("bvid")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();

                let title = item.get("title")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();

                // Skip if bvid or title is missing
                if bvid.is_empty() || title.is_empty() {
                    log_debug!("[RustRcmdApp] Skipping item {} at index {}: missing bvid or title", idx, idx);
                    continue;
                }

                let cover = item.get("cover")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();

                // Owner information
                let owner_name = args
                    .and_then(|a| a.get("up_name"))
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();

                let owner_mid = args
                    .and_then(|a| a.get("up_id"))
                    .and_then(|v| v.as_i64())
                    .unwrap_or(0);

                let owner_face = args
                    .and_then(|a| a.get("up_face"))
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();

                // Statistics
                let view = item.get("cover_left_text_1")
                    .and_then(|v| v.as_str())
                    .and_then(|s| s.parse::<i64>().ok())
                    .unwrap_or(0);

                let danmu = item.get("cover_left_text_2")
                    .and_then(|v| v.as_str())
                    .and_then(|s| s.parse::<i64>().ok())
                    .unwrap_or(0);

                // Duration
                let player_args = item.get("player_args").and_then(|v| v.as_object());
                let duration = player_args
                    .and_then(|p| p.get("duration"))
                    .and_then(|v| v.as_i64())
                    .unwrap_or(0);

                let aid = player_args
                    .and_then(|p| p.get("aid"))
                    .and_then(|v| v.as_i64())
                    .unwrap_or(0);

                let cid = player_args
                    .and_then(|p| p.get("cid"))
                    .and_then(|v| v.as_i64())
                    .unwrap_or(0);

                // Create RcmdVideoInfo
                let video_info = RcmdVideoInfo {
                    id: Some(aid),
                    bvid,
                    cid: Some(cid),
                    title,
                    pic: Some(cover),
                    duration: duration as i32,
                    pubdate: None,
                    owner: crate::models::rcmd::RcmdOwner {
                        mid: owner_mid,
                        name: owner_name,
                        face: Some(owner_face),
                    },
                    stat: crate::models::rcmd::RcmdStat {
                        view: Some(view),
                        danmaku: Some(danmu),
                        like: None,
                    },
                    goto: Some("av".to_string()),
                    uri: item.get("uri")
                        .and_then(|v| v.as_str())
                        .map(|s| s.to_string()),
                    rcmd_reason: item.get("rcmd_reason")
                        .and_then(|v| v.as_str())
                        .map(|s| s.to_string()),
                    is_followed: false, // App API doesn't provide this directly
                };

                videos.push(video_info);
            }

            log_info!(
                "[RustRcmdApp] Successfully fetched {} video recommendations (skipped {} ads, {} non-video)",
                videos.len(),
                skipped_ads,
                skipped_non_video
            );

            // Log first video for debugging
            if !videos.is_empty() {
                log_debug!(
                    "[RustRcmdApp] First video: {} - {}",
                    videos[0].bvid,
                    videos[0].title
                );
            }
        } else {
            log_warn!("[RustRcmdApp] Response data does not contain 'items' array");
        }
    } else {
        log_warn!("[RustRcmdApp] Response data is null");
    }

    log_info!("[RustRcmdApp] App recommendations completed successfully");
    Ok(videos)
}
