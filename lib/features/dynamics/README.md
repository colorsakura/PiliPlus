# Dynamics Feature

动态功能模块，采用干净架构（Clean Architecture）设计。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: DynamicsPage, DynamicsDetailPage      │
│  - Widgets: DynamicItemWidget, UpPanelWidget    │
│  - Providers: Riverpod 状态管理                 │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: DynamicItemEntity, FollowUpEntity  │
│  - Repositories: DynamicsRepository 接口        │
│  - Use Cases: FetchDynamicsUseCase, etc.        │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - DataSources: DynamicsRemoteDataSource        │
│  - RepositoryImpls: 仓库实现                    │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
lib/features/dynamics/
├── domain/                  # 领域层（核心业务逻辑）
│   ├── entities/           # 实体类
│   │   ├── dynamic_item.dart
│   │   ├── dynamics_tab.dart
│   │   ├── dynamics_data.dart
│   │   └── follow_up.dart
│   ├── repositories/       # 仓库接口
│   │   ├── dynamics_repository.dart
│   │   └── dynamics_tab_repository.dart
│   └── usecases/          # 用例
│       ├── fetch_dynamics.dart
│       ├── fetch_follow_up.dart
│       └── get_dynamics_tab_config.dart
├── data/                   # 数据层（数据获取和持久化）
│   ├── datasources/       # 数据源
│   │   ├── dynamics_remote_datasource.dart
│   │   └── dynamics_local_datasource.dart
│   └── repositories/      # 仓库实现
│       ├── dynamics_repository_impl.dart
│       └── dynamics_tab_repository_impl.dart
├── presentation/          # 表现层（UI 和状态管理）
│   ├── providers/         # Riverpod providers
│   │   ├── dynamics_providers.dart
│   │   ├── dynamics_tab_controller.dart
│   │   ├── dynamics_list_controller.dart
│   │   └── follow_up_controller.dart
│   ├── pages/            # 页面
│   │   ├── dynamics_page.dart
│   │   ├── dynamics_detail_page.dart
│   │   ├── dynamics_topic_page.dart
│   │   └── ...
│   └── widgets/          # 组件
│       ├── dynamic_item_widget.dart
│       ├── up_panel_widget.dart
│       └── ...
└── README.md             # 本文件
```

## 核心功能

### 1. 动态列表

- **标签实体**: `DynamicsTabType` 管理动态标签类型
- **动态数据**: `DynamicsDataEntity` 表示动态列表响应
- **动态项**: `DynamicItemEntity` 表示单个动态
- **列表控制器**: `DynamicsListController` 管理动态列表状态

### 2. 关注UP列表

- **关注实体**: `FollowUpEntity` 表示关注的UP用户
- **UP项**: `UpItemEntity` 表示单个UP用户
- **关注控制器**: `FollowUpController` 管理关注UP状态

### 3. 标签配置

- **标签配置**: `DynamicsTabConfig` 管理标签配置
- **配置用例**: `GetDynamicsTabConfigUseCase` 封装配置逻辑

## 使用方法

### 在代码中使用 Providers

```dart
// 在 Widget 中使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabConfig = ref.watch(dynamicsTabControllerProvider);
    final followUpState = ref.watch(followUpControllerProvider);

    return Scaffold(
      // 使用状态
    );
  }
}
```

### 获取动态列表

```dart
// 获取特定标签的动态列表
final dynamicsList = ref.watch(
  dynamicsListControllerProvider(DynamicsTabType.all),
);

// 刷新列表
ref.read(dynamicsListControllerProvider(DynamicsTabType.all).notifier)
    .refresh();

// 加载更多
ref.read(dynamicsListControllerProvider(DynamicsTabType.all).notifier)
    .loadMore();
```

### 获取关注UP列表

```dart
// 获取关注UP列表
final followUp = ref.watch(followUpControllerProvider);

// 刷新
ref.read(followUpControllerProvider.notifier).refresh();

// 加载更多
ref.read(followUpControllerProvider.notifier).loadMore();
```

## 迁移状态

本特性正在进行从 GetX 到 Riverpod + 干净架构的迁移。

### 已完成 ✅

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、仓库实现）
- ✅ Presentation 层（Providers）

### 进行中 🚧

- 🚧 Pages 迁移
- 🚧 Widgets 迁移

### 待完成 ⏳

- ⏳ DynamicsPage 主页面
- ⏳ DynamicsDetailPage 详情页面
- ⏳ DynamicsTopicPage 话题页面
- ⏳ 相关 Widgets
- ⏳ 路由更新
- ⏳ 删除旧文件

## 依赖规则

- **Domain Layer**: 不依赖任何外层，纯粹的业务逻辑
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 相关文件

- 原始控制器: `lib/pages/dynamics/controller.dart`
- 原始页面: `lib/pages/dynamics/view.dart`
- HTTP API: `lib/http/dynamics.dart`
- 模型: `lib/models/dynamics/`
