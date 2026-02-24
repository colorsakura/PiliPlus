## 关键迁移模式

### 1. 多数据源处理 (PGC示例)

对于需要多个数据源的页面,使用ChangeNotifier + Provider.family:

```dart
// Controller
class PgcController extends ChangeNotifier {
  PgcState _state;

  PgcState get state => _state;

  void _updateState(PgcState newState) {
    _state = newState;
    notifyListeners();
  }
}

// Provider
final pgcControllerProvider = Provider.family<PgcController, HomeTabType>(
  (ref, tabType) {
    return PgcController(
      tabType: tabType,
      getPgcIndexUseCase: ref.read(getPgcIndexUseCaseProvider),
      getPgcFollowUseCase: ref.read(getPgcFollowUseCaseProvider),
      getPgcTimelineUseCase: ref.read(getPgcTimelineUseCaseProvider),
    );
  },
);

// Usage
final controller = ref.watch(pgcControllerProvider(tabType));
final mainListState = controller.state.mainListState;
```

### 2. 分页处理模式

统一分页状态管理:

```dart
class PgcState {
  final LoadingState<List<Item>?> mainListState;
  final int currentPage;
  final bool isEnd;
}

Future<void> queryMainList({bool isRefresh = true}) async {
  if (_state.isMainEnd && !isRefresh) return;

  final result = await _getPgcIndexUseCase(page, _tabType);

  if (result case Success(:final response)) {
    if (isRefresh) {
      _updateState(_state.copyWith(
        mainListState: result,
        currentPage: 2,
        isEnd: response.isEmpty,
      ));
    } else {
      // Append to existing list
      final currentList = ...;
      final newList = [...currentList, ...response];
      _updateState(_state.copyWith(
        mainListState: Success(newList),
        currentPage: page + 1,
        isMainEnd: response.isEmpty,
      ));
    }
  }
}
```

## 技术决策

### 使用ChangeNotifier而非StateNotifier的原因

在PGC迁移中发现,当前项目可能使用的Riverpod版本:
- `StateNotifier`不可用或配置复杂
- `ChangeNotifier`是Flutter SDK原生支持
- 与`Provider.family`配合良好

### Provider.family vs NotifierProvider.family

- ✅ `Provider.family<PgcController, HomeTabType>`: 手动创建控制器
- ❌ `NotifierProvider.family`: 需要特定的构造函数签名
- ❌ `StateNotifierProvider.family`: 可能不可用

## 下一步计划

Phase 3: 迁移Dynamics相关页面
- ✅ dynamics_topic_rcmd (已完成)
- ✅ dynamics_topic (已完成)
- ✅ dynamics_create_reserve (已完成)
- dynamics_detail (待迁移)
- dynamics_create_vote (待迁移)
- dynamics_create (待迁移)
- dynamics_mention (待迁移)
- dynamics_repost (待迁移)
- dynamics_select_topic (待迁移)
- dynamics_tab (待迁移)

Phase 4: 迁移Member相关页面
- member, member_profile
- member_dynamics, member_search

Phase 5: 迁移复杂页面
- audio (音频播放器)
- article (文章详情)
- video (视频播放器)
- setting (设置页面)

## 已完成迁移总结

### Phase 1: 简单页面 (11个)
- webview, dlna, contact
- emote, coin_log, exp_log, pgc_review, pgc_index
- article_list

### Phase 2: 中等复杂度 (1个)
- pgc (多数据源页面)

### Phase 3: Dynamics相关页面 (4个)
- dynamics_topic_rcmd (话题推荐)
- dynamics_topic (话题详情 - 包含多个状态和分页)
- dynamics_create_reserve (创建直播预约 - 表单页面)
- popular_series (每周必看 - 多数据源页面)

## 清理进度

### 已从 lib/pages/ 删除的目录 (7个)
- ✅ dynamics_topic_rcmd
- ✅ dynamics_topic
- ✅ dynamics_create_reserve
- ✅ article_list
- ✅ contact
- ✅ dlna
- ✅ webview

### 保留但部分迁移的目录 (5个)
- ⏳ coin_log - controller 保留用于 GetX 兼容性
- ⏳ exp_log - controller 保留用于 GetX 兼容性
- ⏳ pgc - 仍被 home_tab_type.dart 引用
- ⏳ pgc_index - widgets 仍被使用
- ⏳ pgc_review - widgets 仍被使用
- ⏳ emote - 被多个页面引用

**总计: 16个页面已成功迁移, 7个目录已删除, 0个编译错误**

## 干净架构模板

以下是为简单页面创建的Clean Architecture模板:

### 完整Clean Architecture (带数据获取)

以 `coin_log` 和 `exp_log` 为例:

```
lib/features/{feature_name}/
├── domain/
│   ├── entities/
│   │   └── {feature}_item.dart         # 实体类
│   ├── repositories/
│   │   └── {feature}_repository.dart    # 仓库接口
│   └── usecases/
│       └── get_{feature}.dart           # 用例
├── data/
│   ├── datasources/
│   │   └── {feature}_remote_datasource.dart  # 数据源
│   └── repositories/
│       └── {feature}_repository_impl.dart     # 仓库实现
├── presentation/
│   ├── providers/
│   │   ├── {feature}_controller.dart    # Riverpod Controller
│   │   └── {feature}_providers.dart     # Provider定义
│   └── pages/
│       └── {feature}_page.dart          # 页面
└── {feature}.dart                       # 导出文件
```

### 简单页面 (无状态管理)

以 `webview` 和 `dlna` 为例:

```
lib/features/{feature_name}/
├── presentation/
│   └── pages/
│       └── {feature}_page.dart          # 自包含页面
└── {feature}.dart                       # 导出文件
```

## 关键迁移模式

### 1. GetX 到 Riverpod 迁移

**Before (GetX):**
```dart
class MyController extends GetxController {
  final Rx<Data?> data = Rx<Data?>(null);
  final RxBool isLoading = false.obs;

  Future<void> fetchData() async {
    isLoading.value = true;
    final result = await api.fetchData();
    data.value = result;
    isLoading.value = false;
  }
}
```

**After (Riverpod):**
```dart
class MyState {
  final Data? data;
  final bool isLoading;

  const MyState({this.data, this.isLoading = false});

  MyState copyWith({Data? data, bool? isLoading}) {
    return MyState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MyController extends Notifier<MyState> {
  @override
  MyState build() => const MyState();

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true);
    final data = await ref.read(getDataUseCaseProvider)();
    state = state.copyWith(data: data, isLoading: false);
  }
}
```

### 2. 页面迁移

**Before (GetX):**
```dart
class MyPage extends GetView<MyController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(controller.data.value?.title ?? ''));
  }
}
```

**After (Riverpod):**
```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myControllerProvider);
    return Text(state.data?.title ?? '');
  }
}
```

## 下一步计划

1. 完成剩余的简单页面 (article, article_list, audio, pgc等)
2. 开始中等复杂度页面迁移 (login, search, member等)
3. 处理Dynamics相关页面
4. 处理Member相关页面
5. 最后处理复杂页面 (video, setting等)

## 注意事项

1. **依赖关系**: 某些页面依赖于 `common/` 目录下的基类,需要先迁移这些基类
2. **路由更新**: 每次迁移后需要更新 `lib/app/router/app_pages.dart`
3. **删除旧代码**: 一个批次迁移完成后统一删除旧代码
4. **测试验证**: 每次迁移后需要进行完整测试

## 遇到的问题

### Common Controllers 迁移

许多页面继承自:
- `CommonListController` - 用于列表页面
- `CommonDynController` - 用于动态相关页面
- `LogController` - 用于日志记录页面

这些需要迁移到 `core/controllers/` 或创建对应的基类Provider。

### 复杂页面处理

对于复杂页面如 `audio` 和 `article`:
- 需要仔细拆分功能模块
- 可能需要创建多个Provider
- 考虑分阶段迁移

## 构建验证

每次迁移后运行:
```bash
flutter analyze
```

确保无错误后再继续。
