
/// Mixin key encoding table - 32-element shuffle table
const MIXIN_KEY_ENC_TAB: [usize; 32] = [
    14, 10, 2, 18, 23, 27, 8, 3, 28, 5, 15, 31, 12, 19, 11, 7,
    1, 21, 26, 30, 4, 22, 20, 29, 25, 13, 24, 17, 6, 0, 9, 16
];


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
    String::from_utf8(result).unwrap_or_else(|_| String::new())
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
        assert_eq!(long_result.chars().collect::<String>(), "abcdefghijklmnopqrstuvwxyz012345");
        assert_ne!(long_result, "abcdefghijklmnopqrstuvwxyz012345678901234567890123");
    }
}