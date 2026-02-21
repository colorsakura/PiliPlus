# Backup Feature - Clean Architecture with Riverpod 3.x

本功能展示了如何将传统代码重构为干净架构 (Clean Architecture) 的最佳实践,使用 **Riverpod 3.2.1** 进行状态管理。

## 架构概览

```
lib/features/backup/
├── domain/                      # 领域层 (核心业务逻辑)
│   ├── entities/                # 实体
│   │   ├── webdav_config.dart
│   │   ├── backup_result.dart
│   │   └── settings_data.dart
│   ├── repositories/            # 仓库接口
│   │   ├── webdav_repository.dart
│   │   ├── settings_repository.dart
│   │   └── backup_config_repository.dart
│   └── usecases/                # 用例
│       ├── initialize_webdav_usecase.dart
│       ├── backup_settings_usecase.dart
│       ├── restore_settings_usecase.dart
│       ├── get_webdav_config_usecase.dart
│       └── save_webdav_config_usecase.dart
├── data/                        # 数据层
│   ├── datasources/             # 数据源
│   │   ├── webdav_remote_datasource.dart
│   │   ├── settings_local_datasource.dart
│   │   └── backup_config_local_datasource.dart
│   └── repositories/            # 仓库实现
│       ├── webdav_repository_impl.dart
│       ├── settings_repository_impl.dart
│       └── backup_config_repository_impl.dart
├── presentation/                # 表现层
│   ├── providers/
│   │   └── backup_controller.dart    # Notifier + Controller
│   └── pages/
│       └── backup_page.dart
└── providers/                   # 依赖注入层 (DI)
    ├── domain_providers.dart    # Data/Repository/UseCase providers
    └── backup_providers.dart    # Controller provider + 统一导出
```

---

## 分层详解

### 1. Domain 层 (领域层) - 核心业务逻辑

**职责**: 定义核心业务规则和逻辑,不依赖任何外部框架。

| 目录              | 内容                                                   | 说明          |
|-----------------|------------------------------------------------------|-------------|
| `entities/`     | `WebDavConfig`, `BackupResult`, `SettingsData`       | 业务实体类       |
| `repositories/` | 接口定义                                                 | 数据访问契约 (抽象) |
| `usecases/`     | `InitializeWebDavUseCase`, `BackupSettingsUseCase` 等 | 单一业务用例      |

**特点**:

- ✅ 纯 Dart 代码,无框架依赖
- ✅ 可独立测试
- ✅ 可跨项目复用

---

### 2. Data 层 (数据层) - 数据访问实现

**职责**: 实现数据访问逻辑,处理具体技术细节。

| 目录              | 内容                                                    | 说明            |
|-----------------|-------------------------------------------------------|---------------|
| `datasources/`  | `WebDavRemoteDataSource`, `SettingsLocalDataSource` 等 | 直接与外部系统交互     |
| `repositories/` | `WebDavRepositoryImpl`, `SettingsRepositoryImpl` 等    | 实现 Domain 层接口 |

**特点**:

- ✅ 实现 Domain 层定义的接口
- ✅ 处理所有外部依赖 (Hive, WebDAV API)
- ✅ 可通过 Mock 进行测试

---

### 3. Presentation 层 (表现层) - UI 和状态管理

**职责**: 处理 UI 逻辑和用户交互。

| 目录           | 内容                            | 说明                |
|--------------|-------------------------------|-------------------|
| `providers/` | `BackupController` (Notifier) | 状态管理,调用 Use Cases |
| `pages/`     | `BackupPage` (ConsumerWidget) | 纯 UI 组件           |

**特点**:

- ✅ 使用 Riverpod 3.x `Notifier` 管理状态
- ✅ UI 组件通过 `ref.watch()` 读取状态
- ✅ 业务逻辑委托给 Use Cases

---

### 4. Providers 层 (依赖注入层) - DI 配置

**职责**: 创建对象实例,管理依赖关系。

| 文件                      | 内容                                | 说明               |
|-------------------------|-----------------------------------|------------------|
| `domain_providers.dart` | Data/Repository/UseCase Providers | 定义如何创建和注入依赖      |
| `backup_providers.dart` | Controller Provider + Export      | 统一导出所有 Providers |

**特点**:

- ✅ 集中管理依赖注入配置
- ✅ 使用 Riverpod `Provider` 自动解析依赖链
- ✅ 支持开发/生产环境切换

---

## 依赖规则 (依赖倒置)

```
┌─────────────────────────────────────────┐
│         Presentation (UI)               │  ← 使用 Riverpod Notifier
├─────────────────────────────────────────┤
│           Domain (Business)             │  ← 纯 Dart,无框架依赖
│   Entities, Use Cases, Repository I/F   │
├─────────────────────────────────────────┤
│            Data (Implementation)        │  ← 实现 Domain 接口
│   Repository Impl, DataSources          │
└─────────────────────────────────────────┘
              ↑
         Providers (DI)                  ← 连接各层
```

**规则**:

1. Domain 层不依赖任何层
2. Data 层实现 Domain 层接口
3. Presentation 层通过 Use Cases 与 Domain 交互
4. Providers 层负责组装所有依赖

---

## Riverpod 3.x 使用指南

### Notifier & NotifierProvider

```dart
// 1. 定义状态类
class BackupState {
  final WebDavConfig config;
  final bool isLoading;
  final bool obscureText;
  final String? errorMessage;

  const BackupState({
    required this.config,
    this.isLoading = false,
    this.obscureText = true,
    this.errorMessage,
  });

  BackupState copyWith({
    String? uri,
    String? username,
    String? password,
    bool? isLoading,
    bool? obscureText,
    String? errorMessage,
  }) {
    return BackupState(
      config: uri != null || username != null || password != null
          ? WebDavConfig(
              uri: uri ?? config.uri,
              username: username ?? config.username,
              password: password ?? config.password,
            )
          : config,
      isLoading: isLoading ?? this.isLoading,
      obscureText: obscureText ?? this.obscureText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

// 2. 定义 Notifier (Controller)
class BackupController extends Notifier<BackupState> {
  // 通过 getter 访问依赖 (ref 在 build 后可用)
  InitializeWebDavUseCase get _initializeWebDavUseCase =>
      ref.read(initializeWebDavUseCaseProvider);

  @override
  BackupState build() {
    // 返回初始状态
    final config = _getWebDavConfigUseCase();
    return BackupState(config: config);
  }

  void updateUri(String uri) {
    state = state.copyWith(
      config: state.config.copyWith(uri: uri),
    );
  }

  Future<void> backup() async {
    state = state.copyWith(isLoading: true);
    final result = await _backupSettingsUseCase();
    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.message,
    );
  }
}

// 3. 定义 Provider (使用 .new 构造函数引用)
final backupControllerProvider =
    NotifierProvider<BackupController, BackupState>(BackupController.new);
```

### 在 UI 中使用

```dart
class BackupPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  late final TextEditingController _uriCtr;

  @override
  void initState() {
    super.initState();
    final state = ref.read(backupControllerProvider);
    _uriCtr = TextEditingController(text: state.config.uri);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupControllerProvider);
    final controller = ref.read(backupControllerProvider.notifier);

    return Scaffold(
      body: TextField(
        controller: _uriCtr,
        onChanged: controller.updateUri,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isLoading ? null : controller.backup,
      ),
    );
  }
}
```

---

## 优势

| 优势        | 说明                                                |
|-----------|---------------------------------------------------|
| **类型安全**  | Riverpod 3.x 提供编译时类型检查                            |
| **可测试性**  | 每层可独立测试,Use Case 无需 UI 即可测试                       |
| **可维护性**  | 业务逻辑集中在 Domain 层,易于理解和修改                          |
| **可扩展性**  | 添加新功能只需遵循现有模式                                     |
| **依赖注入**  | 自动管理依赖链,无需手动传递依赖                                  |
| **现代语法**  | 使用 Riverpod 3.x 的 `Notifier` (替代 `StateNotifier`) |
| **无代码生成** | 手动编写,无构建工具依赖                                      |

---

## 迁移前后对比

### 迁移前 (传统 GetX MVC)

```dart
// Page 直接调用单例
class BackupPage extends StatefulWidget {
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: WebDav().backup,
      child: Text('备份'),
    );
  }
}

// 单例 Service 直接访问存储
class WebDav {
  WebDav._internal();

  static final WebDav _instance = WebDav._internal();

  factory WebDav() => _instance;

  Future<void> backup() async {
    String data = GStorage.exportAllSettings();
    await client.write(path, data);
  }
}
```

**问题**:

- ❌ 紧耦合: UI 直接依赖 Service 实现
- ❌ 难测试: 无法 Mock WebDav 单例
- ❌ 业务逻辑分散: Service 和 Controller 都有业务逻辑
- ❌ 状态管理混乱: StatefulWidget + 单例 Service

---

### 迁移后 (Clean Architecture + Riverpod 3.x)

```dart
// Page 通过 ConsumerWidget 读取状态
class BackupPage extends ConsumerStatefulWidget {
  Widget build(BuildContext context) {
    final state = ref.watch(backupControllerProvider);
    final controller = ref.read(backupControllerProvider.notifier);

    return FilledButton(
      onPressed: state.isLoading ? null : controller.backup,
      child: Text('备份'),
    );
  }
}

// Controller (Notifier) 管理状态,调用 Use Case
class BackupController extends Notifier<BackupState> {
  @override
  BackupState build() => BackupState(...);

  Future<void> backup() async {
    if (state.config.uri.isEmpty) {
      state = state.copyWith(errorMessage: '请先配置 WebDAV 信息');
      return;
    }

    state = state.copyWith(isLoading: true);

    // 先确保 WebDAV 已初始化
    final initResult = await _initializeWebDavUseCase(state.config);
    if (!initResult.success) {
      state = state.copyWith(errorMessage: initResult.message);
      return;
    }

    // 执行备份
    final result = await _backupSettingsUseCase();
    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.message,
    );
  }
}

// Use Case 封装业务逻辑
class BackupSettingsUseCase {
  Future<BackupResult> call() async {
    final settingsData = await _settingsRepository.exportSettings();
    return await _webDavRepository.backupSettings(settingsData);
  }
}
```

**优势**:

- ✅ 松耦合: UI → Controller → Use Case → Repository
- ✅ 易测试: 每个 Use Case 可独立测试
- ✅ 业务逻辑集中: Domain 层包含所有业务规则
- ✅ 状态管理清晰: Riverpod Notifier 统一管理状态

---

## 技术栈

| 层级       | 技术                | 版本    | 说明               |
|----------|-------------------|-------|------------------|
| **状态管理** | Riverpod Notifier | 3.2.1 | 替代 StateNotifier |
| **依赖注入** | 手动 Provider       | 3.2.1 | 无代码生成            |
| **UI**   | ConsumerWidget    | -     | 响应式 UI           |
| **业务逻辑** | Use Cases         | -     | 单一职责             |
| **数据层**  | Repository 模式     | -     | 数据访问抽象           |
| **本地存储** | Hive              | -     | NoSQL 数据库        |
| **远程通信** | webdav_client     | -     | WebDAV 协议        |

---

## 最佳实践总结

1. **依赖倒置**: Domain 层定义接口,Data 层实现
2. **单一职责**: 每个 Use Case 只做一件事
3. **状态不可变**: 使用 `copyWith` 创建新状态
4. **依赖注入**: 通过 Provider 自动解析依赖
5. **错误处理**: 使用 `BackupResult` 封装操作结果
6. **自动初始化**: 有配置时自动初始化 WebDAV 客户端
7. **用户反馈**: 操作成功/失败都显示 SnackBar 提示

---

## 文件结构说明

```
backup/
├── domain/                      # 核心业务逻辑 (不依赖框架)
│   ├── entities/                # 实体类
│   ├── repositories/            # 仓库接口 (抽象)
│   └── usecases/                # 用例 (业务逻辑)
│
├── data/                        # 数据访问实现
│   ├── datasources/             # 数据源 (Hive, WebDAV API)
│   └── repositories/            # 仓库实现 (实现 Domain 接口)
│
├── presentation/                # UI 和状态管理
│   ├── providers/               # Riverpod Notifier (Controller)
│   └── pages/                   # Flutter Widgets
│
└── providers/                   # 依赖注入配置
    ├── domain_providers.dart    # Data/Repository/UseCase providers
    └── backup_providers.dart    # Controller provider + 导出
```

---

## 导入使用

```dart
// 在需要使用 backup 功能的地方
import 'package:PiliPlus/features/backup/providers/backup_providers.dart';

// 自动导出所有相关 providers
final state = ref.watch(backupControllerProvider);
```
