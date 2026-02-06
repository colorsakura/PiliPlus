# Web推荐API Rust迁移实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将B站首页推荐API从Flutter迁移到Rust，实现完整的WBI签名、网络请求和数据解析功能。

**Architecture:** 使用Facade模式，Rust实现包含WBI签名、HTTP请求和JSON解析，Dart层通过Adapter转换模型，Facade根据feature flag路由到Rust或Flutter实现，支持自动fallback。

**Tech Stack:** Rust (reqwest, serde), Flutter/Dart (flutter_rust_bridge), GetX, Hive

**相关文档:**
- 设计文档: `docs/plans/2025-02-07-rcmd-api-rust-migration-design.md`
- Video API示例: `lib/src/rust/api/video.dart`, `lib/src/rust/adapters/video_adapter.dart`
- WBI签名参考: `lib/utils/wbi_sign.dart`

---

## Task 1: Rust WBI签名实现 - 混淆密钥生成

**Files:**
- Create: `rust/src/api/wbi.rs`

**Step 1: 创建WBI模块文件**

```rust
// rust/src/api/wbi.rs
use once_cell::sync::Lazy;
use std::collections::HashMap;
use std::sync::Mutex;
use std::time::{SystemTime, UNIX_EPOCH};

/// 混淆表（与Dart完全相同）
const MIXIN_KEY_ENC_TAB: [usize; 32] = [
    46, 47, 18, 2, 53, 8, 23, 27, 32, 15, 50, 10, 31, 58, 3, 45,
    35, 27, 43, 5, 49, 33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13
];

/// 全局缓存：mixin_key
static MIXIN_KEY_CACHE: Lazy<Mutex<Option<(String, u64)>>> =
    Lazy::new(|| Mutex::new(None));

/// 对 imgKey 和 subKey 进行字符顺序打乱编码
///
/// # Arguments
/// * `orig` - imgKey + subKey 拼接后的字符串
///
/// # Returns
/// 打乱后的32位密钥
pub fn get_mixin_key(orig: &str) -> String {
    let code_units: Vec<u8> = orig.bytes().collect();
    MIXIN_KEY_ENC_TAB
        .iter()
        .map(|&i| code_units[i] as char)
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_mixin_key() {
        // 测试混淆函数
        let input = "abcdefghijkmnpqrstuvwxyz23456789"; // 32位
        let result = get_mixin_key(input);
        assert_eq!(result.len(), 32);
        assert_ne!(result, input); // 应该被混淆
    }
}
```

**Step 2: 添加模块到mod.rs**

编辑 `rust/src/api/mod.rs`:

```rust
pub mod simple;
pub mod bridge;
pub mod video;
pub mod account;
pub mod wbi;  // 新增

pub use bridge::*;
```

**Step 3: 运行测试验证**

```bash
cd rust && cargo test get_mixin_key --verbose
```

Expected: PASS

**Step 4: 提交**

```bash
git add rust/src/api/wbi.rs rust/src/api/mod.rs
git commit -m "feat(rust): add WBI mixin key generation function

- Add get_mixin_key() with shuffle table
- Matches Dart implementation exactly
- Add unit test

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Rust WBI签名实现 - 参数签名

**Files:**
- Modify: `rust/src/api/wbi.rs`

**Step 1: 添加参数签名函数**

```rust
// 在 rust/src/api/wbi.rs 中添加

use md5; // 需要在 Cargo.toml 中添加依赖
use percent_encoding::{utf8_percent_encode, NON_ALPHANUMERIC};

/// 特殊字符过滤器
const CHR_FILTER: &str = "!\'()*";

/// 为请求参数进行 wbi 签名
///
/// # Arguments
/// * `params` - 请求参数（会被修改）
/// * `mixin_key` - 混淆后的密钥
pub fn enc_wbi(params: &mut HashMap<String, String>, mixin_key: &str) {
    // 添加时间戳
    let wts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    params.insert("wts".to_string(), wts.to_string());

    // 按照 key 重排参数
    let mut keys: Vec<&String> = params.keys().collect();
    keys.sort();

    // 构建查询字符串
    let query_str: String = keys
        .iter()
        .map(|k| {
            let value = params.get(k).unwrap();
            // 过滤特殊字符
            let filtered_value: String = value
                .chars()
                .filter(|c| !CHR_FILTER.contains(*c))
                .collect();

            // URL编码
            format!("{}={}",
                utf8_percent_encode(k, NON_ALPHANUMERIC),
                utf8_percent_encode(&filtered_value, NON_ALPHANUMERIC)
            )
        })
        .collect::<Vec<_>>()
        .join("&");

    // 计算MD5 → w_rid
    let digest = md5::compute(query_str + mixin_key);
    params.insert("w_rid".format!("{:x}", digest));
}
```

**Step 2: 添加md5依赖到Cargo.toml**

编辑 `rust/Cargo.toml`:

```toml
[dependencies]
# ... existing dependencies ...
md5 = "0.7"
percent-encoding = "2.3"
```

**Step 3: 添加测试**

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    // ... existing test ...

    #[test]
    fn test_enc_wbi() {
        let mut params = HashMap::new();
        params.insert("key1".to_string(), "value1".to_string());
        params.insert("key2".to_string(), "value2".to_string());

        enc_wbi(&mut params, "test_key_123456789012345678901234");

        assert!(params.contains_key("wts"));
        assert!(params.contains_key("w_rid"));
        assert_eq!(params["w_rid"].len(), 32); // MD5 hex
    }
}
```

**Step 4: 运行测试验证**

```bash
cd rust && cargo test enc_wbi --verbose
```

Expected: PASS

**Step 5: 构建验证**

```bash
cd rust && cargo build
```

Expected: Success, no errors

**Step 6: 提交**

```bash
git add rust/Cargo.toml rust/src/api/wbi.rs
git commit -m "feat(rust): add WBI parameter signing function

- Add enc_wbi() for parameter signing
- Add timestamp, sorting, URL encoding, MD5 hash
- Add md5 and percent-encoding dependencies
- Add unit test

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Rust WBI签名实现 - 密钥获取

**Files:**
- Modify: `rust/src/api/wbi.rs`
- Modify: `rust/Cargo.toml`

**Step 1: 添加HTTP客户端依赖**

编辑 `rust/Cargo.toml`:

```toml
[dependencies]
# ... existing dependencies ...
reqwest = { version = "0.12", features = ["json", "cookies"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1", features = ["full"] }
```

**Step 2: 添加密钥获取函数**

```rust
// 在 rust/src/api/wbi.rs 中添加

use reqwest::Client;
use serde::Deserialize;
use std::fs;
use std::path::PathBuf;

/// WBI图片信息
#[derive(Debug, Deserialize)]
struct WbiImg {
    img_url: String,
    sub_url: String,
}

/// 用户信息响应
#[derive(Debug, Deserialize)]
struct UserInfoResponse {
    data: UserData,
}

#[derive(Debug, Deserialize)]
struct UserData {
    wbi_img: WbiImg,
}

/// 从URL中提取文件名（不含扩展名）
fn extract_filename(url: &str) -> String {
    let path = url.split('/').last().unwrap_or("");
    path.split('.').next().unwrap_or("").to_string()
}

/// 获取WBI密钥
///
/// 从用户信息API获取wbi_img，提取并混合密钥
pub async fn get_wbi_keys() -> Result<String, Box<dyn std::error::Error>> {
    let client = Client::new();

    // 调用用户信息API
    let resp = client
        .get("https://api.bilibili.com/x/web-interface/nav")
        .send()
        .await?;

    let user_info: UserInfoResponse = resp.json().await?;

    // 提取文件名
    let img_name = extract_filename(&user_info.data.wbi_img.img_url);
    let sub_name = extract_filename(&user_info.data.wbi_img.sub_url);

    // 混合密钥
    let mixin_key = get_mixin_key(&(img_name + &sub_name));

    // 更新缓存
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    *MIXIN_KEY_CACHE.lock().unwrap() = Some((mixin_key.clone(), now));

    Ok(mixin_key)
}

/// 获取WBI密钥（带缓存）
///
/// 检查缓存是否过期（24小时），过期则重新获取
pub async fn get_wbi_keys_cached() -> Result<String, Box<dyn std::error::Error>> {
    const CACHE_DURATION: u64 = 24 * 60 * 60; // 24小时

    let mut cache = MIXIN_KEY_CACHE.lock().unwrap();

    if let Some((key, timestamp)) = cache.as_ref() {
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs();

        if now - timestamp < CACHE_DURATION {
            return Ok(key.clone());
        }
    }

    // 缓存过期或不存在，重新获取
    drop(cache); // 释放锁
    let key = get_wbi_keys().await?;
    Ok(key)
}
```

**Step 3: 添加测试**

```rust
#[tokio::test]
async fn test_get_wbi_keys() {
    let result = get_wbi_keys_cached().await;
    assert!(result.is_ok());

    let key = result.unwrap();
    assert_eq!(key.len(), 32);

    // 第二次调用应该使用缓存
    let result2 = get_wbi_keys_cached().await;
    assert!(result2.is_ok());
}
```

**Step 4: 运行测试验证**

```bash
cd rust && cargo test get_wbi_keys --verbose -- --nocapture
```

Expected: PASS (需要网络连接)

**Step 5: 提交**

```bash
git add rust/Cargo.toml rust/src/api/wbi.rs
git commit -m "feat(rust): add WBI key fetching with caching

- Add get_wbi_keys() to fetch from user info API
- Add 24-hour cache support
- Add filename extraction utility
- Add async test

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Rust数据模型定义

**Files:**
- Create: `rust/src/models/rcmd.rs`
- Modify: `rust/src/models/mod.rs`

**Step 1: 创建推荐数据模型**

```rust
// rust/src/models/rcmd.rs
use serde::{Deserialize, Serialize};

/// 推荐视频信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RcmdVideoInfo {
    pub id: Option<i64>,
    pub bvid: String,
    pub cid: Option<i64>,
    pub goto: Option<String>,
    pub uri: Option<String>,
    pub pic: Option<String>,
    pub title: String,
    pub duration: i32,
    pub pubdate: Option<i64>,
    pub owner: RcmdOwner,
    pub stat: RcmdStat,
    pub is_followed: bool,
    pub rcmd_reason: Option<String>,
}

/// UP主信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RcmdOwner {
    pub mid: i64,
    pub name: String,
    pub face: Option<String>,
}

/// 统计信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RcmdStat {
    pub view: Option<i64>,
    pub like: Option<i64>,
    pub danmaku: Option<i64>,
}

/// 推荐API响应
#[derive(Debug, Deserialize)]
pub struct RcmdResponse {
    pub code: i32,
    pub data: Option<RcmdData>,
    pub message: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct RcmdData {
    pub item: Vec<serde_json::Value>,
}
```

**Step 2: 添加到models模块**

编辑 `rust/src/models/mod.rs`:

```rust
pub mod video;
pub mod account;
pub mod user;
pub mod rcmd; // 新增

pub use video::*;
pub use account::*;
pub use rcmd::*; // 新增
```

**Step 3: 构建验证**

```bash
cd rust && cargo build
```

Expected: Success, no errors

**Step 4: 提交**

```bash
git add rust/src/models/rcmd.rs rust/src/models/mod.rs
git commit -m "feat(rust): add recommendation data models

- Add RcmdVideoInfo, RcmdOwner, RcmdStat
- Add RcmdResponse and RcmdData
- All fields use Option for missing data
- Match Flutter RecVideoItemModel structure

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Rust推荐API实现

**Files:**
- Create: `rust/src/api/rcmd.rs`
- Modify: `rust/src/api/mod.rs`

**Step 1: 实现推荐API函数**

```rust
// rust/src/api/rcmd.rs
use crate::api::wbi::{enc_wbi, get_wbi_keys_cached};
use crate::models::rcmd::*;
use crate::models::ApiError;
use flutter_rust_bridge::frb;
use reqwest::Client;
use std::collections::HashMap;

/// 获取推荐视频列表
///
/// # Arguments
/// * `ps` - 每页数量（通常20）
/// * `fresh_idx` - 刷新索引（0, 1, 2...）
///
/// # Returns
/// 推荐视频列表
#[frb]
pub async fn get_recommend_list(
    ps: i32,
    fresh_idx: i32,
) -> Result<Vec<RcmdVideoInfo>, ApiError> {
    let client = Client::new();

    // 构建请求参数
    let mut params = HashMap::new();
    params.insert("version".to_string(), "1".to_string());
    params.insert("feed_version".to_string(), "V8".to_string());
    params.insert("homepage_ver".to_string(), "1".to_string());
    params.insert("ps".to_string(), ps.to_string());
    params.insert("fresh_idx".to_string(), fresh_idx.to_string());
    params.insert("brush".to_string(), fresh_idx.to_string());
    params.insert("fresh_type".to_string(), "4".to_string());

    // 获取WBI密钥并签名
    let mixin_key = get_wbi_keys_cached()
        .await
        .map_err(|e| ApiError {
            code: -1,
            message: format!("Failed to get WBI keys: {}", e),
        })?;

    enc_wbi(&mut params, &mixin_key);

    // 发起HTTP请求
    let url = "https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd";
    let resp = client
        .get(url)
        .query(&params)
        .send()
        .await
        .map_err(|e| ApiError {
            code: -2,
            message: format!("HTTP request failed: {}", e),
        })?;

    // 解析响应
    let resp_text = resp
        .text()
        .await
        .map_err(|e| ApiError {
            code: -3,
            message: format!("Failed to read response: {}", e),
        })?;

    let rcmd_resp: RcmdResponse = serde_json::from_str(&resp_text)
        .map_err(|e| ApiError {
            code: -4,
            message: format!("Failed to parse response: {}", e),
        })?;

    if rcmd_resp.code != 0 {
        return Err(ApiError {
            code: rcmd_resp.code,
            message: rcmd_resp.message.unwrap_or_else(|| "Unknown error".to_string()),
        });
    }

    let items = rcmd_resp
        .data
        .ok_or_else(|| ApiError {
            code: -5,
            message: "No data in response".to_string(),
        })?
        .item;

    // 解析每个视频项
    let mut videos = Vec::new();
    for item in items {
        if let Ok(video) = serde_json::from_value::<RcmdVideoInfo>(
            item.clone()
        ) {
            // 只保留视频类型（goto='av'）
            if video.goto.as_ref().map_or(false, |g| g == "av") {
                videos.push(video);
            }
        }
    }

    Ok(videos)
}
```

**Step 2: 导出API函数**

编辑 `rust/src/api/mod.rs`:

```rust
pub mod simple;
pub mod bridge;
pub mod video;
pub mod account;
pub mod wbi;
pub mod rcmd;  // 新增

pub use bridge::*;
pub use rcmd::*;  // 新增
```

**Step 3: 导出类型到bridge**

编辑 `rust/src/api/bridge.rs`:

```rust
// 添加类型暴露函数
#[frb]
pub async fn _expose_rcmd_video_info_type() -> RcmdVideoInfo {
    panic!("This function should never be called - it only exists for type registration");
}
```

**Step 4: 构建验证**

```bash
cd rust && cargo build
```

Expected: Success, no errors

**Step 5: 提交**

```bash
git add rust/src/api/rcmd.rs rust/src/api/mod.rs rust/src/api/bridge.rs
git commit -m "feat(rust): add recommendation API implementation

- Add get_recommend_list() function
- Integrate WBI signing
- Parse JSON response
- Filter for video type (goto='av')
- Export types to bridge

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: 生成Dart绑定

**Files:**
- Generated: `lib/src/rust/api/rcmd.dart`
- Generated: `lib/src/rust/models/rcmd.dart`

**Step 1: 运行代码生成**

```bash
flutter_rust_bridge_codegen \
  --rust-input rust/src/api/ \
  --dart-output lib/src/rust/
```

Expected: 生成成功，无错误

**Step 2: 验证生成的文件**

```bash
ls -la lib/src/rust/api/rcmd.dart
ls -la lib/src/rust/models/rcmd.dart
```

Expected: 文件存在

**Step 3: 提交生成的代码**

```bash
git add lib/src/rust/api/rcmd.dart lib/src/rust/models/rcmd.dart rust/src/frb_generated.rs
git commit -m "chore: generate Dart bindings for rcmd API

Auto-generated by flutter_rust_bridge_codegen

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Dart适配器实现

**Files:**
- Create: `lib/src/rust/adapters/rcmd_adapter.dart`

**Step 1: 创建适配器**

```dart
// lib/src/rust/adapters/rcmd_adapter.dart
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/models/model_owner.dart';
import 'package:PiliPlus/models/model_video.dart';
import 'package:PiliPlus/src/rust/models/rcmd.dart' as rust;

class RcmdAdapter {
  /// 转换单个Rust推荐视频到Flutter模型
  static RecVideoItemModel fromRust(rust.RcmdVideoInfo rustVideo) {
    return RecVideoItemModel()
      ..aid = rustVideo.id?.toInt()
      ..bvid = rustVideo.bvid
      ..cid = rustVideo.cid?.toInt()
      ..goto = rustVideo.goto
      ..uri = rustVideo.uri
      ..cover = rustVideo.pic
      ..title = rustVideo.title
      ..duration = rustVideo.duration
      ..pubdate = rustVideo.pubdate?.toInt()
      ..owner = Owner(
        mid: rustVideo.owner.mid.toInt(),
        name: rustVideo.owner.name,
        face: rustVideo.owner.face,
      )
      ..stat = Stat(
        view: rustVideo.stat.view?.toInt(),
        like: rustVideo.stat.like?.toInt(),
        danmaku: rustVideo.stat.danmaku?.toInt(),
      )
      ..isFollowed = rustVideo.isFollowed
      ..rcmdReason = rustVideo.rcmdReason;
  }

  /// 转换推荐列表
  static List<RecVideoItemModel> fromRustList(
    List<rust.RcmdVideoInfo> rustList,
  ) {
    return rustList.map((item) => fromRust(item)).toList();
  }
}
```

**Step 2: 创建测试**

创建 `test/src/rust/adapters/rcmd_adapter_test.dart`:

```dart
// test/src/rust/adapters/rcmd_adapter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/src/rust/adapters/rcmd_adapter.dart';
import 'package:PiliPlus/src/rust/models/rcmd.dart' as rust;

void main() {
  test('RcmdAdapter.fromRust converts correctly', () {
    final rustVideo = rust.RcmdVideoInfo(
      id: 123456,
      bvid: 'BV1xx411c7mD',
      cid: 456789,
      goto: 'av',
      uri: '//www.bilibili.com/video/BV1xx411c7mD',
      pic: 'http://example.com/cover.jpg',
      title: 'Test Video',
      duration: 120,
      pubdate: 1234567890,
      owner: rust.RcmdOwner(
        mid: 789,
        name: 'Test User',
        face: 'http://example.com/face.jpg',
      ),
      stat: rust.RcmdStat(
        view: 1000,
        like: 100,
        danmaku: 50,
      ),
      isFollowed: false,
      rcmdReason: 'Recommended for you',
    );

    final flutter = RcmdAdapter.fromRust(rustVideo);

    expect(flutter.aid, equals(123456));
    expect(flutter.bvid, equals('BV1xx411c7mD'));
    expect(flutter.cid, equals(456789));
    expect(flutter.goto, equals('av'));
    expect(flutter.title, equals('Test Video'));
    expect(flutter.duration, equals(120));
    expect(flutter.owner.mid, equals(789));
    expect(flutter.owner.name, equals('Test User'));
    expect(flutter.stat.view, equals(1000));
    expect(flutter.stat.like, equals(100));
    expect(flutter.isFollowed, isFalse);
    expect(flutter.rcmdReason, equals('Recommended for you'));
  });

  test('RcmdAdapter.fromRustList converts list correctly', () {
    final rustList = [
      rust.RcmdVideoInfo(
        id: 1,
        bvid: 'BV1',
        title: 'Video 1',
        duration: 100,
        owner: rust.RcmdOwner(mid: 1, name: 'User 1'),
        stat: rust.RcmdStat(),
        isFollowed: false,
        goto: 'av',
      ),
      rust.RcmdVideoInfo(
        id: 2,
        bvid: 'BV2',
        title: 'Video 2',
        duration: 200,
        owner: rust.RcmdOwner(mid: 2, name: 'User 2'),
        stat: rust.RcmdStat(),
        isFollowed: false,
        goto: 'av',
      ),
    ];

    final flutterList = RcmdAdapter.fromRustList(rustList);

    expect(flutterList.length, equals(2));
    expect(flutterList[0].bvid, equals('BV1'));
    expect(flutterList[1].bvid, equals('BV2'));
  });
}
```

**Step 3: 运行测试**

```bash
flutter test test/src/rust/adapters/rcmd_adapter_test.dart
```

Expected: PASS

**Step 4: 提交**

```bash
git add lib/src/rust/adapters/rcmd_adapter.dart test/src/rust/adapters/rcmd_adapter_test.dart
git commit -m "feat(dart): add recommendation adapter

- Convert Rust models to Flutter RecVideoItemModel
- Map all fields correctly
- Add unit tests for single and list conversion
- Follow VideoAdapter pattern

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Facade实现

**Files:**
- Create: `lib/http/rcmd_api_facade.dart`

**Step 1: 创建Facade**

```dart
// lib/http/rcmd_api_facade.dart
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/src/rust/adapters/rcmd_adapter.dart';
import 'package:PiliPlus/src/rust/api/rcmd.dart' as rust;
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/recommend_filter.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for recommendation API operations.
class RcmdApiFacade {
  RcmdApiFacade._();

  /// Get recommendation list
  static Future<LoadingState<List<RecVideoItemModel>>> getRecommendList({
    required int ps,
    required int freshIdx,
  }) async {
    if (Pref.useRustRcmdApi) {
      final stopwatch = RustMetricsStopwatch('rust_rcmd_call');
      try {
        // Call Rust implementation
        final rustList = await rust.getRecommendList(
          ps: ps,
          freshIdx: freshIdx,
        );

        stopwatch.stop();

        // Apply filters in Dart layer
        final adapted = RcmdAdapter.fromRustList(rustList);
        final filtered = _applyFilters(adapted);

        return Success(filtered);
      } catch (e, stack) {
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustRcmdFallback');

        if (kDebugMode) {
          debugPrint('Rust rcmd API failed: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter');
        }
        return await _flutterGetRecommendList(ps, freshIdx);
      }
    } else {
      return await _flutterGetRecommendList(ps, freshIdx);
    }
  }

  /// Flutter/Dart implementation
  static Future<LoadingState<List<RecVideoItemModel>>> _flutterGetRecommendList(
    int ps, int freshIdx
  ) async {
    final stopwatch = RustMetricsStopwatch('flutter_rcmd_call');
    try {
      final res = await Request().get(
        Api.recommendListWeb,
        queryParameters: await WbiSign.makSign({
          'version': 1,
          'feed_version': 'V8',
          'homepage_ver': 1,
          'ps': ps,
          'fresh_idx': freshIdx,
          'brush': freshIdx,
          'fresh_type': 4,
        }),
      );

      stopwatch.stop();

      if (res.data['code'] == 0) {
        List<RecVideoItemModel> list = [];
        for (final i in res.data['data']['item']) {
          if (i['goto'] == 'av' &&
              (i['owner'] != null &&
                  !GlobalData().blackMids.contains(i['owner']['mid']))) {
            RecVideoItemModel item = RecVideoItemModel.fromJson(i);
            if (!RecommendFilter.filter(item)) {
              list.add(item);
            }
          }
        }
        return Success(list);
      } else {
        return Error(res.data['message']);
      }
    } catch (e) {
      stopwatch.stopAsError('FlutterRcmdError');
      return Error(e.toString());
    }
  }

  /// Apply filters (blacklist, recommend filter)
  static List<RecVideoItemModel> _applyFilters(
    List<RecVideoItemModel> list
  ) {
    return list.where((item) {
      // Filter blacklisted users
      if (item.owner != null &&
          GlobalData().blackMids.contains(item.owner!.mid)) {
        return false;
      }

      // Apply recommend filter
      if (RecommendFilter.filter(item)) {
        return false;
      }

      return true;
    }).toList();
  }
}
```

**Step 2: 创建测试**

创建 `test/http/rcmd_api_facade_test.dart`:

```dart
// test/http/rcmd_api_facade_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/http/rcmd_api_facade.dart';
import 'package:PiliPlus/utils/storage.dart';

void main() {
  setUpAll(() {
    GStorage.init();
  });

  test('RcmdApiFacade.getRecommendList returns valid data', () async {
    // Test with Flutter implementation (default)
    final result = await RcmdApiFacade.getRecommendList(
      ps: 10,
      freshIdx: 0,
    );

    expect(result, isA<Success>());
    final list = (result as Success).response as List;
    print('Got ${list.length} recommendations');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
```

**Step 3: 运行测试**

```bash
flutter test test/http/rcmd_api_facade_test.dart
```

Expected: PASS

**Step 4: 提交**

```bash
git add lib/http/rcmd_api_facade.dart test/http/rcmd_api_facade_test.dart
git commit -m "feat(dart): add recommendation API facade

- Add getRecommendList() with routing logic
- Automatic fallback to Flutter on error
- Apply filters in both implementations
- Add metrics tracking
- Add integration test

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Feature Flag集成

**Files:**
- Modify: `lib/utils/storage_key.dart`
- Modify: `lib/utils/storage_pref.dart`

**Step 1: 添加storage key**

编辑 `lib/utils/storage_key.dart`:

```dart
abstract final class SettingBoxKey {
  // ... existing keys ...

  /// Use Rust implementation for recommendation API
  static const String useRustRcmdApi = 'useRustRcmdApi';
}
```

**Step 2: 添加Pref访问器**

编辑 `lib/utils/storage_pref.dart`:

```dart
abstract final class Pref {
  // ... existing properties ...

  /// Whether to use Rust implementation for recommendation API
  static bool get useRustRcmdApi =>
      _setting.get(SettingBoxKey.useRustRcmdApi, defaultValue: false);
}
```

**Step 3: 构建验证**

```bash
flutter analyze
```

Expected: No errors

**Step 4: 提交**

```bash
git add lib/utils/storage_key.dart lib/utils/storage_pref.dart
git commit -m "feat(dart): add useRustRcmdApi feature flag

- Add storage key for rcmd API toggle
- Add Pref accessor with default false
- Ready for beta testing integration

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 10: 集成到VideoHttp

**Files:**
- Modify: `lib/http/video.dart`

**Step 1: 修改rcmdVideoList函数**

编辑 `lib/http/video.dart`:

找到 `rcmdVideoList` 函数（约45行），替换为：

```dart
  // 首页推荐视频
  static Future<LoadingState<List<RecVideoItemModel>>> rcmdVideoList({
    required int ps,
    required int freshIdx,
  }) async {
    // 调用facade
    return RcmdApiFacade.getRecommendList(ps: ps, freshIdx: freshIdx);
  }
```

**Step 2: 添加导入**

在文件顶部添加：

```dart
import 'package:PiliPlus/http/rcmd_api_facade.dart';
```

**Step 3: 移除旧的导入（如果不再需要）**

检查是否可以移除：
```dart
import 'package:PiliPlus/utils/wbi_sign.dart';  // 可能还需要，不要删除
```

**Step 4: 构建验证**

```bash
flutter analyze
```

Expected: No errors

**Step 5: 运行应用测试**

```bash
flutter run --debug
```

手动测试：打开首页推荐，验证功能正常

**Step 6: 提交**

```bash
git add lib/http/video.dart
git commit -m "refactor(dart): integrate RcmdApiFacade into VideoHttp

- Replace direct API call with facade
- Enable routing between Rust and Flutter implementations
- No changes to controller layer
- Ready for feature flag testing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 11: Beta Testing集成

**Files:**
- Modify: `lib/utils/beta_testing_manager.dart`

**Step 1: 添加推荐API到beta testing**

编辑 `lib/utils/beta_testing_manager.dart`:

找到初始化部分，添加推荐API：

```dart
  static Future<void> initialize() async {
    if (!Pref.betaTestingEnabled) {
      // ... existing code ...
      return;
    }

    // 计算用户hash和分配
    final isInCohort = _isUserInCohort();

    // Video API（现有）
    GStorage.setting.put(SettingBoxKey.useRustVideoApi, isInCohort);

    // Recommendation API（新增）
    GStorage.setting.put(SettingBoxKey.useRustRcmdApi, isInCohort);

    // ... rest of initialization ...
  }
```

**Step 2: 添加到摘要报告**

找到 `getSummaryReport()` 方法，添加推荐API统计：

```dart
    // Video API stats（现有）
    final videoStats = '''
    **Video API:**
    - Implementation: ${Pref.useRustVideoApi ? 'Rust 🦀' : 'Flutter'}
    - Status: ${Pref.useRustVideoApi ? 'Active' : 'Inactive'}
    ''';

    // Recommendation API stats（新增）
    final rcmdStats = '''
    **Recommendation API:**
    - Implementation: ${Pref.useRustRcmdApi ? 'Rust 🦀' : 'Flutter'}
    - Status: ${Pref.useRustRcmdApi ? 'Active' : 'Inactive'}
    ''';

    return '''
# Beta Testing Summary

$videoStats
$rcmdStats
...
    ''';
```

**Step 3: 添加到状态报告**

找到 `getStatus()` 方法，添加推荐API状态：

```dart
      final rustApis = <String>[
        if (Pref.useRustVideoApi) 'Video',
        if (Pref.useRustRcmdApi) 'Recommendation',  // 新增
      ];
```

**Step 4: 构建验证**

```bash
flutter analyze
```

Expected: No errors

**Step 5: 提交**

```bash
git add lib/utils/beta_testing_manager.dart
git commit -m "feat(dart): integrate recommendation API into beta testing

- Add rcmd API to beta testing manager
- Use same cohort allocation as video API
- Update summary and status reports
- Enable gradual rollout for rcmd API

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 12: A/B对比测试

**Files:**
- Create: `test/rcmd_validation_test.dart`

**Step 1: 创建对比测试**

```dart
// test/rcmd_validation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/http/rcmd_api_facade.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';

void main() {
  setUpAll(() {
    GStorage.init();
  });

  test('Rust and Flutter return equivalent data', () async {
    // Test Flutter implementation
    GStorage.setting.put(SettingBoxKey.useRustRcmdApi, false);
    final flutterResult = await RcmdApiFacade.getRecommendList(
      ps: 10,
      freshIdx: 0,
    );

    expect(flutterResult, isA<Success>());
    final flutterList = (flutterResult as Success).response as List;

    // Test Rust implementation
    GStorage.setting.put(SettingBoxKey.useRustRcmdApi, true);
    final rustResult = await RcmdApiFacade.getRecommendList(
      ps: 10,
      freshIdx: 0,
    );

    expect(rustResult, isA<Success>());
    final rustList = (rustResult as Success).response as List;

    // Compare count
    print('Flutter: ${flutterList.length} items');
    print('Rust: ${rustList.length} items');

    // Both should return data
    expect(flutterList, isNotEmpty);
    expect(rustList, isNotEmpty);

    // Check field structure
    if (rustList.isNotEmpty) {
      final first = rustList.first;
      expect(first.bvid, isNotNull);
      expect(first.title, isNotNull);
      expect(first.owner, isNotNull);
      expect(first.stat, isNotNull);
    }
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('Fallback mechanism works', () async {
    // Enable Rust
    GStorage.setting.put(SettingBoxKey.useRustRcmdApi, true);

    // Should succeed (fallback to Flutter if Rust fails)
    final result = await RcmdApiFacade.getRecommendList(
      ps: 10,
      freshIdx: 0,
    );

    expect(result, isA<Success>());
  }, timeout: const Timeout(Duration(seconds: 30)));
}
```

**Step 2: 运行测试**

```bash
flutter test test/rcmd_validation_test.dart --no-sound-null-safety
```

Expected: PASS

**Step 3: 提交**

```bash
git add test/rcmd_validation_test.dart
git commit -m "test(dart): add A/B comparison tests for rcmd API

- Compare Rust vs Flutter implementations
- Verify data structure equivalence
- Test fallback mechanism
- Add detailed logging

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 13: 集成测试

**Files:**
- Create: `integration_test/rcmd_api_integration_test.dart`

**Step 1: 创建集成测试**

```dart
// integration_test/rcmd_api_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GStorage.init();
  });

  testWidgets('Rcmd API integration test', (tester) async {
    // Enable Rust implementation
    GStorage.setting.put(SettingBoxKey.useRustRcmdApi, true);

    // Load recommendations
    final result = await VideoHttp.rcmdVideoList(
      ps: 20,
      freshIdx: 0,
    );

    expect(result, isA<Success>());

    final list = (result as Success).response as List;
    expect(list, isNotEmpty);

    // Verify first item
    final first = list.first;
    expect(first.bvid, isNotEmpty);
    expect(first.title, isNotEmpty);
    expect(first.owner.mid, isNotNull);
    expect(first.owner.name, isNotEmpty);
    expect(first.stat, isNotNull);

    print('✅ Integration test passed');
    print('   Got ${list.length} recommendations');
    print('   First video: ${first.title}');
  });

  testWidgets('Rcmd API Flutter fallback test', (tester) async {
    // Disable Rust (use Flutter)
    GStorage.setting.put(SettingBoxKey.useRustRcmdApi, false);

    final result = await VideoHttp.rcmdVideoList(
      ps: 20,
      freshIdx: 0,
    );

    expect(result, isA<Success>());

    final list = (result as Success).response as List;
    expect(list, isNotEmpty);

    print('✅ Flutter fallback test passed');
    print('   Got ${list.length} recommendations');
  });
}
```

**Step 2: 运行集成测试**

```bash
flutter test integration_test/rcmd_api_integration_test.dart
```

Expected: PASS

**Step 3: 提交**

```bash
git add integration_test/rcmd_api_integration_test.dart
git commit -m "test(integration): add rcmd API integration tests

- Test Rust implementation end-to-end
- Test Flutter fallback
- Verify data integrity
- Validate field completeness

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 14: 文档更新

**Files:**
- Create: `docs/plans/2025-02-07-rcmd-api-migration-summary.md`

**Step 1: 创建迁移总结文档**

```markdown
# Web推荐API Rust迁移完成报告

**Date:** 2025-02-07
**Status:** ✅ Complete
**Branch:** feature/rcmd-api-rust-migration

---

## 实现总结

### 已完成组件

✅ **Rust WBI签名实现**
- get_mixin_key() - 混淆密钥生成
- enc_wbi() - 参数签名
- get_wbi_keys_cached() - 密钥获取（带24小时缓存）

✅ **Rust推荐API**
- get_recommend_list() - 完整的网络请求实现
- WBI签名集成
- JSON解析和数据过滤

✅ **Dart适配器**
- RcmdAdapter - 转换Rust模型到Flutter模型
- 完整字段映射

✅ **Facade模式**
- RcmdApiFacade - 路由到Rust或Flutter实现
- 自动fallback机制
- Metrics追踪

✅ **Feature Flag**
- useRustRcmdApi - 独立开关
- 集成到BetaTestingManager

✅ **测试覆盖**
- 单元测试（adapter）
- 集成测试（API）
- A/B对比测试

### 架构一致性

与Video API迁移保持一致：
- 相同的Facade模式
- 相同的错误处理
- 相同的metrics追踪
- 相同的beta testing集成

### 测试结果

```
✅ Unit tests: PASS
✅ Integration tests: PASS
✅ A/B comparison: PASS
✅ Fallback mechanism: PASS
```

---

## 使用方法

### 开发者手动测试

```dart
// 启用Rust实现
GStorage.setting.put(SettingBoxKey.useRustRcmdApi, true);

// 调用API
final result = await VideoHttp.rcmdVideoList(ps: 20, freshIdx: 0);
```

### Beta测试

推荐API自动使用与Video API相同的cohort分配：

```dart
await BetaTestingManager.initialize();
// Pref.useRustRcmdApi 将根据用户hash自动设置
```

### 监控

查看Beta Testing摘要：

```dart
final summary = BetaTestingManager.getSummaryReport();
print(summary);
```

---

## 性能指标

TODO: 填充实际测试数据

| 指标 | Flutter | Rust | 改进 |
|------|---------|------|------|
| P50延迟 | ?ms | ?ms | ?% |
| P95延迟 | ?ms | ?ms | ?% |
| 成功率 | ?% | ?% | - |

---

## 下一步

1. ✅ 代码审查
2. ✅ 合并到主分支
3. 开启beta测试（10%）
4. 监控指标
5. 逐步扩大rollout

---

## 相关文档

- 设计文档: `docs/plans/2025-02-07-rcmd-api-rust-migration-design.md`
- 实施计划: `docs/plans/2025-02-07-rcmd-api-implementation-plan.md`
- Flutter UI集成: `docs/plans/2025-02-06-flutter-ui-integration.md`
```

**Step 2: 提交文档**

```bash
git add docs/plans/2025-02-07-rcmd-api-migration-summary.md
git commit -m "docs: add rcmd API migration summary report

- Document all completed components
- Usage instructions
- Performance metrics section
- Next steps for rollout

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 15: 最终验证和准备合并

**Files:**
- All files

**Step 1: 运行所有测试**

```bash
# Rust tests
cd rust && cargo test

# Dart tests
flutter test

# Integration tests
flutter test integration_test/rcmd_api_integration_test.dart
```

Expected: All PASS

**Step 2: 代码格式化**

```bash
# Format Dart code
dart format .

# Format Rust code
cd rust && cargo fmt
```

**Step 3: 静态分析**

```bash
flutter analyze
cd rust && cargo clippy
```

Expected: No errors, only warnings if acceptable

**Step 4: 构建验证**

```bash
# Debug build
flutter build apk --debug

# Release build (optional)
flutter build apk --release
```

Expected: Build success

**Step 5: 检查git状态**

```bash
git status
```

Expected: Only uncommitted changes should be docs

**Step 6: 创建pull request或准备合并**

```bash
# Checkout main branch
git checkout main

# Merge feature branch
git merge feature/rcmd-api-rust-migration

# Or create PR using GitHub
gh pr create --title "feat: migrate recommendation API to Rust" \
             --body "Implement complete WBI signing and recommendation API in Rust

- Add WBI signature generation and caching
- Implement get_recommend_list() API
- Add Dart adapter and facade
- Integrate into beta testing
- Full test coverage

See design doc: docs/plans/2025-02-07-rcmd-api-rust-migration-design.md"
```

**Step 7: 清理worktree（可选，合并后）**

```bash
git worktree remove .worktrees/rcmd-api
```

---

## 总结

**总计15个任务，预计3-4天完成：**

1. ✅ Rust WBI签名 - 混淆密钥生成 (30分钟)
2. ✅ Rust WBI签名 - 参数签名 (1小时)
3. ✅ Rust WBI签名 - 密钥获取 (1.5小时)
4. ✅ Rust数据模型 (30分钟)
5. ✅ Rust推荐API (2小时)
6. ✅ 生成Dart绑定 (15分钟)
7. ✅ Dart适配器 (1小时)
8. ✅ Facade实现 (1.5小时)
9. ✅ Feature flag (15分钟)
10. ✅ 集成到VideoHttp (30分钟)
11. ✅ Beta testing集成 (30分钟)
12. ✅ A/B对比测试 (1小时)
13. ✅ 集成测试 (1小时)
14. ✅ 文档更新 (1小时)
15. ✅ 最终验证 (1小时)

**总时间：约13小时实际编码 + 测试**

---

## 相关技能引用

- @superpowers:executing-plans - 执行此计划
- @superpowers:systematic-debugging - 调试问题
- @superpowers:test-driven-development - TDD方法
- @superpowers:finishing-a-development-branch - 完成开发分支
