pub mod service;
pub mod qrcode;
pub mod login;

pub use service::AccountService;
pub use qrcode::{QrState, QrStatus, QrCodeData};
pub use login::QrLoginFlow;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_qr_state_serialization() {
        let state = QrState::Code {
            url: "https://test.com".to_string(),
            expiry: 180,
        };

        let json = serde_json::to_string(&state).unwrap();
        assert!(json.contains("Code"));
    }
}