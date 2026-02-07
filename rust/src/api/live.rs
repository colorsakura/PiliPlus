use crate::api::wbi::HTTP_CLIENT;
use crate::error::SerializableError;
use crate::models::common::Image;
use crate::models::{LivePlayUrl, LiveQuality, LiveRoomInfo, LiveStatus};
use flutter_rust_bridge::frb;
use serde::Deserialize;
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

// Bilibili API response wrapper
#[derive(Debug, Deserialize)]
struct BiliResponse<T> {
    code: i32,
    message: Option<String>,
    data: Option<T>,
}

// Bilibili live room info H5 response
#[derive(Debug, Deserialize)]
struct BiliRoomInfoH5 {
    room_info: BiliRoomInfo,
    anchor_info: BiliAnchorInfo,
}

#[derive(Debug, Deserialize)]
struct BiliRoomInfo {
    room_id: i64,
    title: String,
    cover: String,
    live_status: i32,
    online: i64,
    live_start_time: i64,
    area_name: String,
}

#[derive(Debug, Deserialize)]
struct BiliAnchorInfo {
    base_info: BiliBaseInfo,
}

#[derive(Debug, Deserialize)]
struct BiliBaseInfo {
    uname: String,
    face: String,
    uid: i64,
}

// Bilibili live room play info response
#[derive(Debug, Deserialize)]
struct BiliRoomPlayInfo {
    room_id: i64,
    short_id: i64,
    uid: i64,
    is_portrait: bool,
    live_status: i32,
    live_time: i64,
    playurl_info: BiliPlayurlInfo,
}

#[derive(Debug, Deserialize)]
struct BiliPlayurlInfo {
    playurl: BiliPlayurl,
}

#[derive(Debug, Deserialize)]
struct BiliPlayurl {
    #[serde(default)]
    stream: Vec<BiliStream>,
}

#[derive(Debug, Deserialize)]
struct BiliStream {
    #[serde(rename = "protocol_name")]
    protocol_name: String,
    #[serde(default)]
    format: Vec<BiliFormat>,
}

#[derive(Debug, Deserialize)]
struct BiliFormat {
    #[serde(rename = "format_name")]
    format_name: String,
    #[serde(default)]
    codec: Vec<BiliCodec>,
}

#[derive(Debug, Deserialize)]
struct BiliCodec {
    #[serde(rename = "codec_name")]
    codec_name: String,
    #[serde(rename = "current_qn")]
    current_qn: i32,
    #[serde(rename = "base_url")]
    base_url: String,
    #[serde(default)]
    #[serde(rename = "url_info")]
    url_info: Vec<BiliUrlInfo>,
}

#[derive(Debug, Deserialize)]
struct BiliUrlInfo {
    host: String,
    extra: String,
}

/// Convert i32 quality to LiveQuality enum
fn quality_from_i32(qn: i32) -> LiveQuality {
    match qn {
        10000 => LiveQuality::Low,
        20000 => LiveQuality::Medium,
        30000 => LiveQuality::High,
        40000 => LiveQuality::Ultra,
        _ => LiveQuality::Medium,
    }
}

/// Convert LiveQuality enum to i32
fn quality_to_i32(quality: LiveQuality) -> i32 {
    match quality {
        LiveQuality::Low => 10000,
        LiveQuality::Medium => 20000,
        LiveQuality::High => 30000,
        LiveQuality::Ultra => 40000,
    }
}

/// Get live room information from Bilibili API
///
/// Fetches basic room information including title, cover, status, online count, etc.
///
/// # Parameters
/// * `room_id` - Live room ID
///
/// # Returns
/// Result containing LiveRoomInfo with room details
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
/// let room_info = get_live_room_info(123456).await?;
/// ```
#[frb]
pub async fn get_live_room_info(room_id: i64) -> Result<LiveRoomInfo, SerializableError> {
    log_info!(
        "[RustLive] Fetching live room info for room_id: {}",
        room_id
    );

    // Build request URL
    let url = format!(
        "https://api.live.bilibili.com/xlive/web-room/v1/index/getH5InfoByRoom?room_id={}",
        room_id
    );

    log_debug!("[RustLive] Request URL: {}", url);

    // Make HTTP GET request - clone client to avoid holding lock across await
    let client = HTTP_CLIENT
        .lock()
        .expect("Failed to lock HTTP client")
        .clone();

    log_debug!("[RustLive] Sending HTTP GET request...");
    let response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .send()
        .await
        .map_err(|e| {
            log_error!("[RustLive] Network error: {}", e);
            SerializableError {
                code: "NETWORK_ERROR".to_string(),
                message: format!("Network error: {}", e),
            }
        })?;

    // Check HTTP status
    if !response.status().is_success() {
        let status = response.status();
        log_error!("[RustLive] HTTP error: {}", status);
        return Err(SerializableError {
            code: "HTTP_ERROR".to_string(),
            message: format!("HTTP error: {}", status),
        });
    }

    log_debug!(
        "[RustLive] Response received, status: {}",
        response.status()
    );

    // Parse response
    let text = response.text().await.map_err(|e| {
        log_error!("[RustLive] Failed to read response body: {}", e);
        SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: format!("Failed to read response: {}", e),
        }
    })?;

    log_debug!("[RustLive] Response body length: {} bytes", text.len());

    // Parse JSON response
    let bili_response: BiliResponse<BiliRoomInfoH5> = serde_json::from_str(&text).map_err(|e| {
        log_error!("[RustLive] JSON parsing error: {}", e);
        SerializableError {
            code: "SERIALIZATION_ERROR".to_string(),
            message: format!("JSON parsing error: {}", e),
        }
    })?;

    // Check API response code
    if bili_response.code != 0 {
        log_error!(
            "[RustLive] API error: code={}, message={:?}",
            bili_response.code,
            bili_response.message
        );
        return Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: bili_response
                .message
                .unwrap_or_else(|| "Unknown API error".to_string()),
        });
    }

    // Extract room info data
    let data = bili_response.data.ok_or_else(|| {
        log_error!("[RustLive] Response data is null");
        SerializableError {
            code: "PARSE_ERROR".to_string(),
            message: "Missing data field in response".to_string(),
        }
    })?;

    // Convert live status
    let live_status = match data.room_info.live_status {
        1 => LiveStatus::Live,
        0 => LiveStatus::Preview,
        2 => LiveStatus::Round,
        _ => LiveStatus::Preview,
    };

    // Build cover URL (ensure it has protocol)
    let cover_url = if data.room_info.cover.starts_with("http") {
        data.room_info.cover.clone()
    } else if !data.room_info.cover.is_empty() {
        format!("https:{}", data.room_info.cover)
    } else {
        String::new()
    };

    // Build avatar URL
    let avatar_url = if data.anchor_info.base_info.face.starts_with("http") {
        data.anchor_info.base_info.face.clone()
    } else if !data.anchor_info.base_info.face.is_empty() {
        format!("https:{}", data.anchor_info.base_info.face)
    } else {
        String::new()
    };

    let room_info = LiveRoomInfo {
        room_id: data.room_info.room_id,
        uid: data.anchor_info.base_info.uid,
        title: data.room_info.title.clone(),
        description: String::new(), // API doesn't provide description in this endpoint
        cover: Image {
            url: cover_url,
            width: None,
            height: None,
        },
        status: live_status,
        online_count: data.room_info.online as u64,
        area_name: data.room_info.area_name.clone(),
    };

    log_info!(
        "[RustLive] Successfully fetched room info: {} (status: {:?}, online: {})",
        room_info.title,
        room_info.status,
        room_info.online_count
    );

    Ok(room_info)
}

/// Get live stream play URLs from Bilibili API
///
/// Fetches playback URLs for a live room at specified quality level.
/// Returns multiple codec formats (H.264, H.265, AV1) if available.
///
/// # Parameters
/// * `room_id` - Live room ID
/// * `quality` - Quality level (10000=Low, 20000=Medium, 30000=High, 40000=Ultra)
///
/// # Returns
/// Result containing LivePlayUrl with playback URLs
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
/// let play_url = get_live_play_url(123456, 20000).await?;
/// ```
#[frb]
pub async fn get_live_play_url(
    room_id: i64,
    quality: i32,
) -> Result<LivePlayUrl, SerializableError> {
    log_info!(
        "[RustLive] Fetching live play URL for room_id: {}, quality: {}",
        room_id,
        quality
    );

    // Build request URL with quality parameter
    let url = format!(
        "https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo?room_id={}&qn={}&protocol=0,1&format=0,1,2&codec=0,1,2&platform=web",
        room_id, quality
    );

    log_debug!("[RustLive] Request URL: {}", url);

    // Make HTTP GET request - clone client to avoid holding lock across await
    let client = HTTP_CLIENT
        .lock()
        .expect("Failed to lock HTTP client")
        .clone();

    log_debug!("[RustLive] Sending HTTP GET request...");
    let response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .send()
        .await
        .map_err(|e| {
            log_error!("[RustLive] Network error: {}", e);
            SerializableError {
                code: "NETWORK_ERROR".to_string(),
                message: format!("Network error: {}", e),
            }
        })?;

    // Check HTTP status
    if !response.status().is_success() {
        let status = response.status();
        log_error!("[RustLive] HTTP error: {}", status);
        return Err(SerializableError {
            code: "HTTP_ERROR".to_string(),
            message: format!("HTTP error: {}", status),
        });
    }

    log_debug!(
        "[RustLive] Response received, status: {}",
        response.status()
    );

    // Parse response
    let text = response.text().await.map_err(|e| {
        log_error!("[RustLive] Failed to read response body: {}", e);
        SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: format!("Failed to read response: {}", e),
        }
    })?;

    log_debug!("[RustLive] Response body length: {} bytes", text.len());

    // Parse JSON response
    let bili_response: BiliResponse<BiliRoomPlayInfo> =
        serde_json::from_str(&text).map_err(|e| {
            log_error!("[RustLive] JSON parsing error: {}", e);
            SerializableError {
                code: "SERIALIZATION_ERROR".to_string(),
                message: format!("JSON parsing error: {}", e),
            }
        })?;

    // Check API response code
    if bili_response.code != 0 {
        log_error!(
            "[RustLive] API error: code={}, message={:?}",
            bili_response.code,
            bili_response.message
        );
        return Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: bili_response
                .message
                .unwrap_or_else(|| "Unknown API error".to_string()),
        });
    }

    // Extract playurl data
    let data = bili_response.data.ok_or_else(|| {
        log_error!("[RustLive] Response data is null");
        SerializableError {
            code: "PARSE_ERROR".to_string(),
            message: "Missing data field in response".to_string(),
        }
    })?;

    // Extract stream data and build URLs
    let mut urls = Vec::new();

    for stream in &data.playurl_info.playurl.stream {
        log_debug!(
            "[RustLive] Processing stream: protocol={}",
            stream.protocol_name
        );

        for format in &stream.format {
            log_debug!("[RustLive] Processing format: {}", format.format_name);

            for codec in &format.codec {
                // Build full URL from base_url and url_info
                if !codec.base_url.is_empty() {
                    // If url_info is available, build complete URL
                    if let Some(url_info) = codec.url_info.first() {
                        let full_url =
                            format!("{}{}{}", url_info.host, codec.base_url, url_info.extra);
                        log_debug!(
                            "[RustLive] Found URL: codec={}, qn={}",
                            codec.codec_name,
                            codec.current_qn
                        );
                        urls.push(full_url);
                    } else {
                        // Otherwise use base_url directly
                        log_debug!(
                            "[RustLive] Found URL (no url_info): codec={}, qn={}",
                            codec.codec_name,
                            codec.current_qn
                        );
                        urls.push(codec.base_url.clone());
                    }
                }
            }
        }
    }

    // Convert quality to enum
    let quality_enum = quality_from_i32(quality);

    log_info!(
        "[RustLive] Successfully fetched {} play URLs (quality: {:?})",
        urls.len(),
        quality_enum
    );

    // Debug: log first URL if available
    if !urls.is_empty() {
        log_debug!("[RustLive] First URL: {}", urls[0]);
    } else {
        log_warn!("[RustLive] No URLs found in response");
    }

    Ok(LivePlayUrl {
        quality: quality_enum,
        urls,
    })
}
