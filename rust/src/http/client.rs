use crate::error::ApiError;
use crate::http::cache::HttpCache;
use crate::http::retry::RetryPolicy;
use reqwest::{Client, header};
use std::sync::Arc;
use std::time::Duration;

pub struct HttpClient {
    client: Client,
    base_url: String,
    cache: Arc<HttpCache>,
    retry_policy: RetryPolicy,
}

impl HttpClient {
    pub fn new(base_url: String) -> Result<Self, ApiError> {
        let client = Client::builder()
            .http2_prior_knowledge() // Force HTTP/2
            .pool_max_idle_per_host(100) // Connection pool
            .pool_idle_timeout(Duration::from_secs(90))
            .timeout(Duration::from_secs(30))
            .build()
            .map_err(|e| ApiError::HttpError(e))?;

        Ok(Self {
            client,
            base_url,
            cache: Arc::new(HttpCache::new()),
            retry_policy: RetryPolicy::default(),
        })
    }

    pub async fn get<T: serde::de::DeserializeOwned>(&self, path: &str) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);

        // Check cache first
        if let Some(cached) = self.cache.get(&url).await {
            let json = String::from_utf8(cached)
                .map_err(|e| ApiError::SerializationError(serde_json::Error::io(std::io::Error::new(std::io::ErrorKind::InvalidData, e))))?;
            return serde_json::from_str(&json)
                .map_err(|e| ApiError::SerializationError(e));
        }

        // Execute request with retry
        let response = self.execute_with_retry(|client| client.get(&url)).await?;

        // Get response text and headers for caching
        let headers = response.headers().clone();
        let text = response.text().await?;

        // Cache the response
        self.cache.insert(&url, text.as_bytes().to_vec(), &headers).await;

        // Parse response
        serde_json::from_str(&text)
            .map_err(|e| ApiError::SerializationError(e))
    }

    pub async fn post<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        body: serde_json::Value,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self.execute_with_retry(|client| client.post(&url).json(&body)).await?;

        response.json().await.map_err(ApiError::from)
    }

    pub async fn get_with_auth<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        cookie_header: &str,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self
            .execute_with_retry(|client| client.get(&url).header(header::COOKIE, cookie_header))
            .await?;

        response.json().await.map_err(ApiError::from)
    }

    pub async fn post_with_auth<T: serde::de::DeserializeOwned>(
        &self,
        path: &str,
        body: serde_json::Value,
        cookie_header: &str,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self
            .execute_with_retry(|client| {
                client.post(&url).json(&body).header(header::COOKIE, cookie_header)
            })
            .await?;

        response.json().await.map_err(ApiError::from)
    }

    async fn execute_with_retry<F>(&self, build_request: F) -> Result<reqwest::Response, ApiError>
    where
        F: Fn(&Client) -> reqwest::RequestBuilder,
    {
        let mut attempt = 0;
        loop {
            attempt += 1;

            let request = build_request(&self.client);

            match request.send().await {
                Ok(resp) if resp.status().is_success() => {
                    return Ok(resp);
                }
                Ok(resp) => {
                    if resp.status() == 401 {
                        return Err(ApiError::Unauthorized);
                    }
                    if self.retry_policy.should_retry(attempt) {
                        let delay = self.retry_policy.delay_for_attempt(attempt);
                        tokio::time::sleep(delay).await;
                        continue;
                    }
                    return Err(ApiError::ApiError {
                        code: resp.status().as_u16() as i32,
                        message: format!("HTTP error: {}", resp.status()),
                    });
                }
                Err(e) => {
                    if self.retry_policy.should_retry(attempt) {
                        let delay = self.retry_policy.delay_for_attempt(attempt);
                        tokio::time::sleep(delay).await;
                        continue;
                    }
                    return Err(ApiError::HttpError(e));
                }
            }
        }
    }

    /// Get the underlying reqwest Client for direct access
    /// Used for download operations that need streaming
    pub fn get_client(&self) -> &Client {
        &self.client
    }

    /// Clear the HTTP cache
    pub async fn clear_cache(&self) {
        self.cache.clear().await;
    }

    /// Clear expired cache entries
    pub async fn clear_expired_cache(&self) {
        self.cache.clear_expired().await;
    }
}
