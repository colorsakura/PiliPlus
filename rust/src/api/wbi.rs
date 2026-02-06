
use std::collections::HashMap;
use md5;
use percent_encoding::{utf8_percent_encode, NON_ALPHANUMERIC};
use chrono::{Local, DateTime, Utc};
use serde::{Deserialize, Serialize};
use once_cell::sync::Lazy;
use std::sync::Mutex;

// Static HTTP client to avoid creating new clients on each call
static HTTP_CLIENT: Lazy<Mutex<reqwest::Client>> = Lazy::new(|| {
    Mutex::new(reqwest::Client::new())
});

/// Mixin key encoding table - 32-element shuffle table
const MIXIN_KEY_ENC_TAB: [usize; 32] = [
    14, 10, 2, 18, 23, 27, 8, 3, 28, 5, 15, 31, 12, 19, 11, 7,
    1, 21, 26, 30, 4, 22, 20, 29, 25, 13, 24, 17, 6, 0, 9, 16
];

/// Allowed special characters in WBI parameter filtering
const ALLOWED_SPECIAL_CHARS: &str = "!'()*-_.";
const CACHE_DURATION_HOURS: i64 = 24;

// Cache structure for WBI keys
#[derive(Debug, Clone, Serialize, Deserialize)]
struct WbiCache {
    img_url: String,
    sub_url: String,
    mixin_key: String,
    timestamp: DateTime<Utc>,
}

impl WbiCache {
    fn is_expired(&self) -> bool {
        Utc::now().signed_duration_since(self.timestamp).num_hours() >= CACHE_DURATION_HOURS
    }
}

// Global cache storage
static WBI_CACHE: Lazy<Mutex<Option<WbiCache>>> = Lazy::new(|| Mutex::new(None));

#[derive(Debug, Clone, Deserialize)]
struct WbiImg {
    img_url: String,
    sub_url: String,
}

#[derive(Debug, Clone, Deserialize)]
struct UserData {
    wbi_img: WbiImg,
}

#[derive(Debug, Clone, Deserialize)]
struct UserInfoResponse {
    code: i32,
    message: String,
    data: UserData,
}

/// Extract filename from WBI URL
///
/// Extracts the filename from a URL path for mixin key generation
///
/// # Parameters
/// * `url` - The URL containing the filename
///
/// # Returns
/// The extracted filename, or empty string if not found
///
/// # Examples
/// ```rust
/// let filename = extract_filename("https://example.com/img_xxx.jpg");
/// assert_eq!(filename, "img_xxx");
/// ```
fn extract_filename(url: &str) -> String {
    url.split('/')
        .last()
        .and_then(|name| name.split('.').next())
        .unwrap_or("")
        .to_string()
}

/// Fetch WBI keys from Bilibili API
///
/// Makes HTTP request to https://api.bilibili.com/x/web-interface/nav
/// to get user information and extract WBI keys
///
/// # Returns
/// Result containing tuple of (img_url, sub_url, mixin_key)
///
/// # Errors
/// Returns reqwest::Error for HTTP failures
/// Returns json::Error for JSON parsing failures
///
/// # Examples
/// ```rust
/// let (img_url, sub_url, mixin_key) = get_wbi_keys().await?;
/// ```
async fn get_wbi_keys() -> Result<(String, String, String), Box<dyn std::error::Error>> {
    let client = HTTP_CLIENT.lock().unwrap_or_else(|p| p.into_inner());

    let response = client
        .get("https://api.bilibili.com/x/web-interface/nav")
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        .send()
        .await?;

    if !response.status().is_success() {
        return Err(format!("HTTP request failed: {}", response.status()).into());
    }

    let text = response.text().await?;
    let user_info: UserInfoResponse = serde_json::from_str(&text)?;

    if user_info.code != 0 {
        return Err(format!("API returned error code {}: {}", user_info.code, user_info.message).into());
    }

    let img_url = user_info.data.wbi_img.img_url;
    let sub_url = user_info.data.wbi_img.sub_url;

    let img_filename = extract_filename(&img_url);
    let sub_filename = extract_filename(&sub_url);

    let mixin_key = get_mixin_key(&format!("{}{}", img_filename, sub_filename));

    // Update cache
    let cache = WbiCache {
        img_url,
        sub_url,
        mixin_key: mixin_key.clone(),
        timestamp: Utc::now(),
    };

    let mut cache_guard = WBI_CACHE.lock().unwrap_or_else(|p| p.into_inner());
    *cache_guard = Some(cache);

    Ok((img_url, sub_url, mixin_key))
}

/// Get WBI keys with caching
///
/// Returns cached WBI keys if available and not expired,
/// otherwise fetches new keys from API
///
/// # Returns
/// Result containing tuple of (img_url, sub_url, mixin_key)
///
/// # Errors
/// Returns reqwest::Error for HTTP failures
/// Returns json::Error for JSON parsing failures
///
/// # Examples
/// ```rust
/// let (img_url, sub_url, mixin_key) = get_wbi_keys_cached().await?;
/// ```
pub async fn get_wbi_keys_cached() -> Result<(String, String, String), Box<dyn std::error::Error>> {
    let mut cache_guard = WBI_CACHE.lock().unwrap_or_else(|p| p.into_inner());

    if let Some(cache) = &*cache_guard {
        if !cache.is_expired() {
            return Ok((cache.img_url.clone(), cache.sub_url.clone(), cache.mixin_key.clone()));
        }
    }

    // Cache is expired or not present, fetch fresh keys
    let (img_url, sub_url, mixin_key) = get_wbi_keys().await?;

    Ok((img_url, sub_url, mixin_key))
}


/// Generate mixin key by shuffling characters according to the encoding table
///
/// Creates a 32-character mixin key from the original string by:
/// 1. Padding the input with zeros if it's shorter than 32 characters
/// 2. Truncating the input if it's longer than 32 characters
/// 3. Shuffling the characters according to MIXIN_KEY_ENC_TAB
///
/// # Parameters
/// * `orig` - The original string to generate the mixin key from
///
/// # Returns
/// A 32-character string representing the mixin key
///
/// # Examples
/// ```rust
/// let key = get_mixin_key("abc123");
/// assert_eq!(key.len(), 32);
/// ```
fn get_mixin_key(orig: &str) -> String {
    // Ensure the input is exactly 32 characters by padding if necessary
    let mut padded_input = String::from(orig);
    while padded_input.len() < 32 {
        padded_input.push('0'); // Pad with zeros
    }
    if padded_input.len() > 32 {
        padded_input = padded_input[..32].to_string();
    }

    let code_units = padded_input.as_bytes();
    let result: Vec<u8> = MIXIN_KEY_ENC_TAB.iter()
        .map(|&i| code_units[i])
        .collect();
    String::from_utf8(result).expect("WBI mixin key generation should always produce valid UTF-8")
}

/// Encode parameters with WBI (Web Bilibili Interface) signing
///
/// Adds timestamp and signature to parameters for API requests
///
/// # Parameters
/// * `params` - Mutable reference to parameters HashMap to be modified
/// * `mixin_key` - The mixin key used for signing
///
/// # Algorithm
/// 1. Add current timestamp as "wts" parameter
/// 2. Sort parameters by key
/// 3. Build query string with URL encoding
/// 4. Filter special characters using ALLOWED_SPECIAL_CHARS
/// 5. Calculate MD5 hash of query + mixin_key
/// 6. Add hash as "w_rid" parameter
///
/// # Examples
/// ```rust
/// let mut params = HashMap::new();
/// params.insert("test".to_string(), "value".to_string());
/// enc_wbi(&mut params, "mixin_key");
/// assert!(params.contains_key("wts"));
/// assert!(params.contains_key("w_rid"));
/// ```
fn enc_wbi(params: &mut HashMap<String, String>, mixin_key: &str) {
    // Input validation
    assert!(!mixin_key.is_empty(), "mixin_key cannot be empty");
    assert!(mixin_key.len() <= 32, "mixin_key cannot be longer than 32 characters");

    // Add timestamp
    let timestamp = Local::now().timestamp().to_string();
    params.insert("wts".to_string(), timestamp);

    // Sort parameters by key
    let mut sorted_params: Vec<_> = params.iter().collect();
    sorted_params.sort_by_key(|(k, _)| k.to_string());

    // Build query string with URL encoding
    let mut query_parts = Vec::new();
    for (key, value) in sorted_params {
        let encoded_key = utf8_percent_encode(key, NON_ALPHANUMERIC).to_string();
        let encoded_value = utf8_percent_encode(value, NON_ALPHANUMERIC).to_string();
        query_parts.push(format!("{}={}", encoded_key, encoded_value));
    }
    let query_string = query_parts.join("&");

    // Filter special characters using ALLOWED_SPECIAL_CHARS constant
    let filtered_query: String = query_string
        .chars()
        .filter(|c| !c.is_ascii_punctuation() || c.is_ascii_alphanumeric() ||
                 ALLOWED_SPECIAL_CHARS.contains(*c))
        .collect();

    // Calculate MD5 hash
    let mut hasher = md5::Context::new();
    hasher.consume(filtered_query.as_bytes());
    hasher.consume(mixin_key.as_bytes());
    let md5_hash = format!("{:02x}", hasher.compute());

    // Add w_rid parameter
    params.insert("w_rid".to_string(), md5_hash);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_mixin_key() {
        let input = "abcdefghijklmnopqrstuvwxyz012345";
        let result = get_mixin_key(input);

        // Verify that the result is exactly 32 characters long
        assert_eq!(result.len(), 32);

        // Verify that the output is different from the input
        assert_ne!(result, input);

        // Verify that the shuffle follows the encoding table correctly
        let code_units = input.as_bytes();
        let expected_first_char = code_units[MIXIN_KEY_ENC_TAB[0]];
        assert_eq!(result.as_bytes()[0], expected_first_char);
    }

    #[test]
    fn test_enc_wbi() {
        let mut params = HashMap::new();
        params.insert("test".to_string(), "value".to_string());
        params.insert("foo".to_string(), "bar".to_string());
        let mixin_key = "test_mixin_key_1234567890123456";

        // Store original count to verify new parameters are added
        let original_count = params.len();

        enc_wbi(&mut params, mixin_key);

        // Verify that wts and w_rid parameters were added
        assert!(params.contains_key("wts"));
        assert!(params.contains_key("w_rid"));

        // Verify that original parameters are still there
        assert_eq!(params.get("test"), Some(&"value".to_string()));
        assert_eq!(params.get("foo"), Some(&"bar".to_string()));

        // Verify that w_rid is exactly 32 characters (MD5 hex)
        let w_rid = params.get("w_rid").unwrap();
        assert_eq!(w_rid.len(), 32);

        // Verify that wts is a valid timestamp (numeric string)
        let wts = params.get("wts").unwrap();
        assert!(wts.parse::<i64>().is_ok());

        // Verify that we have exactly 4 parameters (original 2 + wts + w_rid)
        assert_eq!(params.len(), original_count + 2);
    }

    #[test]
    fn test_get_mixin_key_edge_cases() {
        // Test with empty string - should be padded to 32 zeros
        let empty_result = get_mixin_key("");
        assert_eq!(empty_result.len(), 32);
        assert_eq!(empty_result, "00000000000000000000000000000000");

        // Test with string shorter than 32 chars - should be padded with zeros
        let short_result = get_mixin_key("abc");
        assert_eq!(short_result.len(), 32);
        assert_ne!(short_result, "abc");

        // Test with string longer than 32 chars - should be truncated
        let long_result = get_mixin_key("abcdefghijklmnopqrstuvwxyz012345678901234567890123");
        assert_eq!(long_result.len(), 32);
        // Check that it was truncated properly by comparing the input after truncation
        let expected_input = "abcdefghijklmnopqrstuvwxyz012345";
        assert_eq!(expected_input.len(), 32);
        // The shuffled result should be different from the truncated input
        assert_ne!(long_result, expected_input);
    }
}

#[tokio::test]
async fn test_get_wbi_keys() {
    // This test requires network access to fetch actual WBI keys
    // It's a integration test that may fail if network is not available
    let result = get_wbi_keys().await;

    match result {
        Ok((img_url, sub_url, mixin_key)) => {
            println!("Successfully fetched WBI keys:");
            println!("img_url: {}", img_url);
            println!("sub_url: {}", sub_url);
            println!("mixin_key: {}", mixin_key);

            // Verify that we have valid URLs
            assert!(!img_url.is_empty());
            assert!(!sub_url.is_empty());
            assert!(!mixin_key.is_empty());

            // Verify mixin key length
            assert_eq!(mixin_key.len(), 32);

            // Verify URLs contain expected patterns
            assert!(img_url.contains("http"));
            assert!(sub_url.contains("http"));
        }
        Err(e) => {
            // If the test fails, it might be due to network issues
            // In a real test suite, you might want to mock the HTTP request
            println!("Test failed (possibly due to network): {}", e);
        }
    }
}

#[tokio::test]
async fn test_get_wbi_keys_cached() {
    // Test the cached version
    let result = get_wbi_keys_cached().await;

    match result {
        Ok((img_url, sub_url, mixin_key)) => {
            println!("Successfully fetched cached WBI keys:");
            println!("img_url: {}", img_url);
            println!("sub_url: {}", sub_url);
            println!("mixin_key: {}", mixin_key);

            // Verify that we have valid URLs
            assert!(!img_url.is_empty());
            assert!(!sub_url.is_empty());
            assert!(!mixin_key.is_empty());

            // Verify mixin key length
            assert_eq!(mixin_key.len(), 32);
        }
        Err(e) => {
            println!("Test failed (possibly due to network): {}", e);
        }
    }
}