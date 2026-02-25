# PiliPlus GetX → 干净架构(Riverpod) 迁移进度

**每次迁移都需要保证能够编译成功，每次迁移完成都在最后面输出【冰狗】**

**检查编译成功标准**：
不要只分析修改的文件
运行 `flutter analyze` 无错误
运行 `timeout 30 flutter run -d linux` 无错误

## 📊 总体进度

- **已完成:** 98+ 功能模块完全迁移
- **编译状态:** ✅ **0 编译错误** (项目完全可编译！)
- **剩余 GetxControllers:** 10 个 (5 个在 lib/features，5 个在 lib/pages)
- **兼容层:** 1 个 (search_result - GetX wrapper for Riverpod)
- **已标记 deprecated:** MainController, HomeController (已有 V2 版本)
- **本次会话提交:** **1 个** (msg_feed 迁移)

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
    ));
  }
}
```

### 3. 清晰架构结构

```
lib/features/{feature}/
├── domain/           # 领域层
│   ├── entities/     # 实体
│   └── usecases/     # 用例
├── data/             # 数据层
│   ├── datasources/  # 数据源
│   ├── models/       # 数据模型
│   └── repositories/ # 仓储实现
├── presentation/     # 表现层
│   ├── controllers/  # Riverpod Controllers
│   ├── notifiers/    # Riverpod Notifiers
│   ├── providers/    # Riverpod Providers
│   ├── pages/        # 页面
│   └── widgets/      # 组件
└── {feature}.dart    # 导出文件
```

## 🔄 最近会话迁移 (2025-02-25)

### 本次会话已完成迁移 (1个功能模块)

1. ✅ **msg_feed** - 迁移所有消息通知页面到 Riverpod (msg_at_me, msg_reply_me, msg_like_me, msg_sys_msg)

**技术要点:**
- 所有 4 个消息通知页面迁移到 `lib/features/msg_feed/`
- 使用 ChangeNotifier + Provider 模式替代 GetX
- 移除对 GetX mixins 的依赖
- 路由更新为使用 V2 页面

**新增功能模块:**
- `lib/features/msg_feed/` - 消息通知中心
  - msg_at_me_controller.dart - @我通知
  - msg_reply_me_controller.dart - 回复通知
  - msg_like_me_controller.dart - 收到的赞
  - msg_sys_msg_controller.dart - 系统消息

**编译状态:** ✅ **0 编译错误**

---

### 前一会话已完成迁移 (9个功能模块)

1. ✅ **color_select** - 迁移 _ColorSelectController 到 Riverpod Provider

1. ✅ **color_select** - 迁移 _ColorSelectController 到 Riverpod Provider
2. ✅ **home_zone** - 创建 RankPageV2 和 ZonePageV2 (Riverpod版本)
3. ✅ **history** - 创建 HistoryPageV2 和 HistoryMultiSelectControllerV2
4. ✅ **member_contribute** - 创建 MemberContributeTabControllerV2
5. ✅ **download** - 创建 DownloadMultiSelectControllerV2 和 DownloadPageDataControllerV2
6. ✅ **common_controllers** - 创建 SimpleTabControllerV2 和 DebounceControllerV2 (通用工具类)
7. ✅ **member_search** - 创建 MemberSearchControllerV2 和 MemberSearchChildControllerV2
8. ✅ **live_search** - 创建 LiveSearchControllerV2 和 LiveSearchChildControllerV2
9. ✅ **reply_search** - 创建 ReplySearchControllerV2 和 ReplySearchChildControllerV2

**技术要点:**
- 所有 V2 控制器继承 `ChangeNotifier`
- 使用 `Provider.family` 支持多实例
- 使用 `ListenableBuilder` 或 `ref.watch` 替代 `Obx`
- 移除对 GetX mixins 的依赖
- 创建可复用的通用控制器工具类

**新增通用工具类:**
- `lib/core/controllers/simple_tab_controller.dart` - 简单的 Tab 管理器
- `lib/core/controllers/debounce_controller.dart` - 防抖输入控制器
- `lib/core/controllers/tab_providers.dart` - Tab providers
- `lib/core/controllers/debounce_provider.dart` - Debounce providers

**新增搜索功能模块:**
- `lib/features/member_search/presentation/controllers/member_search_controller_v2.dart`
- `lib/features/member_search/presentation/providers/member_search_providers.dart`
- `lib/features/member_search/presentation/pages/member_search_page_v2.dart`
- `lib/features/member_search/presentation/widgets/member_search_child_page_v2.dart`
- `lib/features/live_search/presentation/controllers/live_search_controller_v2.dart`
- `lib/features/live_search/presentation/providers/live_search_providers.dart`
- `lib/features/live_search/presentation/pages/live_search_page_v2.dart`
- `lib/features/live_search/presentation/widgets/live_search_child_page_v2.dart`

**编译状态:** ✅ **0 编译错误**

---

## 🎯 剩余控制器 (14个)

### 按优先级分类

**高优先级 (核心功能):**
- MainController (shell) - 导航核心
- HomeController (home) - 主页核心
- search相关 (2个控制器) - 搜索功能

**中优先级 (常用功能):**
- DynamicsController - 动态
- LoginPageController - 登录

**低优先级 (辅助功能/复杂依赖):**
- AudioController - 音频播放
- VideoDetailController - 视频详情
- LiveRoomController - 直播间
- CommonIntroController - 通用介绍基类

**lib/features (7个):**
1. MainController (shell)
2. HomeController (home)
3. RankController (home_zone) - 有 V2 版本
4. HistoryMultiSelectController (history) - 有 V2 版本
5. DynamicsController (dynamics)
6. MemberContributeCtr (member_contribute) - 有 V2 版本
7. DownloadPageController (download) - 有 V2 版本
8. BaseSearchController (search)
9. SSearchController (search)
10. LoginPageController (login)
11. AudioController (audio)

**lib/pages (5个):**
1. CommonController - 通用控制器基类 (已重导出到 core/controllers)
2. CommonIntroController - 通用介绍控制器基类 (保留)
3. SearchResultController - **兼容层**
4. VideoDetailController
5. LiveRoomController

**已从 pages 迁移到 features:**
- msg_feed/* - 所有消息通知页面 ✅ 新迁移
- msg_at_me/* - @我通知 (已在 msg_feed 中)
- msg_reply_me/* - 回复通知 (已在 msg_feed 中)
- msg_like_me/* - 收到的赞 (已在 msg_feed 中)
- msg_sys_msg/* - 系统消息 (已在 msg_feed 中)

---

## 📋 下一步计划

### 策略: 逐个迁移 V2 版本

优先选择已创建 V2 控制器的功能进行路由切换，然后继续创建剩余控制器的 V2 版本。

1. **路由切换** (有 V2 版本):
   - color_select - 已完成 ✅
   - home_zone - 已创建 V2 ✅
   - history - 已创建 V2 ✅
   - member_contribute - 已创建 V2 ✅
   - download - 已创建 V2 ✅
   - member_search - 已创建 V2 ✅
   - live_search - 已创建 V2 ✅
   - reply_search - 已创建 V2 ✅
   - **msg_feed** - 本次会话完成 ✅

2. **创建 V2 控制器** (按复杂度):
   - 中等: DynamicsController
   - 复杂: LoginPageController, AudioController

---

## ⚠️ 已知问题

### search_panel 与 search_result 依赖问题

`search_panel` 控制器访问 `SearchResultController.count` 和 `.toTopIndex`，
但新的 Riverpod `Notifier` 不支持这种直接属性访问。

**当前解决方案:**
已创建 GetX 兼容层 (`lib/pages/search_result/controller.dart`)，暂时保留 GetX 版本的 SearchResultController。

---

## 🔗 有用的资源

- Riverpod 文档: https://riverpod.dev
- Flutter 状态管理最佳实践
- 项目内部参考实现: `lib/features/fav/` (完整的多状态+多选功能)

---

*最后更新: 2025-02-25 (续16)*
*维护者: Claude Sonnet 4.6*

## 📝 会话记录

### 续16 - lib/pages/msg_feed_top 迁移
- 创建 lib/features/msg_feed 模块
- 迁移 4 个消息通知页面 (at_me, reply_me, like_me, sys_msg)
- 更新路由配置使用 V2 页面
- 提交数: 1

### 续15 - 编译错误修复 + 新搜索模块迁移
- 修复 V2 控制器编译错误（9个文件）
- 新增 member_search, live_search, reply_search V2 版本
- 提交数: 14

### 剩余复杂控制器分析

**高复杂度 (>500行):**
- AudioController (~800行) - 音频播放，依赖 Player, 多个 mixins
- DynamicsController - 动态列表，关联多个子控制器
- VideoDetailController - 视频详情，最复杂的控制器之一
- LoginPageController - 登录流程，多种登录方式

**建议策略:**
1. 优先迁移简单/中等复杂度的控制器
2. 对复杂控制器考虑保留 GetX 版本作为兼容层
3. 逐步迁移页面级别的路由到 V2 版本
4. 最后处理核心复杂控制器
