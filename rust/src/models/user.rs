use super::common::Image;
use serde::{Deserialize, Serialize};

/// User information matching Bilibili API response
#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserInfo {
    pub mid: i64,
    #[serde(rename = "uname")]
    pub name: String,
    pub face: String,
    #[serde(rename = "level_info")]
    pub level_info: UserLevel,
    #[serde(rename = "vip")]
    pub vip_status: VipStatus,
    pub money: f64,
    // Optional fields that may or may not be present
    #[serde(default)]
    pub email_verified: i32,
    #[serde(default)]
    pub mobile_verified: i32,
    #[serde(default)]
    pub moral: i32,
    #[serde(default)]
    pub scores: i32,
    #[serde(rename = "vipDueDate", default)]
    pub vip_due_date: i64,
    #[serde(rename = "vipPayType", default)]
    pub vip_pay_type: i32,
    #[serde(rename = "vipThemeType", default)]
    pub vip_theme_type: i32,
    #[serde(rename = "vip_avatar_subscript", default)]
    pub vip_avatar_sub: i32,
    #[serde(rename = "vip_nickname_color", default)]
    pub vip_nickname_color: String,
    #[serde(rename = "has_shop", default)]
    pub has_shop: bool,
    #[serde(rename = "shop_url", default)]
    pub shop_url: String,
    #[serde(rename = "is_senior_member", default)]
    pub is_senior_member: i32,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserLevel {
    #[serde(rename = "current_level")]
    pub current_level: u8,
    #[serde(rename = "current_min", default)]
    pub current_min: u32,
    #[serde(rename = "current_exp", default)]
    pub current_exp: u32,
    #[serde(default)]
    pub next_exp: u32,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VipStatus {
    pub status: u8,
    #[serde(rename = "type")]
    pub vip_type: u8,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserStats {
    pub following: u32,
    pub follower: u32,
    #[serde(rename = "dynamic_count", default)]
    pub dynamic_count: u32,
}
