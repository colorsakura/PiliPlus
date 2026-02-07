use reqwest::{Client, header};
use crate::error::ApiError;

pub struct HttpClient {
    client: Client,
    base_url: String,
}

impl HttpClient {
    pub fn new(base_url: String) -> Result<Self, ApiError> {
        let client = Client::builder()
            .http2_adaptive_window(true)
            .build()
            .map_err(|e| ApiError::HttpError(e))?;

        Ok(Self { client, base_url })
    }

    pub async fn get<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self.client
            .get(&url)
            .send()
            .await?;

        self.handle_response(response).await
    }

    pub async fn post<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        body: serde_json::Value,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await?;

        self.handle_response(response).await
    }

    pub async fn get_with_auth<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        cookie_header: &str,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self.client
            .get(&url)
            .header(header::COOKIE, cookie_header)
            .send()
            .await?;

        self.handle_response(response).await
    }

    pub async fn post_with_auth<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        body: serde_json::Value,
        cookie_header: &str,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self.client
            .post(&url)
            .json(&body)
            .header(header::COOKIE, cookie_header)
            .send()
            .await?;

        self.handle_response(response).await
    }

    async fn handle_response<T: serde::de::DeserializeOwned>(
        &self,
        response: reqwest::Response,
    ) -> Result<T, ApiError> {
        if response.status().is_success() {
            response
                .json()
                .await
                .map_err(ApiError::from)
        } else {
            match response.status().as_u16() {
                401 => Err(ApiError::Unauthorized),
                _ => Err(ApiError::ApiError {
                    code: response.status().as_u16() as i32,
                    message: format!("HTTP error: {}", response.status()),
                }),
            }
        }
    }

    /// Get the underlying reqwest Client for direct access
    /// Used for download operations that need streaming
    pub fn get_client(&self) -> &Client {
        &self.client
    }
}