# Clean Architecture 重构指南

本文档记录了将 GetX MVC 模式的页面重构为 Clean Architecture + Riverpod 的过程和模式。

## 重构完成情况

### ✅ 已完成

| 模块 | 路径 | 说明 |
|------|------|------|
| blacklist | `lib/features/blacklist/` | 黑名单管理页面 |

### 🚧 进行中

| 模块 | 路径 | 说明 |
|------|------|------|
| - | - | - |

### 📋 待重构

| 模块 | 原路径 | 优先级 |
|------|--------|--------|
| about | `lib/pages/about/` | 高 |
| fav | `lib/pages/fav/` | 高 |
| follow/fan | `lib/pages/follow/`, `lib/pages/fan/` | 高 |
| history | `lib/pages/history/` | 高 |
| later | `lib/pages/later/` | 高 |

## Clean Architecture 目录结构

```
lib/features/[feature_name]/
├── domain/                      # 领域层（核心业务逻辑）
│   ├── entities/               # 实体类
│   │   ├── [feature]_item.dart
│   │   └── [feature]_result.dart
│   ├── repositories/           # 仓库接口
│   │   └── [feature]_repository.dart
│   └── usecases/              # 用例
│       ├── fetch_[feature].dart
│       └── [action]_[feature].dart
├── data/                       # 数据层（数据获取）
│   ├── datasources/           # 数据源
│   │   └── [feature]_remote_datasource.dart
│   └── repositories/          # 仓库实现
│       └── [feature]_repository_impl.dart
└── presentation/              # 表现层（UI和状态）
    ├── providers/             # Riverpod providers
    │   ├── [feature]_providers.dart
    │   └── [feature]_controller.dart
    └── pages/                # 页面
        └── [feature]_page.dart
```

## 重构步骤

### 1. 创建目录结构

```bash
mkdir -p lib/features/[feature_name]/{domain/{entities,repositories,usecases},data/{datasources,repositories},presentation/{pages,providers}}
```

### 2. 领域层（Domain Layer）

#### 2.1 创建实体类（Entities）

实体类封装业务数据，独立于数据源和UI。

```dart
// lib/features/[feature]/domain/entities/[feature]_item.dart
class [Feature]ItemEntity {
  final int id;
  final String name;
  // ... 其他字段

  const [Feature]ItemEntity({
    required this.id,
    required this.name,
  });

  // 从模型创建实体
  factory [Feature]ItemEntity.fromModel([Feature]ItemModel model) {
    return [Feature]ItemEntity(
      id: model.id,
      name: model.name,
    );
  }

  // 转换为模型（如果需要）
  [Feature]ItemModel toModel() {
    return [Feature]ItemModel(
      id: id,
      name: name,
    );
  }
}
```

#### 2.2 创建结果实体（Result Entity）

```dart
// lib/features/[feature]/domain/entities/[feature]_result.dart
class [Feature]ResultEntity {
  final List<[Feature]ItemEntity> items;
  final int total;
  final bool hasMore;
  final int currentPage;

  const [Feature]ResultEntity({
    required this.items,
    required this.total,
    required this.hasMore,
    required this.currentPage,
  });
}
```

#### 2.3 创建仓库接口（Repository Interface）

```dart
// lib/features/[feature]/domain/repositories/[feature]_repository.dart
abstract interface class [Feature]Repository {
  Future<[Feature]ResultEntity> get[Feature]({
    required int pn,
    required int ps,
  });

  Future<bool> performAction({
    required int id,
  });
}
```

#### 2.4 创建用例（Use Cases）

```dart
// lib/features/[feature]/domain/usecases/fetch_[feature].dart
class Fetch[Feature]UseCase {
  final [Feature]Repository _repository;

  const Fetch[Feature]UseCase(this._repository);

  Future<[Feature]ResultEntity> call({
    required int pn,
    int ps = 20,
  }) {
    return _repository.get[Feature](pn: pn, ps: ps);
  }
}
```

### 3. 数据层（Data Layer）

#### 3.1 创建远程数据源（Remote Data Source）

```dart
// lib/features/[feature]/data/datasources/[feature]_remote_datasource.dart
class [Feature]RemoteDataSource {
  Future<LoadingState<[Feature]Data>> fetch[Feature]({
    required int pn,
    required int ps,
  }) {
    return http.[Feature]Http.get[Feature](pn: pn, ps: ps);
  }
}
```

#### 3.2 创建仓库实现（Repository Implementation）

```dart
// lib/features/[feature]/data/repositories/[feature]_repository_impl.dart
class [Feature]RepositoryImpl implements [Feature]Repository {
  final [Feature]RemoteDataSource _remoteDataSource;

  [Feature]RepositoryImpl({
    required [Feature]RemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<[Feature]ResultEntity> get[Feature]({
    required int pn,
    required int ps,
  }) async {
    final result = await _remoteDataSource.fetch[Feature](
      pn: pn,
      ps: ps,
    );

    return _map[Feature]Result(result, pn, ps);
  }

  [Feature]ResultEntity _map[Feature]Result(
    LoadingState<[Feature]Data> result,
    int pn,
    int ps,
  ) {
    if (result case Success(:final response)) {
      final items = response.list
              ?.map([Feature]ItemEntity.fromModel)
              .toList() ??
          [];

      final total = response.total ?? 0;
      final hasMore = items.length >= ps && items.length < total;

      return [Feature]ResultEntity(
        items: items,
        total: total,
        hasMore: hasMore,
        currentPage: pn,
      );
    } else if (result case Error(:final errMsg)) {
      throw Exception(errMsg);
    } else {
      throw Exception('加载中...');
    }
  }
}
```

### 4. 表现层（Presentation Layer）

#### 4.1 创建 Providers

```dart
// lib/features/[feature]/presentation/providers/[feature]_providers.dart
final [feature]RemoteDataSourceProvider =
    Provider<[Feature]RemoteDataSource>((ref) {
  return [Feature]RemoteDataSource();
});

final [feature]RepositoryProvider = Provider<[Feature]Repository>((ref) {
  final remoteDataSource = ref.watch([feature]RemoteDataSourceProvider);
  return [Feature]RepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

final fetch[Feature]UseCaseProvider = Provider<Fetch[Feature]UseCase>((ref) {
  final repository = ref.watch([feature]RepositoryProvider);
  return Fetch[Feature]UseCase(repository);
});
```

#### 4.2 创建 Controller

```dart
// lib/features/[feature]/presentation/providers/[feature]_controller.dart
class [Feature]State {
  final [Feature]ResultEntity? result;
  final bool isLoading;
  final String? errorMessage;

  const [Feature]State({
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  [Feature]State copyWith({
    [Feature]ResultEntity? result,
    bool? isLoading,
    String? errorMessage,
  }) {
    return [Feature]State(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class [Feature]Controller extends Notifier<[Feature]State> {
  late final Fetch[Feature]UseCase _fetchUseCase;

  int _currentPage = 1;
  bool _isEnd = false;

  @override
  [Feature]State build() {
    _fetchUseCase = ref.read(fetch[Feature]UseCaseProvider);
    return const [Feature]State(isLoading: true);
  }

  Future<void> initialize() => fetch[Feature](isRefresh: true);

  Future<void> fetch[Feature]({bool isRefresh = true}) async {
    if (state.isLoading && state.result != null) return;
    if (!isRefresh && _isEnd) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _fetchUseCase(
        pn: isRefresh ? 1 : _currentPage,
        ps: 20,
      );

      state = state.copyWith(result: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> onRefresh() => fetch[Feature](isRefresh: true);
  Future<void> onLoadMore() => fetch[Feature](isRefresh: false);
  Future<void> onReload() => fetch[Feature](isRefresh: true);
}

final [feature]ControllerProvider =
    NotifierProvider<[Feature]Controller, [Feature]State>(
  [Feature]Controller.new,
);
```

#### 4.3 创建页面（Page）

```dart
// lib/features/[feature]/presentation/pages/[feature]_page.dart
class [Feature]Page extends ConsumerStatefulWidget {
  const [Feature]Page({super.key});

  @override
  ConsumerState<[Feature]Page> createState() => _FeaturePageState();
}

class _[Feature]PageState extends ConsumerState<[Feature]Page> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read([feature]ControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch([feature]ControllerProvider);
    final controller = ref.read([feature]ControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('[Feature]')),
      body: _buildBody(state, controller),
    );
  }
}
```

### 5. 更新路由配置

在 `lib/app/router/app_pages.dart` 中：

```dart
// 更新导入
import 'package:PiliPlus/features/[feature]/presentation/pages/[feature]_page.dart';

// 更新路由
GetPage(name: '/[feature]', page: () => const [Feature]Page()),
```

## 代码检查

在完成重构后，运行静态分析：

```bash
flutter analyze lib/features/[feature]/
```

## 注意事项

### 依赖规则

- **Domain 层**：不依赖任何外层，只定义抽象接口
- **Data 层**：实现 Domain 层定义的接口，依赖具体的 HTTP API
- **Presentation 层**：通过 Use Case 与 Domain 层交互，不直接访问 Repository

### 状态管理

- 使用 `NotifierProvider` 管理状态
- 在 `build()` 方法中通过 `ref.watch()` 订阅状态变化
- 在回调函数中使用 `ref.read()` 调用方法
- 使用 `ref.invalidate()` 刷新 provider

### 错误处理

- 在 Repository 实现中将 API 错误转换为 Exception
- 在 Controller 中捕获异常并更新错误状态
- 在 UI 中根据 `errorMessage` 显示错误信息

### 测试建议

- Domain 层的用例可以使用 Mock Repository 进行单元测试
- Data 层的仓库实现可以使用 Mock Data Source 进行单元测试
- Presentation 层的 Controller 可以通过 Provider 测试框架进行测试

## 参考示例

完整的重构示例请参考：
- `lib/features/blacklist/` - 黑名单管理功能
- `lib/features/home_hot/` - 热门视频功能
