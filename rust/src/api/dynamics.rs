use crate::api::wbi::HTTP_CLIENT;
use crate::error::{ApiError, SerializableError};
use crate::models::common::Image;
use crate::models::{DynamicsItem, DynamicsList};
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

// Bilibili API response wrapper for dynamics
#[derive(Debug, Deserialize)]
struct BiliResponse<T> {
    code: i32,
    message: Option<String>,
    data: Option<T>,
}

// Bilibili dynamics list data structure
#[derive(Debug, Deserialize)]
struct BiliDynamicsListData {
    items: Option<Vec<BiliDynamicItem>>,
    #[serde(default)]
    has_more: bool,
    offset: Option<BiliOffset>,
}

#[derive(Debug, Deserialize)]
struct BiliOffset {
    #[serde(rename = "__str__")]
    offset_str: String,
}

// Bilibili dynamic item structure
#[derive(Debug, Deserialize)]
struct BiliDynamicItem {
    id_str: String,
    #[serde(rename = "mid")]
    uid: i64,
    modules: Vec<BiliModule>,
}

#[derive(Debug, Deserialize)]
struct BiliModule {
    #[serde(rename = "module_author")]
    author: Option<BiliAuthor>,
    #[serde(rename = "module_dynamic")]
    dynamic: Option<BiliDynamicContent>,
}

#[derive(Debug, Deserialize)]
struct BiliAuthor {
    name: String,
    face: String,
}

#[derive(Debug, Deserialize)]
struct BiliDynamicContent {
    desc: Option<BiliDynamicDesc>,
    major: Option<BiliDynamicMajor>,
}

#[derive(Debug, Deserialize)]
struct BiliDynamicDesc {
    text: String,
}

#[derive(Debug, Deserialize)]
struct BiliDynamicMajor {
    #[serde(rename = "type")]
    content_type: String,
    archive: Option<BiliArchive>,
    #[serde(rename = "opus")]
    opus: Option<BiliOpus>,
}

#[derive(Debug, Deserialize)]
struct BiliArchive {
    cover: String,
    title: String,
}

#[derive(Debug, Deserialize)]
struct BiliOpus {
    pics: Option<Vec<BiliPicture>>,
}

#[derive(Debug, Deserialize)]
struct BiliPicture {
    url: String,
}

// Bilibili dynamic detail response structure
#[derive(Debug, Deserialize)]
struct BiliDynamicDetailData {
    item: BiliDynamicItem,
}

/// Convert Bilibili dynamic to internal DynamicsItem model
fn convert_dynamic_item(bili_item: &BiliDynamicItem) -> Option<DynamicsItem> {
    // Extract author info
    let author = bili_item.modules.iter().find_map(|m| m.author.as_ref())?;
    let dynamic_content = bili_item.modules.iter().find_map(|m| m.dynamic.as_ref())?;

    // Build avatar URL
    let avatar_url = if author.face.starts_with("http") {
        author.face.clone()
    } else {
        format!("https:{}", author.face)
    };

    // Extract content text
    let content = dynamic_content
        .desc
        .as_ref()
        .map(|d| d.text.clone())
        .unwrap_or_default();

    // Extract images
    let images = if let Some(opus) = &dynamic_content.major.as_ref()?.opus {
        opus.pics
            .as_ref()
            .map(|pics| {
                pics.iter()
                    .map(|p| Image {
                        url: p.url.clone(),
                        width: None,
                        height: None,
                    })
                    .collect()
            })
            .unwrap_or_default()
    } else {
        Vec::new()
    };

    Some(DynamicsItem {
        id: bili_item.id_str.clone(),
        uid: bili_item.uid,
        username: author.name.clone(),
        avatar: Image {
            url: avatar_url,
            width: None,
            height: None,
        },
        content,
        images,
        publish_time: 0, // Not available in basic response
        like_count: 0,   // Not available in basic response
        reply_count: 0,  // Not available in basic response
    })
}

/// Get user dynamics/posts from Bilibili API
///
/// Fetches dynamics for a user with pagination support.
///
/// # Parameters
/// * `uid` - User ID
/// * `offset` - Pagination offset string
///
/// # Returns
/// Result containing DynamicsList with dynamic items and pagination info
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
/// let dynamics = get_user_dynamics(123456, None).await?;
/// ```
#[frb]
pub async fn get_user_dynamics(
    uid: i64,
    offset: Option<String>,
) -> Result<DynamicsList, SerializableError> {
    log_info!(
        "[RustDynamics] Fetching user dynamics: uid={}, offset={:?}",
        uid,
        offset
    );

    // Build request URL
    let mut url = format!(
        "https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all?timezone_offset=-480&features=itemOpusStyle,listOnlyfans&host_mid={}",
        uid
    );

    if let Some(off) = &offset {
        url.push_str(&format!("&offset={}", off));
    }

    log_debug!("[RustDynamics] Request URL: {}", url);

    // Make HTTP GET request - clone client to avoid holding lock across await
    let client = HTTP_CLIENT
        .lock()
        .expect("Failed to lock HTTP client")
        .clone();

    log_debug!("[RustDynamics] Sending HTTP GET request...");
    let response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .send()
        .await
        .map_err(|e| {
            log_error!("[RustDynamics] Network error: {}", e);
            SerializableError {
                code: "NETWORK_ERROR".to_string(),
                message: format!("Network error: {}", e),
            }
        })?;

    // Check HTTP status
    if !response.status().is_success() {
        let status = response.status();
        log_error!("[RustDynamics] HTTP error: {}", status);
        return Err(SerializableError {
            code: "HTTP_ERROR".to_string(),
            message: format!("HTTP error: {}", status),
        });
    }

    log_debug!(
        "[RustDynamics] Response received, status: {}",
        response.status()
    );

    // Parse response
    let text = response.text().await.map_err(|e| {
        log_error!("[RustDynamics] Failed to read response body: {}", e);
        SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: format!("Failed to read response: {}", e),
        }
    })?;

    log_debug!("[RustDynamics] Response body length: {} bytes", text.len());

    // Parse JSON response
    let bili_response: BiliResponse<BiliDynamicsListData> =
        serde_json::from_str(&text).map_err(|e| {
            log_error!("[RustDynamics] JSON parsing error: {}", e);
            SerializableError {
                code: "SERIALIZATION_ERROR".to_string(),
                message: format!("JSON parsing error: {}", e),
            }
        })?;

    // Check API response code
    if bili_response.code != 0 {
        log_error!(
            "[RustDynamics] API error: code={}, message={:?}",
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

    // Extract dynamics data
    let data = bili_response.data.ok_or_else(|| {
        log_error!("[RustDynamics] Response data is null");
        SerializableError {
            code: "PARSE_ERROR".to_string(),
            message: "Missing data field in response".to_string(),
        }
    })?;

    // Convert dynamics
    let dynamics_items: Vec<DynamicsItem> = if let Some(items) = data.items {
        items
            .iter()
            .filter_map(|item| convert_dynamic_item(item))
            .collect()
    } else {
        log_warn!("[RustDynamics] No dynamics found in response");
        Vec::new()
    };

    let next_offset = data.offset.map(|off| off.offset_str);

    log_info!(
        "[RustDynamics] Successfully fetched {} dynamics (has_more: {})",
        dynamics_items.len(),
        data.has_more
    );

    // Debug: log first dynamic if available
    if !dynamics_items.is_empty() {
        log_debug!(
            "[RustDynamics] First dynamic: {} - {}",
            dynamics_items[0].username,
            dynamics_items[0].content
        );
    }

    Ok(DynamicsList {
        items: dynamics_items,
        has_more: data.has_more,
        offset: next_offset,
    })
}

/// Get dynamics detail by ID from Bilibili API
///
/// Fetches a single dynamic post by its ID.
///
/// # Parameters
/// * `dynamic_id` - Dynamic ID string
///
/// # Returns
/// Result containing DynamicsItem with full dynamic details
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
/// let dynamic = get_dynamics_detail("123456789".to_string()).await?;
/// ```
#[frb]
pub async fn get_dynamics_detail(dynamic_id: String) -> Result<DynamicsItem, SerializableError> {
    log_info!(
        "[RustDynamics] Fetching dynamics detail: id={}",
        dynamic_id
    );

    // Build request URL
    let url = format!(
        "https://api.bilibili.com/x/polymer/web-dynamic/v1/detail?timezone_offset=-480&features=itemOpusStyle&id={}",
        dynamic_id
    );

    log_debug!("[RustDynamics] Request URL: {}", url);

    // Make HTTP GET request - clone client to avoid holding lock across await
    let client = HTTP_CLIENT
        .lock()
        .expect("Failed to lock HTTP client")
        .clone();

    log_debug!("[RustDynamics] Sending HTTP GET request...");
    let response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .send()
        .await
        .map_err(|e| {
            log_error!("[RustDynamics] Network error: {}", e);
            SerializableError {
                code: "NETWORK_ERROR".to_string(),
                message: format!("Network error: {}", e),
            }
        })?;

    // Check HTTP status
    if !response.status().is_success() {
        let status = response.status();
        log_error!("[RustDynamics] HTTP error: {}", status);
        return Err(SerializableError {
            code: "HTTP_ERROR".to_string(),
            message: format!("HTTP error: {}", status),
        });
    }

    log_debug!(
        "[RustDynamics] Response received, status: {}",
        response.status()
    );

    // Parse response
    let text = response.text().await.map_err(|e| {
        log_error!("[RustDynamics] Failed to read response body: {}", e);
        SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: format!("Failed to read response: {}", e),
        }
    })?;

    log_debug!(
        "[RustDynamics] Response body length: {} bytes",
        text.len()
    );

    // Parse JSON response
    let bili_response: BiliResponse<BiliDynamicDetailData> =
        serde_json::from_str(&text).map_err(|e| {
            log_error!("[RustDynamics] JSON parsing error: {}", e);
            SerializableError {
                code: "SERIALIZATION_ERROR".to_string(),
                message: format!("JSON parsing error: {}", e),
            }
        })?;

    // Check API response code
    if bili_response.code != 0 {
        log_error!(
            "[RustDynamics] API error: code={}, message={:?}",
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

    // Extract dynamic data
    let data = bili_response.data.ok_or_else(|| {
        log_error!("[RustDynamics] Response data is null");
        SerializableError {
            code: "PARSE_ERROR".to_string(),
            message: "Missing data field in response".to_string(),
        }
    })?;

    // Convert dynamic item
    let dynamic_item = convert_dynamic_item(&data.item).ok_or_else(|| {
        log_error!("[RustDynamics] Failed to convert dynamic item");
        SerializableError {
            code: "PARSE_ERROR".to_string(),
            message: "Failed to parse dynamic item structure".to_string(),
        }
    })?;

    log_info!(
        "[RustDynamics] Successfully fetched dynamic detail: {} - {}",
        dynamic_item.username,
        dynamic_item.content
    );

    Ok(dynamic_item)
}
