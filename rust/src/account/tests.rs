#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_qr_state_serialization() {
        use crate::account::QrState;

        let state = QrState::Code {
            url: "https://test.com".to_string(),
            expiry: 180,
        };

        let json = serde_json::to_string(&state).unwrap();
        assert!(json.contains("Code"));
    }
}