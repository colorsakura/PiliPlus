use super::*;
use crate::error::ApiError;
use std::collections::HashMap;

#[cfg(test)]
mod tests {
    use super::*;
    use crate::error::ApiError;
    use std::collections::HashMap;

    #[test]
    fn test_cookie_header_construction() {
        let mut account = Account {
            id: "test".to_string(),
            name: "Test User".to_string(),
            avatar: "https://example.com/avatar.jpg".to_string(),
            cookies: HashMap::new(),
            auth_tokens: AuthTokens {
                access_token: None,
                refresh_token: None,
                expires_at: None,
            },
            is_logged_in: true,
        };

        account.update_cookie("SESSDATA".to_string(), "abc123".to_string());
        account.update_cookie("bili_jct".to_string(), "xyz789".to_string());

        let header = account.cookie_header();
        assert!(header.contains("SESSDATA=abc123"));
        assert!(header.contains("bili_jct=xyz789"));
    }

    #[test]
    fn test_api_response_success() {
        let resp: ApiResponse<String> = ApiResponse {
            code: 0,
            message: "success".to_string(),
            data: Some("test data".to_string()),
        };

        assert!(resp.is_success());
        assert_eq!(resp.into_result().unwrap(), "test data");
    }

    #[test]
    fn test_api_response_error() {
        let resp: ApiResponse<String> = ApiResponse {
            code: -1,
            message: "error".to_string(),
            data: None,
        };

        assert!(!resp.is_success());
        let result: Result<String, ApiError> = resp.into_result();
        assert!(result.is_err());
    }

    #[test]
    fn test_video_quality_values() {
        assert_eq!(VideoQuality::Low as i32, 16);
        assert_eq!(VideoQuality::FourK as i32, 112);
    }
}