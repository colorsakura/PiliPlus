# Authentication Feature

Handles user authentication operations including TV QR code login, password login, and SMS verification.

## Architecture

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

\`\`\`
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - TVQRLoginPage: TV扫码登录页面                │
│  - TVQRLoginController: 登录状态管理             │
│  - auth_providers: Riverpod providers          │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - FetchTVCodeParams, PollQRCodeParams: 参数  │
│  - QRCodePollResult: 轮询结果                   │
│  - AuthRepository: 仓库接口                    │
│  - FetchTVCode, PollQRCode: 用例               │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - AuthRemoteDataSource: API实现               │
│  - AuthRemoteDataSourceImpl: 接口适配          │
│  - AuthRepositoryImpl: 仓库实现                │
└─────────────────────────────────────────────────┘
\`\`\`

## 目录结构

\`\`\`
lib/features/auth/
├── domain/                      # 领域层
│   ├── entities/               # 实体类
│   │   └── auth_params.dart
│   ├── repositories/           # 仓库接口
│   │   └── auth_repository.dart
│   └── usecases/              # 用例
│       ├── fetch_tv_code.dart
│       ├── poll_qr_code.dart
│       └── query_captcha.dart
├── data/                       # 数据层
│   ├── datasources/           # 数据源
│   │   ├── auth_remote_datasource_interface.dart
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_remote_datasource_impl.dart
│   └── repositories/          # 仓库实现
│       └── auth_repository_impl.dart
├── presentation/              # 表现层
│   ├── providers/            # Riverpod providers
│   │   ├── auth_providers.dart
│   │   └── auth_controller.dart
│   └── pages/                # 页面
│       └── tv_qr_login_page.dart
└── README.md                 # 本文件
\`\`\`

## 核心功能

### 1. TV QR Code Login

**实体**: `FetchTVCodeParams`, `PollQRCodeParams`, `QRCodePollResult`
**用例**: `FetchTVCode`, `PollQRCode`
**状态**: `TVQRLoginState` (Controller管理)

**流程**:
1. 获取TV二维码: `FetchTVCode` → 返回二维码URL和密钥
2. 显示二维码给用户
3. 轮询登录状态: `PollQRCode` → 每2秒检查一次
4. 扫码成功后自动登录

### 2. 状态管理

\`\`\`dart
enum TVQRLoginStatus {
  initial,      // 初始状态
  loading,      // 加载中
  qrCodeReady,  // 二维码已生成
  polling,      // 轮询中
  success,      // 登录成功
  error,        // 错误
  expired,      // 二维码过期
}
\`\`\`

### 3. 使用方法

#### 在页面中使用

\`\`\`dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(tvqrLoginControllerProvider);

    return loginState.status == TVQRLoginStatus.qrCodeReady
        ? TVQRLoginPage()  // 显示二维码
        : ElevatedButton(
            onPressed: () {
              ref.read(tvqrLoginControllerProvider.notifier).fetchQRCode();
            },
            child: Text('获取二维码'),
          );
  }
}
\`\`\`

#### 单独使用用例

\`\`\`dart
// 获取二维码
final fetchTVCode = ref.read(fetchTVCodeUseCaseProvider);
final qrData = await fetchTVCode();
// Display qrData['qrcode_key'] as QR code

// 轮询登录状态
final pollQRCode = ref.read(pollQRCodeUseCaseProvider);
final result = await pollQRCode(
  PollQRCodeParams(authCode: qrData['qrcode_key']),
);
if (result.isSuccess) {
  // Login successful, handle result.data
}
\`\`\`

## 迁移状态

- ✅ Domain 层完成
- ✅ Data 层完成
- ✅ Presentation 层完成
- ⏳ 测试进行中
- ✅ 文档完成

## 依赖规则

- **Domain Layer**: 不依赖任何外层
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 实现说明

### Data Source 包装器模式

AuthRemoteDataSourceImpl 使用包装器模式:
- `AuthRemoteDataSource`: 原有实现，包含所有HTTP逻辑
- `AuthRemoteDataSourceImpl`: 实现 `IAuthRemoteDataSource` 接口
- 保留了现有实现，同时添加了干净架构接口

### 轮询机制

- 每2秒轮询一次二维码状态
- 倒计时显示二维码剩余时间
- 自动处理过期和成功状态

## 相关文件

- 错误处理: `lib/core/errors/`
- 网络层: `lib/core/network/`
- 迁移指南: `docs/CLEAN_ARCHITECTURE_MIGRATION.md`
- 参考实现: `lib/features/login/`
