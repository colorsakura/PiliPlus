use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::Mutex;
use reqwest::header::HeaderMap;

#[derive(Clone)]
pub struct CacheEntry {
    pub data: Vec<u8>,
    pub etag: Option<String>,
    pub last_modified: Option<String>,
    pub expires_at: i64,
}

pub struct HttpCache {
    store: Arc<Mutex<HashMap<String, CacheEntry>>>,
}

impl HttpCache {
    pub fn new() -> Self {
        Self {
            store: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    pub async fn get(&self, url: &str) -> Option<Vec<u8>> {
        let store = self.store.lock().await;
        if let Some(entry) = store.get(url) {
            if entry.expires_at > chrono::Utc::now().timestamp() {
                return Some(entry.data.clone());
            }
        }
        None
    }

    pub async fn insert(
        &self,
        url: &str,
        data: Vec<u8>,
        headers: &HeaderMap,
    ) {
        let mut store = self.store.lock().await;
        let entry = CacheEntry {
            data,
            etag: headers.get("etag")
                .and_then(|v: &reqwest::header::HeaderValue| v.to_str().ok())
                .map(|s: &str| s.to_string()),
            last_modified: headers.get("last-modified")
                .and_then(|v: &reqwest::header::HeaderValue| v.to_str().ok())
                .map(|s: &str| s.to_string()),
            expires_at: chrono::Utc::now().timestamp() + 300, // 5 minutes
        };
        store.insert(url.to_string(), entry);
    }

    pub async fn clear_expired(&self) {
        let mut store = self.store.lock().await;
        let now = chrono::Utc::now().timestamp();
        store.retain(|_, entry| entry.expires_at > now);
    }

    pub async fn clear(&self) {
        let mut store = self.store.lock().await;
        store.clear();
    }
}
