# PiliPlus GetX → Riverpod 迁移进度

**每次迁移都需要保证能够编译成功，每次迁移完成都在最后面输出【冰狗】**

## 📊 总体进度

- **已完成:** 47+ 功能模块完全迁移
- **编译状态:** ✅ 0 编译错误
- **删除目录:** 64 个 (从 80 个减少到 16 个)
- **删除文件:** 460+ 个
- **删除代码:** 34,650+ 行

## 🎯 核心迁移模式

### 1. ChangeNotifier + Provider.family 模式

```dart
// Controller
class FeatureController extends ChangeNotifier {
  FeatureState _state;

  FeatureState get state => _state;

  void _updateState(FeatureState newState) {
    _state = newState;
    notifyListeners();
  }
}

// Provider
final featureControllerProvider = Provider.family<FeatureController, int>(
  (ref, id) => FeatureController(id: id, useCase: ref.watch(useCaseProvider)),
);

// Usage
final controller = ref.watch(featureControllerProvider(widget.id));
```

### 2. 分页处理模式

```dart
class FeatureState {
  final LoadingState<List<Item>?> listState;
  final int currentPage;
  final bool isEnd;

  FeatureState copyWith({...}) => ...;
}

Future<void> queryData({bool isRefresh = true}) async {
  final result = await _useCase(page);

  if (result case Success(:final response)) {
    _updateState(_state.copyWith(
      listState: Success(response),
      currentPage: page + 1,
      isEnd: response.isEmpty,
    ));
  }
}
```

### 3. CommonListControllerV2 基类

```dart
class MemberArticleController extends BaseListController<Article> {
  @override
  Future<LoadingState<List<Article>>> fetchData(int page) async {
    return await ref.read(getArticlesUseCaseProvider)(page);
  }
}
```

## 📝 GetX → Riverpod 迁移对照

| GetX | Riverpod |
|------|----------|
| `GetxController` | `ChangeNotifier` 或 `Notifier<T>` |
| `Rx<T> value` | `T value` + `copyWith()` |
| `obs(() => ...)` | `ref.watch(provider)` |
| `Get.find<T>()` | `ref.read(provider)` |
| `Get.put(T())` | Provider 自动创建 |
| `Obx(() => ...)` | `ConsumerWidget` + `ref.watch` |
| `onInit()` | 构造函数或 `build()` 方法 |

## 🗂️ 目录结构

### Clean Architecture 模板

```
lib/features/{feature_name}/
├── domain/
│   ├── entities/       # 实体类
│   ├── repositories/   # 仓库接口
│   └── usecases/      # 用例
├── data/
│   ├── datasources/    # 数据源
│   └── repositories/    # 仓库实现
├── presentation/
│   ├── providers/      # Controller + Provider
│   ├── pages/          # 页面
│   └── widgets/        # 组件
└── {feature}.dart       # 导出文件
```

## 🔄 本次会话迁移 (2025-02-25 续)

### 迁移的控制器 (4个)

**简单控制器 (已完成):**
1. ✅ whisper - 清理旧目录，更新导入
2. ✅ member_pgc - 完整迁移，删除旧GetX版本
3. ✅ dynamics_repost - 清理旧目录，更新导入
4. ✅ dynamics_create - 清理旧目录，更新导入

**删除的目录:** 2 个
- whisper, member_pgc

**删除的文件:** 10 个
**删除的代码:** 600+ 行

### 待迁移控制器状态

**需要完整迁移 (仍在使用 GetX):**
- member - 复杂控制器，被多个子功能依赖
- whisper_secondary - 使用 GetX
- whisper_settings - 使用 GetX
- dynamics_detail - 使用 GetX

## 🎯 剩余控制器 (按引用数排序)

**复杂控制器 (>5 refs):**
- video: 25 refs ⚠️
- live_room: 9 refs
- search_panel: 7 refs
- follow_type: 6 refs
- mine: 5 refs
- fav_detail: 5 refs

**中等复杂度 (2-5 refs):**
- follow: 3 refs
- dynamics_tab: 3 refs
- dynamics: 3 refs
- subscription_detail: 2 refs
- subscription: 2 refs
- member_search: 2 refs
- login: 2 refs
- live_search: 2 refs
- download: 2 refs

**简单控制器 (1 ref):**
- search_result: 1 ref
- member: 1 ref
- dynamics_detail: 1 ref
- whisper_secondary: 1 ref (已部分迁移)

## 📋 已发现但无法删除的旧目录

以下功能已迁移到 Riverpod，但旧目录仍包含被引用的子文件：
- `lib/pages/whisper_secondary/` - 仍有 widgets 被引用
- `lib/pages/whisper_settings/` - 仍有 widgets 被引用
- `lib/pages/dynamics_detail/` - 控制器被使用
- `lib/pages/member/` - 控制器被使用

这些目录需要在页面完全迁移后才能删除。

## 📋 下一步计划

### 阶段1: 简单控制器
继续迁移 1-2 refs 的控制器：
- member
- dynamics_detail
- 解决 search_result 依赖问题

### 阶段2: 中等复杂度
迁移 2-3 refs 的控制器：
- subscription_detail
- subscription
- member_search
- login
- live_search
- download

### 阶段3: 复杂控制器
最后处理高引用数控制器：
- mine, fav_detail, follow
- dynamics_tab, dynamics
- follow_type
- search_panel (需先解决 search_result)
- live_room
- video (最复杂)

## ⚠️ 已知问题

### search_panel 与 search_result 依赖问题

`search_panel` 控制器访问 `SearchResultController.count` 和 `.toTopIndex`，
但新的 Riverpod `Notifier` 不支持这种直接属性访问。

**解决方案选项:**
1. 将 search_panel 控制器也迁移到 Riverpod
2. 创建适配器提供兼容接口
3. 暂时保留 GetX 版本的 search_result

## 🔗 有用的资源

- Riverpod 文档: https://riverpod.dev
- Flutter 状态管理最佳实践
- 项目内部参考实现: `lib/features/fav/` (完整的多状态+多选功能)

---

*最后更新: 2025-02-25*
*维护者: Claude Sonnet 4.6*
