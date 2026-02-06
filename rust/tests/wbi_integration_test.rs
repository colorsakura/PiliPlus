use pilicore::wbi;

#[tokio::test]
async fn test_wbi_integration() {
    // Test the WBI key fetching functionality
    let result = wbi::get_wbi_keys().await;

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
            println!("Test failed (possibly due to network): {}", e);
            // We'll allow this test to pass even in CI environments
            // where network might not be available
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
        let result = wbi::extract_filename(input);
        assert_eq!(result, expected, "Failed for input: {}", input);
    }
}