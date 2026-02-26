# Login Feature

登录特性管理应用的用户认证功能，包括二维码登录、密码登录、短信验证码登录等多种登录方式。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: LoginPage                             │
│  - Widgets: Captcha, CountryCodeSelector        │
│  - Providers: Riverpod 状态管理                 │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: QrCode, LoginResult, SmsCode       │
│  - Repositories: LoginRepository                │
│  - Use Cases: GetQRCode, LoginByPassword, etc.  │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - DataSources: 登录API远程数据源               │
│  - RepositoryImpls: 仓库实现                    │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
lib/features/login/
├── domain/                  # 领域层（核心业务逻辑）
│   ├── entities/           # 实体类
│   │   ├── qr_code_entity.dart
│   │   ├── login_result_entity.dart
│   │   ├── sms_code_entity.dart
│   │   └── risk_verify_info_entity.dart
│   ├── repositories/       # 仓库接口
│   │   └── login_repository.dart
│   └── usecases/          # 用例
│       ├── get_qr_code.dart
│       ├── login_by_password.dart
│       ├── send_sms_code.dart
│       └── login_by_sms.dart
├── data/                   # 数据层（数据获取和持久化）
│   ├── datasources/       # 数据源
│   │   └── login_api_datasource.dart
│   └── repositories/      # 仓库实现
│       └── login_repository_impl.dart
├── presentation/          # 表现层（UI 和状态管理）
│   ├── providers/         # Riverpod providers
│   │   ├── login_providers.dart
│   │   └── login_controller.dart
│   └── pages/            # 页面
│       ├── login_page.dart
│       ├── login_controller.dart (GetX @deprecated)
│       └── geetest/
│           └── geetest_webview_dialog.dart
├── login.dart             # 导出文件
└── README.md             # 本文件
```

## 核心功能

### 1. 二维码登录

- **实体**: `QrCodeEntity` 管理二维码信息
- **用例**: `GetQRCodeUseCase` 获取二维码
- **状态**: `LoginController.qrCode` 保存二维码信息
- **轮询**: 自动轮询扫码状态

### 2. 密码登录

- **实体**: `LoginResultEntity` 表示登录结果
- **用例**: `LoginByPasswordUseCase` 执行密码登录
- **方法**: `LoginController.loginWithPassword()` 执行登录

### 3. 短信验证码登录

- **实体**: `SmsCodeEntity` 表示验证码信息
- **用例**: `SendSmsCodeUseCase` 发送验证码
- **用例**: `LoginBySmsUseCase` 短信登录
- **方法**: `LoginController.sendSmsCode()` 发送验证码
- **方法**: `LoginController.loginWithSms()` 执行登录

### 4. 风控验证

- **实体**: `RiskVerifyInfoEntity` 风控验证信息
- **处理**: 自动识别并处理风控验证流程

### 5. 状态管理（Riverpod）

- **`loginControllerProvider`**: 登录状态管理
- **状态包含**: 加载状态、错误信息、二维码、验证码等

## 使用方法

### 在代码中使用 Providers

```dart
// 在 Widget 中使用
class LoginWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);
    final loginController = ref.read(loginControllerProvider.notifier);

    return Scaffold(
      body: loginState.isLoading
          ? CircularProgressIndicator()
          : LoginForm(),
    );
  }
}
```

### 二维码登录

```dart
// 获取二维码
ref.read(loginControllerProvider.notifier).fetchQRCode();

// 检查登录结果
if (loginState.loginResult?.isSuccess == true) {
  // 登录成功，保存账号信息
}
```

### 密码登录

```dart
// 执行密码登录
ref.read(loginControllerProvider.notifier).loginWithPassword(
  username: 'username',
  password: 'password',
);

// 检查是否需要风控验证
if (loginState.loginResult?.needRiskVerify == true) {
  // 显示风控验证界面
}
```

### 短信验证码登录

```dart
// 发送验证码
ref.read(loginControllerProvider.notifier).sendSmsCode(
  tel: '13800138000',
  cid: countryCode.countryId,
);

// 验证码登录
ref.read(loginControllerProvider.notifier).loginWithSms(
  tel: '13800138000',
  code: '123456',
  cid: countryCode.countryId,
);
```

## 迁移状态

本特性正在进行从 GetX 到 Riverpod + 干净架构的迁移。

### 已完成 ✅

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、仓库实现）
- ✅ Presentation 层（Providers、Controller）
- ⏳ UI 层迁移（待进行）

### 待完成 🚧

- ⏳ 将现有页面迁移到新的状态管理
- ⏳ 添加完整的错误处理
- ⏳ 集成账号保存逻辑
- ⏳ 添加完整的测试用例

### 保留文件（向后兼容）

以下文件保留用于向后兼容，将在迁移完成后标记为 `@Deprecated`：

- `presentation/pages/login_controller.dart` - 旧的 `LoginPageController`（GetX）

这些文件可以在确认所有功能正常后被删除。

## 依赖规则

- **Domain Layer**: 不依赖任何外层，纯粹的业务逻辑
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 错误处理

所有用例都定义了明确的错误处理：

```dart
try {
  await loginController.loginWithPassword(
    username: username,
    password: password,
  );
} on ValidationFailure catch (e) {
  // 处理验证错误
  print('Validation error: ${e.message}');
} on ServerFailure catch (e) {
  // 处理服务器错误
  print('Server error: ${e.message}');
} on NetworkFailure catch (e) {
  // 处理网络错误
  print('Network error: ${e.message}');
}
```

## 相关文件

- 登录模型: `lib/models/login/model.dart`
- 登录常量: `lib/core/constants/login_api_constants.dart`
- 账号管理: `lib/utils/accounts.dart`
- HTTP客户端: `lib/core/network/http_client.dart`
