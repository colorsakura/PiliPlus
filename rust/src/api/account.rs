use crate::models::Account;
use crate::services::get_services;
use flutter_rust_bridge::frb;

/// Get current logged-in account
#[frb]
pub async fn get_current_account() -> Option<Account> {
    let services = get_services().await;
    services.account.current_account().await
}

/// Switch to a different account
#[frb]
pub async fn switch_account(account_id: String) -> Result<(), String> {
    let services = get_services().await;
    services
        .account
        .switch_account(&account_id)
        .await
        .map_err(|e| e.to_string())
}

/// Get all saved accounts
#[frb]
pub async fn get_all_accounts() -> Result<Vec<Account>, String> {
    let services = get_services().await;
    services
        .account
        .all_accounts()
        .await
        .map_err(|e| e.to_string())
}

/// Save an account
#[frb]
pub async fn save_account(account: Account) -> Result<(), String> {
    let services = get_services().await;
    services
        .account
        .add_account(account)
        .await
        .map_err(|e: crate::error::AccountError| e.to_string())
}

/// Delete an account
#[frb]
pub async fn delete_account(account_id: String) -> Result<(), String> {
    let services = get_services().await;
    services
        .account
        .remove_account(&account_id)
        .await
        .map_err(|e: crate::error::AccountError| e.to_string())
}

/// Get current account ID
#[frb]
pub async fn get_current_account_id() -> Option<String> {
    let services = get_services().await;
    services.account.current_account_id().await
}
