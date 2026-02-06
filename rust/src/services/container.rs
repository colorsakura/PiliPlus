use once_cell::sync::OnceCell;
use std::sync::Arc;

use crate::storage::StorageService;
use crate::services::account::AccountService;
use crate::http::HttpService;
use crate::bilibili_api::{VideoApi, UserApi, SearchApi};

pub struct Services {
    pub storage: Arc<StorageService>,
    pub http: Arc<HttpService>,
    pub account: Arc<AccountService>,
    // pub download: Arc<DownloadService>,  // TODO: Restore when DownloadService is ready
    pub video_api: Arc<VideoApi>,
    pub user_api: Arc<UserApi>,
    pub search_api: Arc<SearchApi>,
}

static SERVICES: OnceCell<Arc<Services>> = OnceCell::new();

/// Initialize services (async, for use within tokio runtime)
async fn init_services() -> Arc<Services> {
    let storage = Arc::new(StorageService::new(":memory:").await.unwrap());
    let http = Arc::new(HttpService::new("https://api.bilibili.com".to_string()).unwrap());
    let account = Arc::new(AccountService::new(storage.clone(), http.clone()));
    // let download = Arc::new(DownloadService::new(storage.clone(), http.clone()));  // TODO: Restore when needed
    let video_api = Arc::new(VideoApi::new(http.clone()));
    let user_api = Arc::new(UserApi::new(http.clone()));
    let search_api = Arc::new(SearchApi::new(http.clone()));

    Arc::new(Services {
        storage,
        http,
        account,
        // download,  // TODO: Restore when needed
        video_api,
        user_api,
        search_api,
    })
}

/// Get global services instance
/// This will initialize services on first call in an async context
pub async fn get_services() -> Arc<Services> {
    // Use get_or_init safely in async context
    // We use a oneshot channel to ensure only one initialization happens
    if let Some(services) = SERVICES.get() {
        return services.clone();
    }

    // Initialize services asynchronously
    let services = init_services().await;

    // Try to set - if another thread beat us to it, use theirs
    SERVICES.get_or_init(|| services.clone()).clone()
}