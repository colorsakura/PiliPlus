use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct QrCodeData {
    pub url: String,
    pub oauth_key: String,
    pub expiry: u64,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub enum QrState {
    Code { url: String, expiry: u64 },
    Scanned,
    LoggedIn(Account),
    Expired,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub enum QrStatus {
    Waiting,
    Scanned,
    Success { cookies: HashMap<String, String> },
    Expired,
}

use crate::models::Account;
