# A方案：完全替代Dart HTTP - 详细设计文档

**项目代号**: Rust HTTP Big Bang
**方案类型**: A方案（大爆炸完全重写）
**创建日期**: 2025-02-07
**预计工期**: 4-6周全职开发
**状态**: 设计完成，待实施

---

## 📋 执行摘要

### 决策
采用**A方案：大爆炸完全重写**，用Rust完全替代Dio/Dart HTTP层，冻结功能开发4-6周，全职投入完成迁移。

### 目标
- 移除所有Dio依赖
- 在Rust中实现完整的HTTP层
- 迁移所有26个API模块
- 实现完整登录系统（5种方式）
- 实现Rust原生弹幕系统（WebSocket）
- 性能提升30-40%，内存减少40-50%

### 风险
- **高风险**：大爆炸重写，无自动回滚
- **功能冻结**：4-6周无法添加新功能
- **测试负担**：完全依赖手动测试

---

## 🎯 核心设计原则

1. **完全重写**：不保留Dio，用reqwest完全替代
2. **手动迁移**：每个API手动精心实现，不使用脚本
3. **简化架构**：移除拦截器复杂性，用Rust原生方式
4. **功能完整**：所有现有功能在Rust中重实现
5. **性能优先**：充分利用Rust性能优势

---

## 🏗️ 架构设计

### 整体架构图

```
┌─────────────────────────────────────────────┐
│         Flutter UI Layer (不变)              │
│     GetX Controllers + Widgets              │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────┴───────────────────────────┐
│         HTTP Facade Layer (简化)            │
│  统一接口，内部全部调用 Rust                │
└─────────────────┬───────────────────────────┘
                  │ FFI Bridge
┌─────────────────┴───────────────────────────┐
│          Rust HTTP Layer (NEW)              │
│  ┌─────────────────────────────────────┐   │
│  │  AccountService (NEW完整实现)       │   │
│  │  • 多账户管理                       │   │
│  │  • Cookie 自动注入                  │   │
│  │  • Session 管理                     │   │
│  │  • 跨FFI状态同步                    │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  HttpClient (reqwest增强)           │   │
│  │  • HTTP/2 支持                      │   │
│  │  • 连接池 (100连接)                 │   │
│  │  • 指数退避重试                    │   │
│  │  • HTTP 缓存 (ETag)                 │   │
│  │  • Brotli/GZIP 解压                 │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  LoginService (NEW完整实现)         │   │
│  │  • QR码登录                         │   │
│  │  • SMS验证码登录                    │   │
│  │  • 密码登录                         │   │
│  │  • Web Cookie登录                   │   │
│  │  • TV QR登录                        │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  DanmakuService (NEW完整实现)       │   │
│  │  • WebSocket连接                    │   │
│  │  • 实时消息处理                     │   │
│  │  • 弹幕过滤                         │   │
│  │  • 自动重连                         │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  API Modules (26个)                 │   │
│  │  • Phase 1: 9个已完成               │   │
│  │  • Phase 2: 4个高优先级             │   │
│  │  • Phase 3: 5个中优先级             │   │
│  │  • Phase 4: 5个低优先级             │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
                  │
                  ↓
         Bilibili API Server
```

### 与现有架构的对比

**现有架构（混合）**:
```
UI → Facade → [Rust (35%) OR Dart (65%)] → API
```

**目标架构（纯Rust）**:
```
UI → Facade → [Rust 100%] → API
```

---

## 📦 核心组件详细设计

### 1. AccountService（账户服务）

**文件**: `rust/src/services/account.rs`

**职责**:
- 多账户存储和管理（SQLite）
- Cookie 自动注入到HTTP请求
- Session 过期检测和自动刷新
- 账户切换和状态通知
- 跨 FFI 状态同步

**API设计**:
```rust
pub struct AccountService {
    current_account: Arc<RwLock<Option<Account>>>,
    all_accounts: Arc<RwLock<Vec<Account>>>,
    cookie_jar: Arc<Mutex<CookieJar>>,
    storage: Arc<StorageService>,
    change_tx: broadcast::Sender<AccountChange>,
}

impl AccountService {
    // Cookie 管理
    pub async fn inject_cookies(&self, request: &mut Request)
        -> Result<(), AccountError>;

    // 账户操作
    pub async fn switch_account(&self, account_id: &str)
        -> Result<(), AccountError>;
    pub async fn add_account(&self, account: Account)
        -> Result<(), AccountError>;
    pub async fn remove_account(&self, account_id: &str)
        -> Result<(), AccountError>;
    pub async fn current_account(&self) -> Option<Account>;

    // Session 管理
    pub async fn refresh_session(&self)
        -> Result<(), AccountError>;
    pub async fn validate_session(&self) -> bool;

    // 状态通知
    pub fn account_changes(&self) -> broadcast::Receiver<AccountChange>;
}
```

**数据模型**:
```rust
#[derive(Clone, Serialize, Deserialize, Debug)]
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

#[derive(Clone, Serialize, Deserialize, Debug)]
pub struct AuthTokens {
    pub access_token: Option<String>,
    pub refresh_token: Option<String>,
    pub expires_at: Option<i64>,
}
```

**依赖**: StorageService, tokio, serde

---

### 2. HttpClient（HTTP客户端）

**文件**: `rust/src/http/client.rs`

**职责**:
- HTTP/2 连接和连接池
- 自动重试（指数退避）
- HTTP 缓存（ETag/Last-Modified）
- Brotli/GZIP 自动解压
- 统一错误处理

**API设计**:
```rust
pub struct HttpClient {
    client: reqwest::Client,
    cache: Arc<HttpCache>,
    account: Arc<AccountService>,
}

impl HttpClient {
    // 通用请求方法
    pub async fn get<T: DeserializeOwned>(
        &self,
        url: &str,
        with_auth: bool,
    ) -> Result<T, ApiError>;

    pub async fn post<T: DeserializeOwned>(
        &self,
        url: &str,
        body: serde_json::Value,
        with_auth: bool,
    ) -> Result<T, ApiError>;

    // 内部方法
    async fn execute_with_retry<T>(
        &self,
        request: RequestBuilder,
        max_retries: u32,
    ) -> Result<T, ApiError>;

    fn decompress_response(&self,
        response: Response
    ) -> Result<Vec<u8>, ApiError>;
}
```

**配置**:
```rust
// reqwest Client 配置
let client = reqwest::Client::builder()
    .http2_prior_knowledge()  // HTTP/2
    .pool_max_idle_per_host(100)  // 连接池
    .pool_idle_timeout(Duration::from_secs(90))
    .timeout(Duration::from_secs(30))
    .build()?;
```

**缓存策略**:
```rust
pub struct HttpCache {
    store: Arc<Mutex<HashMap<String, CacheEntry>>>,
}

struct CacheEntry {
    data: Vec<u8>,
    etag: Option<String>,
    last_modified: Option<String>,
    expires_at: i64,
}

impl HttpCache {
    // GET 请求先查缓存
    pub async fn get(&self, url: &str)
        -> Option<Vec<u8>>;

    // 304响应更新缓存
    pub async fn update(&self, url: &str,
        data: Vec<u8>, headers: &HeaderMap);
}
```

**依赖**: reqwest, tokio, async-trait

---

### 3. LoginService（登录服务）

**文件**: `rust/src/services/login.rs`

**职责**:
- 5种登录方式实现
- 登录状态实时通知
- Session 创建和管理
- 验证码处理

**API设计**:
```rust
pub struct LoginService {
    http: Arc<HttpClient>,
    account: Arc<AccountService>,
    login_tx: broadcast::Sender<LoginEvent>,
}

#[derive(Clone, Serialize, Deserialize, Debug)]
pub enum LoginEvent {
    QrCode { url: String, expiry: u64 },
    QrScanned,
    QrSuccess { account: Account },
    QrExpired,
    SmsSent { phone: String },
    SmsSuccess { account: Account },
    PasswordSuccess { account: Account },
    WebCookieSuccess { account: Account },
    Error { message: String },
}

impl LoginService {
    // QR 码登录
    pub async fn login_qr(&self)
        -> broadcast::Receiver<LoginEvent>;

    // SMS 验证码登录
    pub async fn login_sms_send(
        &self,
        phone: &str,
        country_code: &str
    ) -> Result<(), LoginError>;

    pub async fn login_sms_verify(
        &self,
        phone: &str,
        code: &str
    ) -> Result<Account, LoginError>;

    // 密码登录
    pub async fn login_password(
        &self,
        username: &str,
        password: &str,
        captcha: Option<CaptchaData>,
    ) -> Result<Account, LoginError>;

    // Web Cookie 登录
    pub async fn login_web_cookie(
        &self,
        cookie_str: &str,
    ) -> Result<Account, LoginError>;

    // TV QR 登录
    pub async fn login_tv_qr(&self)
        -> broadcast::Receiver<LoginEvent>;
}
```

**登录流程**:
```
QR登录:
1. 获取QR码 → 生成图片
2. 轮询状态 → 扫码/成功/过期
3. 获取Cookies → 创建Account
4. 存储到数据库 → 切换为当前账户

SMS登录:
1. 发送验证码 → 手机收到
2. 提交验证码 → 验证通过
3. 获取Cookies → 创建Account
4. 存储到数据库 → 切换为当前账户

密码登录:
1. 获取Captcha → 验证码图片
2. 提交用户名+密码+验证码 → 验证通过
3. 获取Cookies → 创建Account
4. 存储到数据库 → 切换为当前账户
```

**依赖**: HttpClient, AccountService, tokio-tungstenite

---

### 4. DanmakuService（弹幕服务）

**文件**: `rust/src/services/danmaku.rs`

**职责**:
- WebSocket 连接管理
- 实时消息接收和解析
- 弹幕过滤和屏蔽
- 自动重连机制

**API设计**:
```rust
pub struct DanmakuService {
    http: Arc<HttpClient>,
    connections: Arc<Mutex<HashMap<i64, DanmakuSession>>>,
}

pub struct DanmakuSession {
    room_id: i64,
    tx: broadcast::Sender<DanmakuEvent>,
    filter: DanmakuFilter,
}

#[derive(Clone, Serialize, Deserialize, Debug)]
pub enum DanmakuEvent {
    Connected { room_id: i64 },
    Message { data: DanmakuMessage },
    Gift { data: GiftData },
    SuperChat { data: SuperChatData },
    OnlineCount { count: u64 },
    Disconnected,
    Error { error: String },
}

impl DanmakuService {
    // 连接到直播间
    pub async fn connect_room(
        &self,
        room_id: i64,
    ) -> broadcast::Receiver<DanmakuEvent>;

    // 发送弹幕
    pub async fn send_message(
        &self,
        room_id: i64,
        message: &str,
    ) -> Result<(), DanmakuError>;

    // 断开连接
    pub async fn disconnect(&self, room_id: i64);

    // 设置过滤规则
    pub async fn set_filter(
        &self,
        room_id: i64,
        filter: DanmakuFilter,
    );
}

// 弹幕过滤
pub struct DanmakuFilter {
    block_keywords: HashSet<String>,
    block_users: HashSet<i64>,
    level_threshold: u8,
    block_gifts: bool,
}

impl DanmakuFilter {
    pub fn should_block(&self, msg: &DanmakuMessage) -> bool {
        // 多层过滤逻辑
    }
}
```

**WebSocket连接流程**:
```
1. 获取房间信息 → 真实房间ID
2. 建立WebSocket连接 → wss://...
3. 发送认证包 → 携带Cookie
4. 进入消息循环 → 接收弹幕
5. 解析数据包 → 转换为事件
6. 发送到Dart → Stream消费
7. 断线重连 → 自动处理
```

**数据包解析**:
```rust
// Bilibili协议包结构
struct Packet {
    length: u32,      // 包长度
    header: u16,      // 协议头
    version: u16,     // 版本
    operation: u32,   // 操作码
    sequence: u32,    // 序列号
    body: Vec<u8>,    // 数据体
}

fn parse_packet(data: &[u8]) -> Option<DanmakuEvent> {
    // 1. 解包（16字节头）
    // 2. 解压（zlib）
    // 3. 解析（protobuf/json）
    // 4. 转换为事件
}
```

**依赖**: tokio-tungstenite, bytes, protobuf

---

### 5. API模块（26个）

**已完成的9个** (Phase 1):
- ✅ video.rs - 视频信息
- ✅ rcmd.rs - Web推荐
- ✅ rcmd_app.rs - App推荐
- ✅ user.rs - 用户信息
- ✅ search.rs - 搜索
- ✅ comments.rs - 评论
- ✅ dynamics.rs - 动态
- ✅ live.rs - 直播
- ✅ download.rs - 下载

**需要实现的17个**:

**Phase 2（高优先级）**:
- 🔄 login.rs - 登录（NEW）
- 🔄 member.rs - 成员/粉丝/关注
- 🔄 reply.rs - 回复系统
- 🔄 danmaku.rs - 弹幕（NEW）

**Phase 3（中优先级）**:
- 📋 fan.rs - 番剧
- 📋 fav.rs - 收藏
- 📋 follow.rs - 关注关系
- 📋 msg.rs - 消息通知
- 📋 pgc.rs - PGC内容

**Phase 4（低优先级）**:
- 📋 black.rs - 黑名单
- 📋 match.rs - 匹配
- 📋 music.rs - 音乐
- 📋 sponsor_block.rs - 赞助屏蔽
- 📋 validate.rs - 验证

**统一API模式**:
```rust
use flutter_rust_bridge::frb;
use crate::services::get_services;
use crate::error::BridgeResult;

#[frb]
pub async fn api_method(
    param1: String,
    param2: i64,
) -> BridgeResult<ResponseType> {
    let services = get_services();

    // 构建请求
    let url = format!("/x/endpoint/{}", param1);

    // 发送（自动注入Cookie、重试、缓存）
    let response = services.http
        .get(&url, true)
        .await?;

    Ok(response)
}
```

---

## 🗂️ 文件结构

### Rust端文件

```
rust/src/
├── api/
│   ├── bridge.rs              ✅ 已有
│   ├── video.rs               ✅ 已有
│   ├── rcmd.rs                ✅ 已有
│   ├── rcmd_app.rs            ✅ 已有
│   ├── user.rs                ✅ 已有
│   ├── search.rs              ✅ 已有
│   ├── comments.rs            ✅ 已有
│   ├── dynamics.rs            ✅ 已有
│   ├── live.rs                ✅ 已有
│   ├── download.rs            ✅ 已有
│   ├── login.rs               🔄 需要实现
│   ├── member.rs              🔄 需要实现
│   ├── reply.rs               🔄 需要实现
│   ├── danmaku.rs             🔄 需要实现
│   ├── fan.rs                 📋 待实现
│   ├── fav.rs                 📋 待实现
│   ├── follow.rs              📋 待实现
│   ├── msg.rs                 📋 待实现
│   ├── pgc.rs                 📋 待实现
│   ├── black.rs               📋 待实现
│   ├── match.rs               📋 待实现
│   ├── music.rs               📋 待实现
│   ├── sponsor_block.rs       📋 待实现
│   ├── validate.rs            📋 待实现
│   └── mod.rs                 需要更新
│
├── services/
│   ├── account.rs             🔄 需要重写
│   ├── login.rs               🔄 新增
│   ├── danmaku.rs             🔄 新增
│   ├── http.rs                🔄 需要重写
│   ├── cache.rs               🔄 新增
│   └── mod.rs                 需要更新
│
├── http/
│   ├── client.rs              🔄 需要重写
│   ├── cache.rs               🔄 新增
│   ├── retry.rs               🔄 新增
│   └── mod.rs                 需要更新
│
├── models/
│   ├── account.rs             ✅ 已有
│   ├── login.rs               🔄 新增
│   ├── danmaku.rs             🔄 新增
│   └── ...
│
└── lib.rs                     需要更新
```

### Dart端文件（删除）

```
lib/http/
├── dio.dart                  ❌ 删除
├── retry_interceptor.dart    ❌ 删除
├── user.dart                  ❌ 删除
├── [其他旧文件]              部分删除

utils/accounts/
└── manager.dart              ❌ 用Rust替代
```

### pubspec.yaml（更新）

```yaml
dependencies:
  # 移除
  dio: 5.4.0                  ❌ 删除
  dio_http2_adapter: 2.3.0    ❌ 删除
  cookie_jar: 4.0.8           ❌ 删除

  # 保留
  pilicore:
    path: rust_builder
  flutter_rust_bridge: 2.11.1
```

---

## 📅 实施时间表

### Week 1: 高优先级API（Phase 2）

| 日期 | 任务 | 预期产出 | 里程碑 |
|------|------|----------|--------|
| Day 1-2 | login.rs - QR登录、密码登录 | 2种登录方式 | - |
| Day 3 | login.rs - SMS、TV、Web Cookie | 3种登录方式 | - |
| Day 4 | member.rs - 关注/粉丝/统计 | 完整功能 | - |
| Day 5 | reply.rs - 嵌套回复 | 完整功能 | **M1** |

**M1 (Week 1 Day 5)**: 核心功能完成
- ✅ 登录系统5种方式
- ✅ 账户管理完整
- ✅ 成员和回复API

---

### Week 2: 弹幕和集成（Phase 2）

| 日期 | 任务 | 预期产出 | 里程碑 |
|------|------|----------|--------|
| Day 1 | danmaku.rs - WebSocket连接 | 基础连接 | - |
| Day 2 | danmaku.rs - 消息解析 | 弹幕接收 | - |
| Day 3 | danmaku.rs - 过滤和重连 | 完整功能 | - |
| Day 4 | 集成测试 | 测试报告 | - |
| Day 5 | Bug修复 | 稳定版本 | **M2** |

**M2 (Week 2 Day 5)**: Phase 2完成
- ✅ 弹幕系统完整
- ✅ 所有核心API工作
- ✅ 集成测试通过

---

### Week 3: 中优先级API（Phase 3）

| 日期 | 任务 | 预期产出 |
|------|------|----------|
| Day 1 | fan.rs + fav.rs | 2个API |
| Day 2 | follow.rs + msg.rs | 2个API |
| Day 3-4 | pgc.rs | 复杂API |
| Day 5 | 测试和修复 | 稳定版本 |

---

### Week 4: 低优先级API（Phase 4）

| 日期 | 任务 | 预期产出 | 里程碑 |
|------|------|----------|--------|
| Day 1 | black.rs + match.rs | 2个API |
| Day 2 | music.rs + sponsor_block.rs | 2个API |
| Day 3 | validate.rs | 最后1个 |
| Day 4-5 | 全面测试 | 测试报告 | **M3** |

**M3 (Week 4 Day 5)**: 所有API完成
- ✅ 26个API全部迁移
- ✅ 100%功能对等
- ✅ 测试覆盖完整

---

### Week 5: 清理和优化

| 日期 | 任务 | 预期产出 |
|------|------|----------|
| Day 1-2 | 移除Dio代码 | 代码库简化 |
| Day 3 | 简化HTTP层 | 架构统一 |
| Day 4 | 性能优化 | 性能提升 |
| Day 5 | 最终测试 | 稳定版本 |

---

### Week 6: 发布准备

| 日期 | 任务 | 预期产出 |
|------|------|----------|
| Day 1-2 | 压力测试 | 性能报告 |
| Day 3 | 文档完善 | 完整文档 |
| Day 4 | Code Review | 审查通过 |
| Day 5 | 正式发布 | **M4** |

**M4 (Week 6 Day 5)**: 正式发布
- ✅ 生产就绪
- ✅ 文档完整
- ✅ 性能达标

---

## ✅ 成功标准

### 技术指标

**必须达成**:
- ✅ 所有26个API在Rust中实现
- ✅ 100%功能对等（相比Dart）
- ✅ API响应时间 <100ms (p50)
- ✅ 内存使用减少≥30%
- ✅ 零崩溃（生产环境）
- ✅ 所有登录方式工作
- ✅ 弹幕实时性<100ms延迟

**期望达成**:
- 🎯 API响应时间 <80ms (p50)
- 🎯 内存使用减少≥40%
- 🎯 CPU使用减少≥25%
- 🎯 代码量减少≥30%

### 功能验收

**登录系统**:
- ✅ QR码登录成功
- ✅ 密码登录成功
- ✅ SMS验证码登录成功
- ✅ Web Cookie登录成功
- ✅ TV QR登录成功
- ✅ 多账户切换正常
- ✅ Session自动刷新

**弹幕系统**:
- ✅ 连接稳定性>99%
- ✅ 消息延迟<100ms
- ✅ 过滤功能正常
- ✅ 礼物消息正常
- ✅ 在线人数准确
- ✅ 自动重连成功

**其他API**:
- ✅ 所有接口功能正常
- ✅ 数据解析正确
- ✅ 错误处理完善
- ✅ Cookie注入正确
- ✅ 重试机制有效

---

## ⚠️ 风险管理

### 风险评估矩阵

| 风险 | 影响 | 概率 | 风险等级 | 缓解措施 |
|------|------|------|----------|----------|
| 功能遗漏 | 高 | 中 | 🔴高 | 详细对比，逐个测试 |
| 性能回归 | 中 | 低 | 🟡中 | 基准测试，早期发现 |
| 登录失败 | 高 | 中 | 🔴高 | 充分测试所有方式 |
| 弹幕不稳定 | 中 | 中 | 🟡中 | 完善错误处理 |
| 延期交付 | 高 | 低 | 🟡中 | 每日追踪，及时调整 |
| 引入Bug | 高 | 中 | 🔴高 | 立即测试，快速修复 |

### 应急计划

**技术难题（>1天无法解决）**:
1. 寻求帮助（社区、文档、专家）
2. 降级实现（先核心功能，后续完善）
3. 保留Dart fallback（临时方案）

**严重Bug（阻塞发布）**:
1. 立即回滚到上一个稳定commit
2. 分析根因（日志、调试）
3. 修复后重新测试
4. 回归测试确保无新问题

**进度延期（>1周）**:
1. 重新评估剩余工作
2. 优先级排序（核心功能优先）
3. 调整计划（缩减非核心功能）
4. 延长1-2周（如必要）

---

## 📊 预期收益

### 性能提升

| 指标 | 当前(Dart) | 目标(Rust) | 提升 |
|------|------------|-----------|------|
| API响应时间(p50) | 85ms | 60ms | 29% ↑ |
| API响应时间(p95) | 180ms | 130ms | 28% ↑ |
| 内存使用 | 45MB | 27MB | 40% ↓ |
| CPU使用 | 18% | 13% | 28% ↓ |
| JSON解析 | 12ms | 3ms | 75% ↑ |

### 代码质量

| 指标 | 改善 |
|------|------|
| 代码行数 | -30% |
| 依赖数量 | -5个包 |
| 编译时检查 | 更严格 |
| 类型安全 | 100% |
| 内存安全 | Rust保证 |

### 开发体验

| 改善 | 说明 |
|------|------|
| 统一架构 | 单一HTTP层 |
| 更好的工具 | Cargo工具链 |
| 性能分析 | Rust profiler |
| 错误处理 | thiserror类型 |

---

## 🧪 测试策略

### 手动测试（主要方法）

**每个API的测试流程**:
1. 正常场景测试
2. 错误场景测试（网络错误、超时）
3. 边界条件测试（空值、大数据）
4. 性能测试（响应时间）
5. 集成测试（与UI集成）

**测试工具**:
- Flutter DevTools（性能分析）
- 内存分析（Profiler）
- 日志查看（tracing输出）

### 对比验证（辅助方法）

**A/B对比工具**:
```dart
// 开发阶段对比工具
class ApiComparator {
  static Future<void> compare(String api, Map<String, dynamic> params) async {
    final rust = await rustApiCall(api, params);
    final dart = await dartApiCall(api, params);

    print('Rust: $rust');
    print('Dart: $dart');

    if (rust != dart) {
      print('❌ Mismatch detected!');
    }
  }
}
```

---

## 📚 依赖管理

### 新增Rust依赖

```toml
[dependencies]
# 已有
flutter_rust_bridge = "2.11.1"
tokio = { version = "1.35", features = ["full"] }
reqwest = { version = "0.11", default-features = false,
           features = ["json", "cookies", "brotli", "native-tls"] }
sqlx = { version = "0.7", features = ["runtime-tokio", "sqlite", "chrono"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
thiserror = "1.0"
uuid = { version = "1.6", features = ["v4", "v5", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
once_cell = "1.19"
tracing = "0.1"
tracing-subscriber = "0.3"
bytes = "1.5"
flume = "0.11"
async-stream = "0.3"
futures = "0.3"
urlencoding = "2.1"
md5 = "0.7"
percent-encoding = "2.3"

# 新增
tokio-tungstenite = "0.21"  # WebSocket
protobuf = "3.4"            # 弹幕协议
zlib = "0.11"               # 弹幕解压
base64 = "0.21"             # 编码
hmac = "0.12"               # 签名
sha2 = "0.10"               # 哈希
```

### 移除Dart依赖

```yaml
# pubspec.yaml - 移除
dependencies:
  dio: 5.4.0                  # ❌
  dio_http2_adapter: 2.3.0    # ❌
  cookie_jar: 4.0.8           # ❌
```

---

## 📝 文档计划

### 创建的文档

1. **设计文档**（本文档）
   - 完整架构设计
   - API设计规范
   - 实施计划

2. **API迁移文档**（每个API一篇）
   - 功能说明
   - 实现细节
   - 测试结果

3. **最终报告**
   - 项目总结
   - 性能对比
   - 经验教训

---

## 🎯 下一步行动

### 立即行动

1. **创建实施计划**
   - 使用 `superpowers:writing-plans`
   - 详细任务分解
   - 每日任务清单

2. **设置开发环境**
   - 创建新分支：`feature/rust-http-complete`
   - 验证依赖版本
   - 基础设施检查

3. **开始Week 1任务**
   - 实现login.rs
   - 实现AccountService重写
   - 实现HttpClient重写

### 检查点

- **Daily**: 每日commit，总结进度
- **Weekly**: 每周review，评估风险
- **Milestone**: 里程碑验收，调整计划

---

## 📊 项目档案

**项目名称**: Rust HTTP Big Bang
**方案类型**: A方案（完全替代）
**预计开始**: 2025-02-08
**预计完成**: 2025-03-15（6周）
**预算**: 1人全职 × 6周

**关键决策**:
- ✅ 大爆炸重写（非渐进式）
- ✅ 全职开发（非并行）
- ✅ 手动迁移（非脚本）
- ✅ 仅手动测试（非自动化）
- ✅ 简化架构（移除拦截器）

**成功概率**: 70%（高风险但高回报）

---

**文档版本**: 1.0
**创建日期**: 2025-02-07
**最后更新**: 2025-02-07
**状态**: ✅ 设计完成，待实施

**相关文档**:
- 可行性分析: `docs/analysis/2025-02-07-rust-http-replacement-feasibility.md`
- 项目状态: `docs/plans/2025-02-07-project-status-summary.md`

---

**附录**: 暂无
