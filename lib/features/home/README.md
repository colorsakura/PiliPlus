# Home Feature

首页特性管理应用的主页面，包括标签切换、搜索建议、顶部栏隐藏等功能。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: HomePage                              │
│  - Widgets: HomeAppBar, UserAvatar, SearchBar   │
│  - Providers: Riverpod 状态管理                 │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: HomeTabConfig, SearchSuggestion    │
│  - Repositories: HomeTabRepository, etc.        │
│  - Use Cases: GetHomeTabConfigUseCase, etc.     │
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
lib/features/home/
├── domain/                  # 领域层（核心业务逻辑）
│   ├── entities/           # 实体类
│   │   ├── home_tab_config.dart
│   │   └── search_suggestion.dart
│   ├── repositories/       # 仓库接口
│   │   ├── home_tab_repository.dart
│   │   └── search_repository.dart
│   └── usecases/          # 用例
│       ├── get_home_tab_config.dart
│       └── fetch_search_suggestion.dart
├── data/                   # 数据层（数据获取和持久化）
│   ├── datasources/       # 数据源
│   │   ├── home_tab_local_datasource.dart
│   │   └── search_remote_datasource.dart
│   └── repositories/      # 仓库实现
│       ├── home_tab_repository_impl.dart
│       └── search_repository_impl.dart
├── presentation/          # 表现层（UI 和状态管理）
│   ├── providers/         # Riverpod providers
│   │   ├── home_providers.dart
│   │   ├── home_tab_controller.dart
│   │   └── search_controller.dart
│   ├── pages/            # 页面
│   │   └── home_page.dart
│   └── widgets/          # 组件
│       └── home_app_bar.dart
├── controller.dart        # 旧 HomeController（@deprecated）
├── view.dart             # 旧 HomePage（@deprecated）
└── README.md             # 本文件
```

## 核心功能

### 1. 标签配置

- **标签实体**: `HomeTabConfig` 管理首页标签状态
- **标签仓库**: `HomeTabRepository` 负责配置的读写
- **配置用例**: `GetHomeTabConfigUseCase` 封装配置业务逻辑

### 2. 搜索建议

- **搜索实体**: `SearchSuggestion` 表示默认搜索词
- **搜索仓库**: `SearchRepository` 负责获取搜索建议
- **获取用例**: `FetchSearchSuggestionUseCase` 封装搜索建议逻辑

### 3. 状态管理（Riverpod）

- **`homeTabConfigControllerProvider`**: 标签配置状态
- **`searchSuggestionControllerProvider`**: 搜索建议状态

## 使用方法

### 在代码中使用 Providers

```dart
// 在 Widget 中使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabConfig = ref.watch(homeTabConfigControllerProvider);
    final searchSuggestion = ref.watch(searchSuggestionControllerProvider);

    return Scaffold(
      // 使用状态
    );
  }
}
```

### 标签操作

```dart
// 更新选中索引
ref.read(homeTabConfigControllerProvider.notifier).updateIndex(1);

// 更新默认搜索词
ref.read(homeTabConfigControllerProvider.notifier).updateDefaultSearch('关键词');
```

### 获取搜索建议

```dart
// 手动触发获取
ref.read(searchSuggestionControllerProvider.notifier).fetchDefaultSearch();
```

## 迁移状态

本特性已完成从 GetX 到 Riverpod + 干净架构的迁移。

### 已完成 ✅

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、仓库实现）
- ✅ Presentation 层（Providers、HomePage、Widgets）
- ✅ 功能完整性验证
- ✅ 编译通过（无错误、无警告）

### 保留文件（向后兼容）

以下文件保留用于向后兼容，已标记为 `@Deprecated`：

- `controller.dart` - 旧的 `HomeController`（GetX）
- `view.dart` - 旧的 `HomePage`（GetX）

这些文件可以在确认所有功能正常后被删除。

## 依赖规则

- **Domain Layer**: 不依赖任何外层，纯粹的业务逻辑
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 与 Shell 特性的集成

HomePage 通过以下方式与 Shell 特性集成：

1. **导航配置**: 通过 `navigationConfigControllerProvider` 获取导航状态
2. **未读消息**: 通过 `unreadMessageControllerProvider` 获取消息状态
3. **顶部栏隐藏**: 根据 Shell 的导航配置控制顶部栏显示/隐藏

## 相关文件

- 导航配置: `lib/features/shell/domain/entities/navigation_config.dart`
- 导航 Provider: `lib/features/shell/presentation/providers/navigation_provider.dart`
