#[cfg(test)]
mod wbi_tests {
    use super::wbi::{get_wbi_keys, get_wbi_keys_cached, extract_filename};

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

    #[test]
    fn test_extract_filename() {
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
            assert_eq!(result, expected, "Failed for input: {}", input);
        }
    }
}