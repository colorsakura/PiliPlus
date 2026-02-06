use serde::{Deserialize, Serialize};
use super::common::Image;

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserInfo {
    pub mid: i64,
    pub name: String,
    pub face: Image,
    #[serde(rename = "level")]
    pub level_info: UserLevel,
    #[serde(rename = "vip")]
    pub vip_status: VipStatus,
    pub money: CoinBalance,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserLevel {
    pub current_level: u8,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct VipStatus {
    pub status: u8,
    #[serde(rename = "type")]
    pub vip_type: u8,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct CoinBalance {
    pub coins: u32,
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
pub struct UserStats {
    pub following: u32,
    pub follower: u32,
}