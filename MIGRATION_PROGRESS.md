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

### Phase 3: Dynamics相关页面 - 基础设施已就绪

✅ **公共基础设施迁移完成 (2024-02-24):**
- `lib/pages/common/` → `lib/core/controllers/` (4个控制器)
- `lib/pages/common/publish/` → `lib/common/widgets/publish/` (2个发布页面)
- `lib/pages/search/` → `lib/utils/mixins/` (DebounceStreamState)

**已迁移的Dynamics页面 (7个):**
1. ✅ dynamics_topic_rcmd (话题推荐)
2. ✅ dynamics_topic (话题详情 - 多状态+分页)
3. ✅ dynamics_create_reserve (创建直播预约)
4. ✅ popular_series (每周必看 - 多数据源)
5. ✅ dynamics_mention (提及用户 - DebounceStreamState + 多选)
6. ✅ dynamics_select_topic (话题选择 - DebounceStreamState + 分页)
7. ✅ dynamics_create_vote (创建投票 - 表单页面，支持文字/图片投票)

**复杂页面 - 部分迁移 (2个):**
- `dynamics_detail` - Clean Architecture层已创建，页面仍使用GetX + CommonDynController
- `dynamics_tab` - Clean Architecture层已创建，页面仍使用GetX + CommonListController

**Riverpod 3.x兼容性更新 (2024-02-24):**
- 将 `ChangeNotifierProvider` 更新为 `Provider<T>` (Riverpod 3.x已移除ChangeNotifierProvider)
- 修复 vote_remote_datasource 的.when()用法
- 修复 vote_form_state 的const构造函数问题

**编译错误修复 (2024-02-24):**
- 修复所有14个编译错误 (0 errors)
- dynamics_mention: 使用 Consumer 包装 build 方法提供 ref 访问
- dynamics_select_topic: 使用 Consumer 包装 build 方法提供 ref 访问
- dynamics_create_vote: 修复 voteId getter 访问
- topic_search_controller: 修复 Success 模式匹配和错误类型转换

**总计: 19个页面已成功迁移, 0个编译错误**

**已使用迁移的基础设施的页面 (2个):**
- `dynamics_repost` - 使用 CommonRichTextPubPage ✅ (lib/common/widgets/publish/)
- `dynamics_create` - 使用 CommonRichTextPubPage ✅ (lib/common/widgets/publish/)

这两个页面通过导入迁移后的公共组件，已经使用了新的基础设施。
- 其他 dynamics 相关页面

### Phase 4: Member相关页面

用户相关页面大多数依赖 member controller 和公共基础设施。

### Phase 5: 复杂页面

- `audio` - 音频播放器，依赖 TripleMixin, FavMixin, BlockConfigMixin
- `video` - 视频播放器，最复杂的页面
- `article` - 文章详情，依赖 HTML 渲染
- `setting` - 设置页面，包含大量子页面

## 已完成迁移总结

### Phase 1: 简单页面 (11个)
- webview, dlna, contact
- emote, coin_log, exp_log, pgc_review, pgc_index
- article_list

### Phase 2: 中等复杂度 (1个)
- pgc (多数据源页面)

### Phase 3: Dynamics相关页面 (7个)

**Commit:** `28cbdb962` (2024-02-24)

#### Common Infrastructure Migration
迁移了公共控制器和发布组件到核心位置:
- **lib/core/controllers/**
  - `common_controller.dart` - 滚动/刷新基础控制器
  - `common_list_controller.dart` - 分页支持
  - `reply_controller.dart` - 评论/回复功能 (90+ 行，包含排序、置顶、反诈骗等)
  - `common_dyn_controller.dart` - 动态评论支持
- **lib/common/widgets/publish/**
  - `common_publish_page.dart` - 发布页面基类，处理键盘/面板管理
  - `common_rich_text_pub_page.dart` - 富文本编辑器，支持图片上传、@提及、表情
- **lib/utils/mixins/**
  - `debounce_stream_mixin.dart` - 防抖流处理混入类

#### Dynamics Pages
- dynamics_topic (话题详情 - 包含多个状态和分页)
- dynamics_create_reserve (创建直播预约 - 表单页面)
- popular_series (每周必看 - 多数据源页面)
- dynamics_mention (提及用户 - 使用 DebounceStreamState)
- dynamics_select_topic (话题选择 - 使用 DebounceStreamState + 分页)
- dynamics_create_vote (创建投票 - 表单页面，支持文字/图片投票)

**总计: 19个页面已成功迁移, 7个目录已删除, 0个编译错误**

## Git 提交历史

### Commit 1: Initial migration (16 pages)
- **Commit:** `f3fc26ef8` - refactor: migrate dynamics feature to clean architecture
- Migrated dynamics feature base pages

### Commit 2: First batch (16 pages total)
- **Commit:** `aeea8d43f` - refactor: migrate 16 pages to clean architecture with Riverpod
- Dynamics: dynamics_topic_rcmd, dynamics_topic, dynamics_create_reserve
- Popular: popular_series
- Simple pages: article_list, coin_log, emote, exp_log, pgc_index, pgc_review
- UI pages: contact, dlna, share, webview

### Commit 3: Common infrastructure + 3 Dynamics pages (2024-02-24)
- **Commit:** `28cbdb962` - refactor: migrate 3 more Dynamics pages and common infrastructure
- **Common Infrastructure:**
  - lib/core/controllers/ (CommonController, CommonListController, ReplyController, CommonDynController)
  - lib/common/widgets/publish/ (CommonPublishPage, CommonRichTextPubPage)
  - lib/utils/mixins/ (DebounceStreamState)
- **Dynamics Pages:**
  - dynamics_mention (用户提及面板)
  - dynamics_select_topic (话题选择)
  - dynamics_create_vote (创建投票)

## 清理进度

### 已从 lib/pages/ 删除的目录 (7个)
- ✅ dynamics_topic_rcmd
- ✅ dynamics_topic
- ✅ dynamics_create_reserve
- ✅ article_list
- ✅ contact
- ✅ dlna
- ✅ webview

### 保留但部分迁移的目录 (8个)
- ⏳ coin_log - controller 保留用于 GetX 兼容性
- ⏳ exp_log - controller 保留用于 GetX 兼容性
- ⏳ dynamics_mention - 完整迁移，旧文件重新导出新实现
- ⏳ dynamics_select_topic - 完整迁移，旧文件重新导出新实现
- ⏳ dynamics_create_vote - 完整迁移，旧文件重新导出新实现
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
