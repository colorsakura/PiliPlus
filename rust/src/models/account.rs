use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct Account {
    pub id: String,
    pub name: String,
    pub avatar: String,
    pub cookies: HashMap<String, String>,
    pub auth_tokens: AuthTokens,
    pub is_logged_in: bool,
    pub created_at: i64,
    pub last_used: i64,
}

impl Account {
    pub fn cookie_header(&self) -> String {
        self.cookies
            .iter()
            .map(|(k, v)| format!("{}={}", k, v))
            .collect::<Vec<_>>()
            .join("; ")
    }

    pub fn update_cookie(&mut self, key: String, value: String) {
        self.cookies.insert(key, value);
    }
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct AuthTokens {
    pub access_token: Option<String>,
    pub refresh_token: Option<String>,
    pub expires_at: Option<i64>,
}

#[derive(Clone, Serialize, Deserialize, Debug)]
pub struct CookieJar {
    pub cookies: HashMap<String, String>,
}

impl CookieJar {
    pub fn new() -> Self {
        Self {
            cookies: HashMap::new(),
        }
    }

    pub fn set(&mut self, name: String, value: String) {
        self.cookies.insert(name, value);
    }

    pub fn get(&self, name: &str) -> Option<&String> {
        self.cookies.get(name)
    }

    pub fn to_header(&self) -> String {
        self.cookies
            .iter()
            .map(|(k, v)| format!("{}={}", k, v))
            .collect::<Vec<_>>()
            .join("; ")
    }
}
