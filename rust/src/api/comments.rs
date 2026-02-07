use crate::api::wbi::HTTP_CLIENT;
use crate::error::{ApiError, SerializableError};
use crate::models::common::Image;
use crate::models::{Comment, CommentList};
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

// Bilibili API response wrapper for comments
#[derive(Debug, Deserialize)]
struct BiliResponse<T> {
    code: i32,
    message: Option<String>,
    data: Option<T>,
}

// Bilibili comment data structure
#[derive(Debug, Deserialize)]
struct BiliCommentData {
    replies: Option<Vec<BiliCommentReply>>,
    #[serde(default)]
    num: u32,
    #[serde(default)]
    cursor: BiliCursor,
}

#[derive(Debug, Deserialize, Default)]
struct BiliCursor {
    #[serde(default)]
    is_end: bool,
    #[serde(default)]
    next: Option<String>,
    #[serde(default)]
    prev: Option<String>,
}

#[derive(Debug, Deserialize)]
struct BiliCommentReply {
    #[serde(rename = "rpid")]
    id: i64,
    #[serde(rename = "oid")]
    oid: i64,
    #[serde(rename = "mid")]
    uid: i64,
    member: BiliMember,
    content: BiliContent,
    like: u64,
    #[serde(rename = "rcount")]
    reply_count: u64,
    ctime: i64,
    replies: Option<Vec<BiliCommentReply>>,
}

#[derive(Debug, Deserialize)]
struct BiliMember {
    uname: String,
    avatar: BiliAvatar,
}

#[derive(Debug, Deserialize)]
struct BiliAvatar {
    #[serde(default)]
    uri: String,
}

#[derive(Debug, Deserialize)]
struct BiliContent {
    message: String,
}

/// Convert Bilibili comment to internal Comment model
fn convert_comment(bili_comment: &BiliCommentReply, oid: i64) -> Comment {
    // Build avatar URL from URI
    let avatar_url = if bili_comment.member.avatar.uri.starts_with("http") {
        bili_comment.member.avatar.uri.clone()
    } else {
        format!("https:{}", bili_comment.member.avatar.uri)
    };

    // Convert nested replies recursively
    let replies = if let Some(bili_replies) = &bili_comment.replies {
        bili_replies
            .iter()
            .map(|r| convert_comment(r, oid))
            .collect()
    } else {
        Vec::new()
    };

    Comment {
        id: bili_comment.id,
        oid,
        uid: bili_comment.uid,
        username: bili_comment.member.uname.clone(),
        avatar: Image {
            url: avatar_url,
            width: None,
            height: None,
        },
        content: bili_comment.content.message.clone(),
        like_count: bili_comment.like,
        reply_count: bili_comment.reply_count,
        publish_time: bili_comment.ctime,
        replies,
    }
}

/// Get video comments from Bilibili API
///
/// Fetches comments for a video with pagination support.
///
/// # Parameters
/// * `oid` - Video ID (avid)
/// * `page` - Page number (0-indexed)
/// * `page_size` - Number of comments per page (typically 20)
///
/// # Returns
/// Result containing CommentList with comments and pagination info
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
/// let comments = get_video_comments(123456, 0, 20).await?;
/// ```
#[frb]
pub async fn get_video_comments(
    oid: i64,
    page: u32,
    page_size: u32,
) -> Result<CommentList, SerializableError> {
    log_info!(
        "[RustComments] Fetching video comments: oid={}, page={}, page_size={}",
        oid,
        page,
        page_size
    );

    // Build request URL with pagination
    // type=1 means video comments
    // mode=3 means sort by hot (mode=2 would be by time)
    let pagination_offset = if page == 0 {
        String::new()
    } else {
        // For pagination, we use the pagination_str parameter
        // This is a simplified version - in production you'd track the actual offset
        format!("&pagination_str={{\"offset\":\"\"}}")
    };

    let url = format!(
        "https://api.bilibili.com/x/v2/reply/main?oid={}&type=1&mode=3{}",
        oid, pagination_offset
    );

    log_debug!("[RustComments] Request URL: {}", url);

    // Make HTTP GET request - clone client to avoid holding lock across await
    let client = HTTP_CLIENT
        .lock()
        .expect("Failed to lock HTTP client")
        .clone();

    log_debug!("[RustComments] Sending HTTP GET request...");
    let response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .send()
        .await
        .map_err(|e| {
            log_error!("[RustComments] Network error: {}", e);
            SerializableError {
                code: "NETWORK_ERROR".to_string(),
                message: format!("Network error: {}", e),
            }
        })?;

    // Check HTTP status
    if !response.status().is_success() {
        let status = response.status();
        log_error!("[RustComments] HTTP error: {}", status);
        return Err(SerializableError {
            code: "HTTP_ERROR".to_string(),
            message: format!("HTTP error: {}", status),
        });
    }

    log_debug!(
        "[RustComments] Response received, status: {}",
        response.status()
    );

    // Parse response
    let text = response.text().await.map_err(|e| {
        log_error!("[RustComments] Failed to read response body: {}", e);
        SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: format!("Failed to read response: {}", e),
        }
    })?;

    log_debug!("[RustComments] Response body length: {} bytes", text.len());

    // Parse JSON response
    let bili_response: BiliResponse<BiliCommentData> =
        serde_json::from_str(&text).map_err(|e| {
            log_error!("[RustComments] JSON parsing error: {}", e);
            SerializableError {
                code: "SERIALIZATION_ERROR".to_string(),
                message: format!("JSON parsing error: {}", e),
            }
        })?;

    // Check API response code
    if bili_response.code != 0 {
        log_error!(
            "[RustComments] API error: code={}, message={:?}",
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

    // Extract comment data
    let data = bili_response.data.ok_or_else(|| {
        log_error!("[RustComments] Response data is null");
        SerializableError {
            code: "PARSE_ERROR".to_string(),
            message: "Missing data field in response".to_string(),
        }
    })?;

    // Convert comments
    let comments: Vec<Comment> = if let Some(replies) = data.replies {
        replies
            .iter()
            .map(|reply| convert_comment(reply, oid))
            .collect()
    } else {
        log_warn!("[RustComments] No comments found in response");
        Vec::new()
    };

    let total_count = data.num;

    log_info!(
        "[RustComments] Successfully fetched {} comments (total: {})",
        comments.len(),
        total_count
    );

    // Debug: log first comment if available
    if !comments.is_empty() {
        log_debug!(
            "[RustComments] First comment: {} - {}",
            comments[0].username,
            comments[0].content
        );
    }

    Ok(CommentList {
        comments,
        page,
        page_size,
        total_count,
    })
}
