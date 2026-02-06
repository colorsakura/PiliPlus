use flutter_rust_bridge::frb;
use crate::models::Account;
use crate::error::BridgeResult;
use crate::services::get_services;
use crate::stream::AccountStream;

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

/// Subscribe to account change events stream
///
/// Returns a stream adapter that provides async access to account change events.
/// Multiple subscribers can call this function to receive independent streams.
#[frb]
pub fn subscribe_account_changes() -> AccountStream {
    let services = get_services();
    let receiver = services.account.account_changes();
    AccountStream::new(receiver)
}

/// Poll for the next account change event
///
/// Helper function for Flutter to poll events synchronously.
/// Returns None if no event is available or stream is closed.
///
/// TODO: Replace with proper async stream support in flutter_rust_bridge
#[frb(sync)]
pub fn poll_account_change(stream: &mut AccountStream) -> Option<Account> {
    // For sync bridge, we need to block on tokio runtime
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        // Use a timeout to avoid blocking indefinitely
        match tokio::time::timeout(tokio::time::Duration::from_millis(100), stream.next()).await {
            Ok(account) => account,
            Err(_) => None, // Timeout
        }
    })
}