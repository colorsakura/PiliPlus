# 移除 grid.dart 组件设计文档

**日期:** 2026-03-01
**状态:** 已批准
**作者:** Claude

## 📋 概述

移除 `lib/utils/grid.dart` 中的自定义网格组件，使用 Flutter SDK 原生的 `SliverGridDelegateWithMaxCrossAxisExtent` 替换，简化代码依赖。

## 🎯 目标

1. 移除自定义 `SliverGridDelegateWithExtentAndRatio` 实现
2. 移除 `SliverGridDelegateWithMaxCrossAxisExtent` 重复实现
3. 移除 `GridMixin`，内联骨架屏代码到各个页面
4. 减少 utils 层的职责，使用 Flutter SDK 原生能力

## 🏗️ 架构改动

### 移除的文件

```
lib/utils/grid.dart  # 完全删除
```

### 组件映射关系

| 旧组件 | 新组件 | 说明 |
|--------|--------|------|
| `SliverGridDelegateWithExtentAndRatio` | `SliverGridDelegateWithMaxCrossAxisExtent` | Flutter SDK 原生 |
| `SliverGridDelegateWithMaxCrossAxisExtent` | `SliverGridDelegateWithMaxCrossAxisExtent` | 完全重复，直接删除 |
| `GridMixin` | 内联代码 | 各页面自己实现骨架屏 |

## 💻 实现细节

### 1. Grid.videoCardHDelegate() 替换

**旧代码：**
```dart
Grid.videoCardHDelegate(context, minHeight: 90)
```

**新代码：**
```dart
SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: Pref.smallCardWidth * 2,
  mainAxisSpacing: 2,
  crossAxisSpacing: 0,
  childAspectRatio: StyleString.aspectRatio * 2.2,
)
```

### 2. GridMixin 移除

**旧代码：**
```dart
class _PageState extends State<Page> with GridMixin {
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        loading ? gridSkeleton : content,
      ],
    );
  }
}
```

**新代码：**
```dart
class _PageState extends State<Page> {
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 0,
    childAspectRatio: StyleString.aspectRatio * 2.2,
  );

  Widget get gridSkeleton => SliverGrid.builder(
    gridDelegate: gridDelegate,
    itemBuilder: (_, _) => const VideoCardHSkeleton(),
    itemCount: 10,
  );

  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        loading ? gridSkeleton : content,
      ],
    );
  }
}
```

### 3. 特殊情况处理

**minHeight: 110 的场景（2 个文件）：**
```dart
// lib/features/history_search/presentation/pages/history_search_page.dart
// lib/features/fav_search/presentation/pages/fav_search_page.dart
```
这两个文件使用了 `minHeight: 110`，改为使用统一的 `childAspectRatio`。

## 📊 影响范围

### 修改的文件（80+）

- `lib/features/home_rcmd/presentation/pages/rcmd_page.dart`
- `lib/features/video/presentation/pages/related/view.dart`
- `lib/features/search_panel/presentation/pages/*/view.dart` (5 个文件)
- `lib/features/follow_same/presentation/pages/follow_same_page_v2.dart`
- `lib/features/followed/presentation/pages/followed_page_v2.dart`
- `lib/features/member_home/presentation/pages/member_home_page.dart`
- `lib/features/subscription/*/presentation/pages/*_page_v2.dart` (2 个文件)
- `lib/features/music/presentation/pages/*.dart` (2 个文件)
- `lib/features/download/presentation/pages/*.dart` (4 个文件)
- `lib/features/member_*/presentation/pages/*.dart` (15+ 个文件)
- `lib/features/live_*/presentation/pages/*.dart` (10+ 个文件)
- `lib/features/fav/presentation/pages/*.dart` (5 个文件)
- `lib/features/fav/fav_*/presentation/pages/*.dart` (7 个文件)
- 以及其他约 30 个文件

### GridMixin 使用（~10 个文件）

- `lib/features/article_list/presentation/pages/article_list_page.dart`
- `lib/features/popular_series/presentation/pages/popular_series_page.dart`
- `lib/features/popular_precious/presentation/pages/popular_precious_page_v2.dart`
- `lib/features/search_panel/presentation/pages/video/view.dart`
- `lib/features/search_panel/presentation/pages/article/view.dart`
- `lib/features/fav_detail/presentation/pages/fav_detail_page.dart`
- `lib/features/subscription_detail/presentation/pages/subscription_detail_page_v2.dart`
- `lib/features/subscription/presentation/pages/subscription_page_v2.dart`
- `lib/features/music/presentation/pages/music_recommend_page.dart`
- `lib/features/video/presentation/pages/related/view.dart`

## ⚠️ 风险与缓解

| 风险 | 缓解措施 |
|------|---------|
| 移除 `minHeight` 可能导致小屏幕卡片过小 | 通过 `childAspectRatio` 确保合理的宽高比 |
| 80+ 文件迁移工作量大 | 使用批量查找替换 + 逐个文件验证 |
| `GridMixin` 移除后代码重复 | 接受一定的代码重复以换取架构简化 |
| 影响范围广，可能引入回归 | 运行 `flutter analyze` 验证编译 |

## 🔄 迁移策略

**全局迁移** - 一次性更改所有 80+ 个文件。

### 迁移步骤

1. 移除 `lib/utils/grid.dart` 文件
2. 批量替换 `import 'package:PiliPlus/utils/grid.dart';`
3. 批量替换 `Grid.videoCardHDelegate(context)` 调用
4. 处理 `GridMixin` 使用，内联骨架屏代码
5. 运行 `flutter analyze` 验证编译
6. 手动测试关键页面（首页、视频详情、搜索）

## ✅ 验收标准

1. ✅ `lib/utils/grid.dart` 已删除
2. ✅ 所有 80+ 个文件编译通过
3. ✅ `flutter analyze` 无错误
4. ✅ 首页、视频详情页、搜索页网格显示正常
5. ✅ 骨架屏显示正常

## 📚 相关文档

- Flutter SDK `SliverGridDelegateWithMaxCrossAxisExtent`: https://api.flutter.dev/flutter/widgets/SliverGridDelegateWithMaxCrossAxisExtent-class.html
