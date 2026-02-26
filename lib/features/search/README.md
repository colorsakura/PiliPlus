# Search Feature

搜索功能管理应用的搜索页面，提供搜索建议、热搜榜、搜索推荐和搜索历史等功能。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: SearchPage                            │
│  - Widgets: SearchBar, SuggestList              │
│  - Providers: Riverpod 状态管理                 │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: SearchSuggest, SearchResult        │
│  - Repositories: SearchRepository               │
│  - Use Cases: GetSearchSuggest, SearchByType    │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - DataSources: 搜索API远程数据源               │
│  - RepositoryImpls: 仓库实现                    │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
lib/features/search/
├── domain/                  # 领域层（核心业务逻辑）
│   ├── entities/           # 实体类
│   │   ├── search_suggest_entity.dart
│   │   ├── search_result_entity.dart
│   │   ├── search_trending_entity.dart
│   │   └── search_history_entity.dart
│   ├── repositories/       # 仓库接口
│   │   └── search_repository.dart
│   └── usecases/          # 用例
│       ├── get_search_suggest.dart
│       ├── search_by_type.dart
│       ├── get_search_trending.dart
│       ├── get_search_recommend.dart
│       └── manage_search_history.dart
├── data/                   # 数据层（数据获取和持久化）
│   ├── datasources/       # 数据源
│   │   └── search_remote_datasource.dart
│   └── repositories/      # 仓库实现
│       └── search_repository_impl.dart
├── presentation/          # 表现层（UI 和状态管理）
│   ├── providers/         # Riverpod providers
│   │   ├── search_providers.dart
│   │   ├── search_state.dart
│   │   └── search_controller.dart
│   ├── pages/            # 页面
│   │   ├── search_page.dart
│   │   ├── search_controller.dart (GetX @deprecated)
│   │   └── widget/
│   └── widgets/          # 组件
└── README.md             # 本文件
```

## 核心功能

### 1. 搜索建议

- **实体**: `SearchSuggestEntity` 管理搜索建议
- **用例**: `GetSearchSuggestUseCase` 获取搜索建议
- **防抖**: 使用200ms防抖优化输入体验
- **状态**: `SearchController.onTextChanged()`

### 2. 分类搜索

- **实体**: `SearchResultEntity` 搜索结果基类
- **子类型**: `SearchVideoEntity`, `SearchUserEntity`, `SearchLiveEntity`
- **用例**: `SearchByTypeUseCase` 执行分类搜索
- **支持类型**: video, bili_user, live_room, media_bangumi, article

### 3. 热搜榜

- **实体**: `SearchTrendingDataEntity` 热搜数据
- **用例**: `GetSearchTrendingUseCase` 获取热搜榜
- **包含**: 热搜列表 + 置顶列表

### 4. 搜索推荐

- **实体**: `SearchTrendingEntity` 推荐关键词
- **用例**: `GetSearchRecommendUseCase` 获取搜索推荐
- **开关**: 可通过设置开启/关闭

### 5. 搜索历史

- **实体**: `SearchHistoryEntity` 管理搜索历史
- **用例**: `ManageSearchHistoryUseCase` 管理历史记录
- **操作**: 添加、删除、清空历史
- **存储**: 使用GStorage持久化

### 6. UID识别

- **验证**: `SearchController.validateUid()`
- **显示**: 当输入纯数字时显示UID按钮

## 使用方法

### 在代码中使用 Providers

```dart
// 在 Widget 中使用
class SearchPageWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);
    final searchController = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          // 搜索建议
          if (searchState.suggestList.isNotEmpty)
            SuggestList(items: searchState.suggestList),

          // 热搜榜
          if (searchState.trendingData != null)
            TrendingList(data: searchState.trendingData!),

          // 搜索结果
          if (searchState.searchResults != null)
            SearchResultList(items: searchState.searchResults!),
        ],
      ),
    );
  }
}
```

### 处理搜索输入

```dart
// 监听搜索输入变化
searchController.onTextChanged(keyword);

// 验证UID
searchController.validateUid(keyword);
```

### 执行搜索

```dart
// 执行分类搜索
await searchController.search(
  searchType: SearchType.video,
  keyword: 'flutter',
  page: 1,
);
```

### 管理搜索历史

```dart
// 删除单条历史
searchController.removeHistory(keyword);

// 清空所有历史
searchController.clearHistory();
```

### 获取热搜和推荐

```dart
// 获取热搜榜
await searchController.queryTrendingList(limit: 10);

// 获取搜索推荐
await searchController.queryRecommendList();
```

## 迁移状态

本特性正在进行从 GetX 到 Riverpod + 干净架构的迁移。

### 已完成 ✅

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、仓库实现）
- ✅ Presentation 层（Providers、State、Controller）

### 待完成 🚧

- ⏳ 将现有页面迁移到新的Provider
- ⏳ 添加完整的测试用例

### 保留文件（向后兼容）

以下文件保留用于向后兼容，将在迁移完成后标记为 `@Deprecated`：

- `presentation/pages/search_controller.dart` - 旧的GetX控制器

这些文件可以在确认所有功能正常后被删除或整合。

## 依赖规则

- **Domain Layer**: 不依赖任何外层，纯粹的业务逻辑
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 错误处理

所有用例都定义了明确的错误处理：

```dart
try {
  await searchController.search(
    searchType: SearchType.video,
    keyword: 'flutter',
  );
} on ServerFailure catch (e) {
  // 处理服务器错误
  print('Server error: ${e.message}');
} on NetworkFailure catch (e) {
  // 处理网络错误
  print('Network error: ${e.message}');
}
```

## 相关文件

- 搜索模型: `lib/models/search/`
- 搜索HTTP: `lib/http/search.dart`
- 搜索API常量: `lib/core/constants/search_api_constants.dart`
- 搜索类型: `lib/models/common/search/search_type.dart`
