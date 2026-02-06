use flutter_rust_bridge::frb;
use crate::models::Account;
use crate::error::BridgeResult;
use crate::services::get_services;

/// Get current logged-in account
#[frb]
pub async fn get_current_account() -> BridgeResult<Option<Account>> {
    let services = get_services();

    Ok(services.account.current_account().await)
}

/// Switch to a different account
#[frb]
pub async fn switch_account(account_id: String) -> BridgeResult<()> {
    let services = get_services();

    services.account.switch_account(&account_id).await
        .map_err(|e| e.into())
}

/// Get all saved accounts
#[frb]
pub async fn get_all_accounts() -> BridgeResult<Vec<Account>> {
    let services = get_services();

    services.storage.all_accounts().await
        .map_err(|e| e.into())
}