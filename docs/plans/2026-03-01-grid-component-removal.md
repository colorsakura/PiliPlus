# Grid Component Removal Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 移除 `lib/utils/grid.dart` 自定义网格组件，使用 Flutter SDK 原生的 `SliverGridDelegateWithMaxCrossAxisExtent` 替换，简化 80+ 个文件的依赖。

**Architecture:** 删除自定义网格实现，将 `GridMixin` 的骨架屏功能内联到各个页面，使用 Flutter SDK 原生网格代理。全局一次性迁移所有 80+ 个文件。

**Tech Stack:** Flutter 3.41.2, Dart 3.10+

---

## Task 1: 移除 grid.dart 文件

**Files:**
- Delete: `lib/utils/grid.dart`

**Step 1: 删除 grid.dart 文件**

```bash
rm lib/utils/grid.dart
```

**Step 2: 验证文件已删除**

```bash
ls lib/utils/grid.dart
```

Expected: "No such file or directory"

**Step 3: 提交删除**

```bash
git add lib/utils/grid.dart
git commit -m "refactor(grid): remove custom grid.dart component

This removes the custom grid implementation in preparation for migration
to Flutter SDK native components.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 2: 批量替换 import 语句 - Features 层

**Files:**
- Modify: 80+ feature files importing `grid.dart`

**Step 1: 使用批量替换移除 import**

```bash
# 移除所有 import 'package:PiliPlus/utils/grid.dart';
find lib/features -type f -name "*.dart" -exec sed -i "/import 'package:PiliPlus\/utils\/grid.dart';/d" {} \;
```

**Step 2: 验证没有残留的 grid.dart 导入**

```bash
grep -r "import.*grid\.dart" lib/features/
```

Expected: 无结果

**Step 3: 提交 import 移除**

```bash
git add lib/features/
git commit -m "refactor(grid): remove grid.dart imports from feature modules

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 3: 替换 Grid.videoCardHDelegate() 调用（无 GridMixin 文件）

**Files:**
- Modify: 约 70 个文件直接使用 `Grid.videoCardHDelegate(context)`

**Step 1: 批量替换默认的 videoCardHDelegate 调用**

```bash
# 替换 Grid.videoCardHDelegate(context) 为完整的 SliverGridDelegateWithMaxCrossAxisExtent
find lib/features -type f -name "*.dart" -exec sed -i 's/Grid\.videoCardHDelegate(context)/SliverGridDelegateWithMaxCrossAxisExtent(\n    maxCrossAxisExtent: Pref.smallCardWidth * 2,\n    mainAxisSpacing: 2,\n    crossAxisSpacing: 0,\n    childAspectRatio: StyleString.aspectRatio * 2.2,\n  )/g' {} \;
```

**Step 2: 验证替换结果（抽样检查）**

```bash
grep -n "SliverGridDelegateWithMaxCrossAxisExtent" lib/features/home_rcmd/presentation/pages/rcmd_page.dart
```

Expected: 看到替换后的代码

**Step 3: 提交批量替换**

```bash
git add lib/features/
git commit -m "refactor(grid): replace Grid.videoCardHDelegate with SliverGridDelegateWithMaxCrossAxisExtent

Replace default grid delegate calls with Flutter SDK native component.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 4: 替换带 minHeight: 110 的特殊调用

**Files:**
- Modify:
  - `lib/features/history_search/presentation/pages/history_search_page.dart`
  - `lib/features/fav_search/presentation/pages/fav_search_page.dart`

**Step 1: 修改 history_search_page.dart**

在 `lib/features/history_search/presentation/pages/history_search_page.dart` 中：

```dart
// 旧代码（约第 31 行）
late final gridDelegate = Grid.videoCardHDelegate(context, minHeight: 110);

// 新代码
late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: Pref.smallCardWidth * 2,
  mainAxisSpacing: 2,
  crossAxisSpacing: 0,
  childAspectRatio: StyleString.aspectRatio * 2.2,
);
```

**Step 2: 修改 fav_search_page.dart**

在 `lib/features/fav_search/presentation/pages/fav_search_page.dart` 中：

```dart
// 旧代码（约第 91 行）
late final gridDelegate = Grid.videoCardHDelegate(context, minHeight: 110);

// 新代码
late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: Pref.smallCardWidth * 2,
  mainAxisSpacing: 2,
  crossAxisSpacing: 0,
  childAspectRatio: StyleString.aspectRatio * 2.2,
);
```

**Step 3: 验证修改**

```bash
grep -n "minHeight" lib/features/history_search/presentation/pages/history_search_page.dart lib/features/fav_search/presentation/pages/fav_search_page.dart
```

Expected: 无结果（minHeight 已移除）

**Step 4: 提交特殊调用替换**

```bash
git add lib/features/history_search/ lib/features/fav_search/
git commit -m "refactor(grid): replace grid delegates with minHeight: 110

Unify to use standard childAspectRatio instead of minHeight.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 5: 移除 GridMixin 并内联实现（批量）

**Files:**
- Modify: ~10 个使用 `GridMixin` 的文件

**Step 1: 为每个使用 GridMixin 的文件添加内联实现**

对于以下文件，按照模板进行修改：

```dart
// 在每个使用 GridMixin 的类中添加：
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
```

并移除 `with GridMixin`。

**Step 2: 批量移除 GridMixin**

```bash
# 移除 "with GridMixin"
find lib/features -type f -name "*.dart" -exec sed -i 's/ with GridMixin//' {} \;
```

**Step 3: 验证没有残留的 GridMixin**

```bash
grep -rn "GridMixin" lib/features/
```

Expected: 无结果

**Step 4: 提交 GridMixin 移除**

```bash
git add lib/features/
git commit -m "refactor(grid): remove GridMixin and inline skeleton screen code

Move grid skeleton implementation inline to each page to eliminate
the mixin dependency on the removed grid.dart file.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 6: 处理 utils/waterfall.dart 中的依赖

**Files:**
- Modify: `lib/utils/waterfall.dart`

**Step 1: 检查 waterfall.dart 如何使用 grid.dart**

```bash
grep -n "grid" lib/utils/waterfall.dart
```

**Step 2: 根据 waterfall.dart 的实际使用情况进行修改**

查看导入的内容并移除相关代码或内联实现。

**Step 3: 验证编译**

```bash
flutter analyze lib/utils/waterfall.dart
```

**Step 4: 提交 waterfall.dart 修改**

```bash
git add lib/utils/waterfall.dart
git commit -m "refactor(grid): update waterfall.dart to remove grid.dart dependency

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 7: 运行静态分析并修复错误

**Step 1: 运行 flutter analyze**

```bash
flutter analyze
```

**Step 2: 记录所有错误**

如果出现编译错误，记录到临时文件：

```bash
flutter analyze 2>&1 | tee analyze_errors.txt
```

**Step 3: 逐个修复分析错误**

根据错误信息修复：
- 缺失的导入
- 类型不匹配
- 未定义的标识符

**Step 4: 重新运行分析确认无错误**

```bash
flutter analyze
```

Expected: "No issues found!"

**Step 5: 提交修复**

```bash
git add -A
git commit -m "fix: resolve compilation errors after grid.dart removal

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 8: 验收测试

**Step 1: 首页测试**

```bash
flutter run -d linux
# 或者
flutter run -d android
```

手动验证：
- [ ] 首页推荐网格显示正常
- [ ] 骨架屏显示正常
- [ ] 视频卡片比例正常

**Step 2: 视频详情页测试**

验证：
- [ ] 相关视频网格显示正常
- [ ] 评论区网格显示正常

**Step 3: 搜索页测试**

验证：
- [ ] 搜索结果网格显示正常
- [ ] 各个搜索分类（视频、用户、文章等）网格正常

**Step 4: 其他关键页面测试**

- [ ] 历史记录页
- [ ] 收藏页
- [ ] 关注页
- [ ] 直播页

**Step 5: 提交验收**

```bash
git add -A
git commit -m "test: verify grid component removal migration

All key pages verified:
- Home page grids display correctly
- Video detail page grids display correctly
- Search page grids display correctly
- Skeleton screens work as expected

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 9: 清理和文档更新

**Step 1: 检查是否有文档引用 grid.dart**

```bash
grep -rn "grid\.dart" docs/
```

**Step 2: 更新相关文档**

如果文档中有引用，进行更新。

**Step 3: 最终提交**

```bash
git add docs/
git commit -m "docs: update documentation after grid.dart removal

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 10: 创建迁移总结 PR

**Step 1: 推送到远程分支**

```bash
git push origin main
```

**Step 2: 创建迁移总结文档**

在项目根目录创建 `MIGRATION_SUMMARY.md`：

```markdown
# Grid Component Removal Migration Summary

**Date:** 2026-03-01
**Scope:** 80+ files migrated

## What Changed

- Removed `lib/utils/grid.dart` custom implementation
- Replaced `SliverGridDelegateWithExtentAndRatio` with Flutter SDK native `SliverGridDelegateWithMaxCrossAxisExtent`
- Removed `GridMixin` and inlined skeleton screen code
- Unified grid delegate configuration across all pages

## Impact

- 80+ feature files updated
- 0 API changes
- UI remains identical for end users

## Benefits

- Reduced custom code maintenance
- Better alignment with Flutter SDK
- Simplified utils layer responsibilities

## Testing

All key pages manually verified:
- ✅ Home page
- ✅ Video detail page
- ✅ Search page
- ✅ History/Favorite/Follow pages
```

**Step 3: 最终提交**

```bash
git add MIGRATION_SUMMARY.md
git commit -m "docs: add grid component removal migration summary

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Notes

- **Expected duration:** 2-3 hours for full migration
- **Critical path:** Tasks 1-7 must be completed in order
- **Rollback plan:** `git reset --hard <commit-before-task-1>`
- **Testing focus:** Key pages (home, video detail, search) should be thoroughly tested

## Verification Checklist

- [ ] `lib/utils/grid.dart` deleted
- [ ] No imports of `grid.dart` remain
- [ ] No `GridMixin` usage remains
- [ ] `flutter analyze` passes with no errors
- [ ] Key pages display grids correctly
- [ ] Skeleton screens work as expected
- [ ] Documentation updated
