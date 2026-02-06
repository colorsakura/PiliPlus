use flutter_rust_bridge::frb;

/// Initialize the Rust core
#[frb(sync)]
pub fn init_core() {
    // Initialize logging
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .init();

    tracing::info!("PiliPlus Rust core initialized");
}

/// Get version information
#[frb(sync)]
pub fn get_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// Health check
#[frb(sync)]
pub fn health_check() -> bool {
    true
}

