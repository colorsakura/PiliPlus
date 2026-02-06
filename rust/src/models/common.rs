use serde::{Deserialize, Serialize};
use crate::error::ApiError;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct Image {
    pub url: String,
    pub width: Option<u32>,
    pub height: Option<u32>,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct ApiResponse<T> {
    pub code: i32,
    pub message: String,
    pub data: Option<T>,
}

impl<T> ApiResponse<T> {
    pub fn is_success(&self) -> bool {
        self.code == 0
    }

    pub fn into_result(self) -> Result<T, ApiError> {
        if self.is_success() {
            self.data.ok_or_else(|| {
                ApiError::ApiError {
                    code: self.code,
                    message: "No data in response".to_string(),
                }
            })
        } else {
            Err(ApiError::ApiError {
                code: self.code,
                message: self.message,
            })
        }
    }
}