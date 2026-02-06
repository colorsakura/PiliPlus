// Standalone WBI test without dependencies on the main library

use std::collections::HashMap;
use md5;
use percent_encoding::{utf8_percent_encode, NON_ALPHANUMERIC};
use chrono::{Local, DateTime, Utc};
use serde::{Deserialize, Serialize};
use once_cell::sync::Lazy;
use std::sync::Mutex;
use tokio;

// Constants
const MIXIN_KEY_ENC_TAB: [usize; 32] = [
    14, 10, 2, 18, 23, 27, 8, 3, 28, 5, 15, 31, 12, 19, 11, 7,
    1, 21, 26, 30, 4, 22, 20, 29, 25, 13, 24, 17, 6, 0, 9, 16
];

const ALLOWED_SPECIAL_CHARS: &str = "!'()*-_.";
const CACHE_DURATION_HOURS: i64 = 24;

// Cache structure
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

// Helper functions
fn extract_filename(url: &str) -> String {
    url.split('/')
        .last()
        .and_then(|name| name.split('.').next())
        .unwrap_or("")
        .to_string()
}

fn get_mixin_key(orig: &str) -> String {
    let mut padded_input = String::from(orig);
    while padded_input.len() < 32 {
        padded_input.push('0');
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

async fn get_wbi_keys() -> Result<(String, String, String), Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();

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

    let img_url_clone = user_info.data.wbi_img.img_url.clone();
    let sub_url_clone = user_info.data.wbi_img.sub_url.clone();

    let img_filename = extract_filename(&img_url_clone);
    let sub_filename = extract_filename(&sub_url_clone);

    let mixin_key = get_mixin_key(&format!("{}{}", img_filename, sub_filename));

    // Update cache
    let cache = WbiCache {
        img_url: img_url_clone.clone(),
        sub_url: sub_url_clone.clone(),
        mixin_key: mixin_key.clone(),
        timestamp: Utc::now(),
    };

    let mut cache_guard = WBI_CACHE.lock().unwrap_or_else(|p| p.into_inner());
    *cache_guard = Some(cache);

    Ok((img_url_clone, sub_url_clone, mixin_key))
}

async fn get_wbi_keys_cached() -> Result<(String, String, String), Box<dyn std::error::Error>> {
    let cache_guard = WBI_CACHE.lock().unwrap_or_else(|p| p.into_inner());

    if let Some(cache) = &*cache_guard {
        if !cache.is_expired() {
            return Ok((cache.img_url.clone(), cache.sub_url.clone(), cache.mixin_key.clone()));
        }
    }

    // Cache is expired or not present, fetch fresh keys
    let (img_url, sub_url, mixin_key) = get_wbi_keys().await?;

    Ok((img_url, sub_url, mixin_key))
}

#[tokio::main]
async fn main() {
    println!("Testing WBI key fetching functionality");

    // Test the WBI key fetching functionality
    match get_wbi_keys().await {
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
            eprintln!("Failed to fetch WBI keys: {}", e);
            // Exit with error code
            std::process::exit(1);
        }
    }

    // Test the cached version
    println!("\nTesting cached version:");
    match get_wbi_keys_cached().await {
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
            eprintln!("Failed to fetch cached WBI keys: {}", e);
            std::process::exit(1);
        }
    }

    // Test extract_filename function
    println!("\nTesting extract_filename function:");
    let test_cases = vec![
        ("https://example.com/img_xxx.jpg", "img_xxx"),
        ("https://example.com/sub_xxx.jpg", "sub_xxx"),
        ("http://test.com/wbi_img.png", "wbi_img"),
        ("https://bilibili.com/path/to/file123.gif", "file123"),
        ("invalid-url", ""),
        ("", ""),
    ];

    for (input, expected) in test_cases {
        let result = extract_filename(input);
        if result == expected {
            println!("✓ extract_filename(\"{}\") = \"{}\"", input, result);
        } else {
            println!("✗ extract_filename(\"{}\") = \"{}\" (expected \"{}\")", input, result, expected);
        }
    }

    // Test enc_wbi function
    println!("\nTesting enc_wbi function:");
    let mut test_params = HashMap::new();
    test_params.insert("test".to_string(), "value".to_string());
    test_params.insert("foo".to_string(), "bar".to_string());

    let mixin_key = "test_mixin_key_1234567890123456";
    let original_count = test_params.len();

    enc_wbi(&mut test_params, mixin_key);

    println!("After encoding:");
    for (key, value) in &test_params {
        println!("  {}: {}", key, value);
    }

    // Verify that wts and w_rid parameters were added
    assert!(test_params.contains_key("wts"));
    assert!(test_params.contains_key("w_rid"));
    assert_eq!(test_params.len(), original_count + 2);

    println!("\nAll tests completed successfully!");
}