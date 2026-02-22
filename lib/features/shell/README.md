# Shell Feature

Shell 特性管理应用的主导航框架，包括底部/侧边导航栏、未读消息/动态检查等功能。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: ShellPage                             │
│  - Widgets: UserAvatar, NavigationRail, etc.    │
│  - Providers: Riverpod 状态管理                 │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: 业务数据模型                       │
│  - Repositories: 仓库接口                       │
│  - Use Cases: 业务逻辑用例                      │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - DataSources: 本地/远程数据源                 │
│  - RepositoryImpls: 仓库实现                    │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
lib/features/shell/
├── domain/                  # 领域层（核心业务逻辑）
│   ├── entities/           # 实体类
│   ├── repositories/       # 仓库接口
│   └── usecases/          # 用例
├── data/                   # 数据层（数据获取和持久化）
│   ├── datasources/       # 数据源
│   └── repositories/      # 仓库实现
├── presentation/          # 表现层（UI 和状态管理）
│   ├── providers/         # Riverpod providers
│   └── pages/            # 页面
├── controller.dart        # 旧 MainController（@deprecated）
├── network_manager.dart   # 旧 NetworkManager（@deprecated）
└── README.md             # 本文件
```

## 核心功能

### 1. 导航管理

- **导航配置**: `NavigationConfig` 实体管理导航栏状态
- **导航仓库**: `NavigationRepository` 负责配置的读写
- **导航用例**: `GetNavigationConfigUseCase` 封装配置业务逻辑

### 2. 未读消息检查

- **消息实体**: `UnreadMessage` 表示未读消息状态
- **消息仓库**: `MessageRepository` 负责获取未读数据
- **检查用例**: `CheckUnreadMessagesUseCase` 封装检查逻辑

### 3. 未读动态检查

- **动态实体**: `UnreadDynamic` 表示未读动态状态
- **动态仓库**: `DynamicRepository` 负责获取未读数据
- **检查用例**: `CheckUnreadDynamicsUseCase` 封装检查逻辑

### 4. 状态管理（Riverpod）

- **`navigationConfigControllerProvider`**: 导航配置状态
- **`navigationStateControllerProvider`**: 导航 UI 状态（滚动偏移等）
- **`unreadMessageControllerProvider`**: 未读消息状态
- **`unreadDynamicControllerProvider`**: 未读动态状态
- **`periodicCheckSchedulerProvider`**: 定时检查调度器

## 使用方法

### 在代码中使用 Providers

```dart
// 在 Widget 中使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navConfig = ref.watch(navigationConfigControllerProvider);
    final unreadMsg = ref.watch(unreadMessageControllerProvider);

    return Scaffold(
      // 使用状态
    );
  }
}
```

### 导航操作

```dart
// 更新导航索引
ref.read(navigationConfigControllerProvider.notifier).updateIndex(1);

// 更新使用底部导航
ref.read(navigationConfigControllerProvider.notifier).updateUseBottomNav(true);
```

### 检查未读消息

```dart
// 手动触发检查
ref.read(unreadMessageControllerProvider.notifier).fetchUnread();

// 清除未读
ref.read(unreadMessageControllerProvider.notifier).clear();
```

## 迁移状态

本特性已完成从 GetX 到 Riverpod + 干净架构的迁移。

### 已完成

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、仓库实现）
- ✅ Presentation 层（Providers、ShellPage）
- ✅ 定时检查调度器
- ✅ 代码优化（移除不必要的 async/await）

### 待完成

- ⏳ 迁移其他依赖 `MainController` 的页面
- ⏳ 删除 `controller.dart` 中的 `MainController`
- ⏳ 删除 `network_manager.dart`

## 依赖规则

- **Domain Layer**: 不依赖任何外层，纯粹的业务逻辑
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑
