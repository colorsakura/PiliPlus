# Login Feature

用户登录功能模块，负责处理用户认证和授权。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

\`\`\`
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - SimpleLoginPage: 简化登录页面（演示）          │
│  - SimpleLoginController: 登录状态管理           │
│  - login_providers: Riverpod providers          │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - LoginEntity: 登录实体                        │
│  - LoginRepository: 仓库接口                    │
│  - PerformLoginUseCase: 登录用例               │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - LoginRemoteDatasource: 登录 API（简化）       │
│  - LoginModel: 登录数据模型                     │
│  - LoginRepositoryImpl: 仓库实现                │
│  - LoginMapper: 实体转换                        │
└─────────────────────────────────────────────────┘
\`\`\`

## 目录结构

\`\`\`
lib/features/login/
├── domain/                      # 领域层
│   ├── entities/               # 实体类
│   │   ├── login_entity.dart
│   │   ├── login_result_entity.dart
│   │   ├── qr_code_entity.dart
│   │   └── ...
│   ├── repositories/           # 仓库接口
│   │   └── login_repository.dart
│   └── usecases/              # 用例
│       ├── perform_login.dart  # 简化登录用例
│       ├── login_by_password.dart
│       ├── login_by_sms.dart
│       └── ...
├── data/                       # 数据层
│   ├── datasources/           # 数据源
│   │   ├── login_api_datasource.dart  # 完整实现
│   │   └── login_remote_datasource.dart # 简化演示
│   ├── models/                # 数据模型
│   │   └── login_model.dart
│   ├── repositories/          # 仓库实现
│   │   └── login_repository_impl.dart
│   └── mappers/               # 实体转换
│       └── login_mapper.dart
├── presentation/              # 表现层
│   ├── providers/            # Riverpod providers
│   │   ├── login_providers.dart
│   │   ├── login_controller.dart  # 完整控制器
│   │   └── simple_login_controller.dart # 简化演示
│   ├── pages/                # 页面
│   │   └── simple_login_page.dart
│   └── widgets/              # 组件
└── README.md                 # 本文件
\`\`\`

## 核心功能

### 1. 简化登录（演示用）

本模块包含一个简化的登录实现，用于演示干净架构模式：

**实体**: `LoginEntity` 管理登录状态
**用例**: `PerformLoginUseCase` 执行登录逻辑
**状态**: `SimpleLoginController` 管理登录状态

### 2. 参数验证

- 用户名不能为空
- 密码不能为空
- 密码长度不少于 6 位

### 3. 错误处理

- `ValidationFailure` - 参数验证失败
- `UnauthorizedFailure` - 凭证无效
- `ServerFailure` - 服务器错误
- `NetworkFailure` - 网络错误

### 4. 完整登录功能

模块还包含完整的登录实现，支持：
- 二维码登录
- 密码登录
- 短信验证码登录
- OAuth2 授权
- 风控验证

## 使用方法

### 使用简化的登录（演示）

\`\`\`dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(simpleLoginControllerProvider);

    return loginState.when(
      initial: () => LoginForm(),
      loading: () => CircularProgressIndicator(),
      success: (entity) => HomeScreen(),
      error: (message) => ErrorWidget(message),
    );
  }
}
\`\`\`

### 执行登录

\`\`\`dart
ref.read(simpleLoginControllerProvider.notifier).login(
  username: 'user@example.com',
  password: 'password123',
);
\`\`\`

## 迁移状态

- ✅ Domain 层完成
- ✅ Data 层完成
- ✅ Presentation 层完成
- ✅ 测试完成
- ✅ 文档完成

## 依赖规则

- **Domain Layer**: 不依赖任何外层
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 测试

\`\`\`bash
# 运行登录模块测试
flutter test test/features/login/

# 运行静态分析
flutter analyze lib/features/login/

# 代码格式化
dart format lib/features/login/
\`\`\`

## 注意事项

**重要**: 本模块中的 `SimpleLoginController` 和 `SimpleLoginPage` 是为了演示干净架构模式而创建的简化版本。在生产环境中，应该使用现有的完整登录实现（`LoginController` 和相关页面）。

简化版本仅用于：
- 演示三层架构的分离
- 展示依赖注入模式
- 作为其他模块迁移的参考模板

## 相关文件

- 错误处理: `lib/core/errors/`
- 网络层: `lib/core/network/`
- 路由配置: `lib/app/router/`
- 迁移指南: `docs/CLEAN_ARCHITECTURE_MIGRATION.md`
