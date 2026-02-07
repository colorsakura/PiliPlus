use crate::error::ApiError;
use serde::{Deserialize, Deserializer, Serialize};

#[derive(Clone, Serialize, Debug, PartialEq)]
pub struct Image {
    pub url: String,
    pub width: Option<u32>,
    pub height: Option<u32>,
}

// Custom deserializer for Image - handles both string URLs and Image objects
impl<'de> Deserialize<'de> for Image {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        use serde::de::Error;

        // Try to deserialize as a string first
        let value = serde_json::Value::deserialize(deserializer)?;

        match value {
            // If it's a string, create Image with just the URL
            serde_json::Value::String(url) => Ok(Image {
                url,
                width: None,
                height: None,
            }),
            // If it's an object, parse as Image struct
            serde_json::Value::Object(mut obj) => {
                let url_value = obj
                    .remove("url")
                    .ok_or_else(|| Error::missing_field("url"))?;

                let url = url_value
                    .as_str()
                    .ok_or_else(|| Error::custom("url must be a string"))?
                    .to_string();

                let width = obj
                    .remove("width")
                    .and_then(|v| v.as_u64())
                    .map(|v| v as u32);

                let height = obj
                    .remove("height")
                    .and_then(|v| v.as_u64())
                    .map(|v| v as u32);

                Ok(Image { url, width, height })
            }
            _ => Err(Error::custom("expected string or object for Image")),
        }
    }
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
            self.data.ok_or_else(|| ApiError::ApiError {
                code: self.code,
                message: "No data in response".to_string(),
            })
        } else {
            Err(ApiError::ApiError {
                code: self.code,
                message: self.message,
            })
        }
    }
}
