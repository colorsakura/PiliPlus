use once_cell::sync::Lazy;
use std::sync::Arc;
use tokio::runtime::Runtime;

use crate::storage::StorageService;
use crate::http::HttpService;
use crate::account::AccountService;
use crate::download::DownloadService;
use crate::bilibili_api::{VideoApi, UserApi};

pub struct Services {
    pub storage: Arc<StorageService>,
    pub http: Arc<HttpService>,
    pub account: Arc<AccountService>,
    pub download: Arc<DownloadService>,
    pub video_api: Arc<VideoApi>,
    pub user_api: Arc<UserApi>,
}

static SERVICES: Lazy<Arc<Services>> = Lazy::new(|| {
    let rt = Runtime::new().unwrap();

    rt.block_on(async {
        let storage = Arc::new(StorageService::new(":memory:").await.unwrap());
        let http = Arc::new(HttpService::new("https://api.bilibili.com".to_string()).unwrap());
        let account = Arc::new(AccountService::new(storage.clone(), http.clone()));
        let download = Arc::new(DownloadService::new(storage.clone(), http.clone()));
        let video_api = Arc::new(VideoApi::new(http.clone()));
        let user_api = Arc::new(UserApi::new(http.clone()));

        Arc::new(Services {
            storage,
            http,
            account,
            download,
            video_api,
            user_api,
        })
    })
});

/// Get global services instance
pub fn get_services() -> Arc<Services> {
    SERVICES.clone()
}