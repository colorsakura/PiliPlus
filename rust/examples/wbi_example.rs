// Example for WBI functions
use pilicore::api::wbi::{enc_wbi, get_mixin_key};
use std::collections::HashMap;

fn main() {
    println!("Testing WBI functions...");

    // Test get_mixin_key
    let input = "abcdefghijklmnopqrstuvwxyz012345";
    let result = get_mixin_key(input);
    println!(
        "get_mixin_key({}) -> {} (length: {})",
        input,
        result,
        result.len()
    );
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

    println!("All tests passed!");
}
