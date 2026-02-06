use once_cell::sync::Lazy;
use std::sync::Arc;
use tokio::runtime::Runtime;

use crate::storage::StorageService;
use crate::http::HttpService;
use crate::account::AccountService;

pub struct Services {
    pub storage: Arc<StorageService>,
    pub http: Arc<HttpService>,
    pub account: Arc<AccountService>,
}

static SERVICES: Lazy<Arc<Services>> = Lazy::new(|| {
    let rt = Runtime::new().unwrap();

    rt.block_on(async {
        let storage = Arc::new(StorageService::new(":memory:").await.unwrap());
        let http = Arc::new(HttpService::new("https://api.bilibili.com".to_string()).unwrap());
        let account = Arc::new(AccountService::new(storage.clone(), http.clone()));

        Arc::new(Services {
            storage,
            http,
            account,
        })
    })
});

/// Get global services instance
pub fn get_services() -> Arc<Services> {
    SERVICES.clone()
}