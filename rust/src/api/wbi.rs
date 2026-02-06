
use std::collections::HashMap;
use md5;
use percent_encoding::{utf8_percent_encode, NON_ALPHANUMERIC};
use chrono::Local;

/// Mixin key encoding table - 32-element shuffle table
const MIXIN_KEY_ENC_TAB: [usize; 32] = [
    14, 10, 2, 18, 23, 27, 8, 3, 28, 5, 15, 31, 12, 19, 11, 7,
    1, 21, 26, 30, 4, 22, 20, 29, 25, 13, 24, 17, 6, 0, 9, 16
];

/// Allowed special characters in WBI parameter filtering
const ALLOWED_SPECIAL_CHARS: &str = "!'()*-_.";


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
    sorted_params.sort_by_key(|(k, _)| k.clone());

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