// Simple test for WBI functions
use std::collections::HashMap;
use md5;
use percent_encoding::{utf8_percent_encode, NON_ALPHANUMERIC};
use chrono::{Local, TimeZone};

/// Mixin key encoding table - 32-element shuffle table
const MIXIN_KEY_ENC_TAB: [usize; 32] = [
    14, 10, 2, 18, 23, 27, 8, 3, 28, 5, 15, 31, 12, 19, 11, 7,
    1, 21, 26, 30, 4, 22, 20, 29, 25, 13, 24, 17, 6, 0, 9, 16
];

/// Allowed special characters in WBI parameter filtering
const ALLOWED_SPECIAL_CHARS: &str = "!'()*-_.";

/// Generate mixin key by shuffling characters according to the encoding table
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
fn enc_wbi(params: &mut HashMap<String, String>, mixin_key: &str) {
    // Input validation
    assert!(!mixin_key.is_empty(), "mixin_key cannot be empty");
    assert!(mixin_key.len() <= 32, "mixin_key cannot be longer than 32 characters");

    // Add timestamp
    let timestamp = Local::now().timestamp().to_string();
    params.insert("wts".to_string(), timestamp);

    // Sort parameters by key
    let mut sorted_params: Vec<_> = params.iter().collect();
    sorted_params.sort_by_key(|(k, _)| k.clone());

    // Build query string with URL encoding
    let mut query_parts = Vec::new();
    for (key, value) in sorted_params {
        let encoded_key = utf8_percent_encode(key, NON_ALPHANUMERIC).to_string();
        let encoded_value = utf8_percent_encode(value, NON_ALPHANUMERIC).to_string();
        query_parts.push(format!("{}={}", encoded_key, encoded_value));
    }
    let query_string = query_parts.join("&");

    // Filter special characters using ALLOWED_SPECIAL_CHARS
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

fn main() {
    println!("Testing WBI functions...");

    // Test get_mixin_key
    let input = "abcdefghijklmnopqrstuvwxyz012345";
    let result = get_mixin_key(input);
    println!("get_mixin_key({}) -> {} (length: {})", input, result, result.len());
    assert_eq!(result.len(), 32);

    // Test enc_wbi
    let mut params = HashMap::new();
    params.insert("test".to_string(), "value".to_string());
    params.insert("foo".to_string(), "bar".to_string());
    let mixin_key = "test_mixin_key_1234567890123456";

    println!("Before enc_wbi: {:?}", params);
    enc_wbi(&mut params, mixin_key);
    println!("After enc_wbi: {:?}", params);

    assert!(params.contains_key("wts"));
    assert!(params.contains_key("w_rid"));

    // Test validation assertions
    println!("Testing validation...");
    let mut test_params = HashMap::new();
    test_params.insert("key".to_string(), "value".to_string());

    // Should pass
    enc_wbi(&mut test_params, "valid_key");

    // Should panic - empty mixin_key
    // enc_wbi(&mut test_params, "");

    // Should panic - too long mixin_key
    // enc_wbi(&mut test_params, "this_key_is_way_too_long_for_the_limit");

    println!("All tests passed!");
}