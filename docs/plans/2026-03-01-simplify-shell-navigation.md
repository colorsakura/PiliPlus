# Shell Navigation Simplification Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Simplify Shell navigation by removing the over-engineered NavigationConfig system and fixing navigation to three options: home, dynamics, mine.

**Architecture:** Replace the 5-layer architecture (Entity → Repository → DataSource → UseCase → Controller) with a simple 1-layer architecture (State → Controller → UI). Navigation options are hardcoded as constants.

**Tech Stack:** Flutter 3.41.2, Dart 3.10+, Riverpod 3.2.1

**Prerequisites:**
- Read design document: `docs/plans/2026-03-01-simplify-shell-navigation-design.md`
- Understand current NavigationConfig implementation

---

## Task 1: Create NavigationState entity

**Files:**
- Create: `lib/features/shell/domain/entities/navigation_state.dart`

**Step 1: Create navigation_state.dart**

```dart
/// 导航状态
///
/// 管理导航栏选中状态
class NavigationState {
  /// 当前选中的索引
  final int selectedIndex;

  const NavigationState({this.selectedIndex = 0});

  NavigationState copyWith({int? selectedIndex}) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
```

**Step 2: Run flutter analyze**

```bash
flutter analyze lib/features/shell/domain/entities/navigation_state.dart
```

Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/shell/domain/entities/navigation_state.dart
git commit -m "refactor(shell): create NavigationState entity

- Simple state class with selectedIndex
- Immutable with copyWith method
- Replaces complex NavigationConfig entity"
```

---

## Task 2: Create simplified NavigationController

**Files:**
- Create: `lib/features/shell/presentation/providers/navigation_controller.dart` (new file)
- Modify: `lib/features/shell/presentation/providers/navigation_provider.dart`

**Step 1: Create navigation_controller.dart with new simplified controller**

```dart
import 'package:PiliPlus/features/shell/domain/entities/navigation_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_controller.g.dart';

/// 导航控制器
///
/// 管理导航选中状态的简化控制器
@riverpod
class Navigation extends _$Navigation {
  @override
  NavigationState build() => const NavigationState();

  /// 更新选中的导航索引
  void updateIndex(int index) {
    // 验证索引范围（0-2，对应三个固定导航项）
    if (index >= 0 && index < 3) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  /// 重置到首页
  void reset() {
    state = const NavigationState(selectedIndex: 0);
  }
}
```

**Step 2: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/providers/navigation_controller.dart
```

Expected: No errors

**Step 3: Generate Riverpod code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: Generates `navigation_controller.g.dart`

**Step 4: Update navigation_provider.dart to export the new controller**

```dart
// Export for easy access
export 'navigation_controller.dart';
```

**Step 5: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/providers/
```

Expected: No errors

**Step 6: Commit**

```bash
git add lib/features/shell/presentation/providers/
git commit -m "refactor(shell): create simplified NavigationController

- Replace NavigationConfigController with simple Navigation
- Manage only selectedIndex state (0-2)
- Add index validation (0-2 for 3 fixed items)
- Add reset() method for returning to home
- Reduce from ~100 lines to ~40 lines"
```

---

## Task 3: Modify ShellPage to use fixed navigation items

**Files:**
- Modify: `lib/features/shell/presentation/pages/shell_page.dart`

**Step 1: Read current imports and provider usage**

```bash
head -35 lib/features/shell/presentation/pages/shell_page.dart
```

**Step 2: Add fixed navigation items constant to _ShellPageState class**

Add after the `_padding` field declaration (around line 46):

```dart
// 固定的导航选项
static const List<NavigationBarType> _navigationItems = [
  NavigationBarType.home,
  NavigationBarType.dynamics,
  NavigationBarType.mine,
];
```

**Step 3: Update build() method to use new navigation provider**

Find and replace the config watching (around line 192-195):

```dart
// BEFORE:
final navConfigState = ref.watch(navigationConfigControllerProvider);
final unreadDyn = ref.watch(unreadDynamicControllerProvider);

final config = navConfigState.config;
if (config == null) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}

// AFTER:
final selectedIndex = ref.watch(navigationProvider).selectedIndex;
final unreadDyn = ref.watch(unreadDynamicControllerProvider);
```

**Step 4: Update _handleNavTap method to use new controller**

Find the `_handleNavTap` method (around line 155-183) and update:

```dart
void _handleNavTap(int index) {
  feedBack();

  // 验证索引范围
  if (index < 0 || index >= _navigationItems.length) return;

  final currentIndex = widget.navigationShell.currentIndex;
  final currentNav = _navigationItems[index];

  if (index != currentIndex) {
    // 切换到新分支
    widget.navigationShell.goBranch(index);
    ref.read(navigationProvider.notifier).updateIndex(index);

    // 根据页面类型执行特定操作
    if (currentNav == NavigationBarType.dynamics) {
      ref.read(unreadDynamicControllerProvider.notifier).clear();
    }
  } else {
    // 双击同页面：触发刷新
    ref.read(refreshTriggerProvider.notifier).trigger(index);
  }
}
```

**Step 5: Update _handlePop method to use new controller**

Find the `_handlePop` method (around line 140-152) and update:

```dart
void _handlePop() {
  final currentIndex = widget.navigationShell.currentIndex;

  if (currentIndex != 0) {
    // 返回到首页
    widget.navigationShell.goBranch(0);
    ref.read(navigationProvider.notifier).updateIndex(0);
    ref.read(navigationStateControllerProvider.notifier).reset();
  } else {
    _onBack();
  }
}
```

**Step 6: Remove old config-dependent code**

Find and remove the config null check (if it still exists after Task 3-4):

```dart
// DELETE this block:
if (config == null) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}
```

**Step 7: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/pages/shell_page.dart
```

Expected: No errors (but there will be unused variable warnings for `config`)

**Step 8: Commit**

```bash
git add lib/features/shell/presentation/pages/shell_page.dart
git commit -m "refactor(shell): use fixed navigation items in ShellPage

- Add _navigationItems constant with 3 fixed options
- Replace navigationConfigControllerProvider with navigationProvider
- Simplify build() method - no config loading
- Update _handleNavTap to use fixed items list
- Update _handlePop to use new controller
- Remove config null check"
```

---

## Task 4: Modify BottomNavigationBar widget

**Files:**
- Modify: `lib/features/shell/presentation/widgets/bottom_nav_bar.dart`

**Step 1: Read current widget signature**

```bash
head -25 lib/features/shell/presentation/widgets/bottom_nav_bar.dart
```

**Step 2: Update widget signature to remove config parameter**

Replace the entire widget class:

```dart
import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/nav_icon_builder.dart';
import 'package:flutter/material.dart';

/// 底部导航栏
///
/// 用于移动端竖屏模式，显示底部导航项
class ShellBottomNavigationBar extends StatelessWidget {
  const ShellBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.dynCount,
    required this.onDestinationSelected,
  });

  final List<NavigationBarType> items;
  final int selectedIndex;
  final int dynCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onDestinationSelected,
      iconSize: 16,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      items: items
          .map(
            (e) => BottomNavigationBarItem(
              label: e.label,
              icon: NavIconBuilder(
                type: e,
                dynCount: dynCount,
              ),
              activeIcon: NavIconBuilder(
                type: e,
                selected: true,
                dynCount: dynCount,
              ),
            ),
          )
          .toList(),
    );
  }
}
```

**Key changes:**
- Removed `config` parameter
- Added `items` parameter (List<NavigationBarType>)
- Added `selectedIndex` parameter (int)
- Simplified currentIndex to use `selectedIndex` directly
- Removed config clamping (validation is in controller)

**Step 3: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/widgets/bottom_nav_bar.dart
```

Expected: No errors

**Step 4: Commit**

```bash
git add lib/features/shell/presentation/widgets/bottom_nav_bar.dart
git commit -m "refactor(shell): simplify BottomNavigationBar widget

- Remove NavigationConfig dependency
- Accept fixed items list and selectedIndex
- Simplify currentIndex logic
- Widget is now more reusable and testable"
```

---

## Task 5: Modify SideNavBar widget

**Files:**
- Modify: `lib/features/shell/presentation/widgets/side_nav_bar.dart`

**Step 1: Update widget signature to remove config parameter**

Read the current file first:

```bash
cat lib/features/shell/presentation/widgets/side_nav_bar.dart
```

Replace the widget class:

```dart
import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/nav_icon_builder.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/user_section.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:flutter/material.dart';

/// 侧边导航栏
///
/// 用于桌面端/平板横屏模式，显示侧边导航项和用户区域
class SideNavBar extends StatelessWidget {
  const SideNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.dynCount,
    required this.dynamicBadgeMode,
    required this.unreadMessage,
    required this.msgBadgeMode,
    required this.theme,
    required this.onDestinationSelected,
    required this.onSearchPressed,
    required this.onMessagePressed,
    required this.onUserTap,
    required this.isLogin,
    this.faceUrl,
  });

  final List<NavigationBarType> items;
  final int selectedIndex;
  final int dynCount;
  final DynamicBadgeMode dynamicBadgeMode;
  final UnreadMessage unreadMessage;
  final DynamicBadgeMode msgBadgeMode;
  final ThemeData theme;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSearchPressed;
  final VoidCallback onMessagePressed;
  final VoidCallback onUserTap;
  final bool isLogin;
  final String? faceUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          const SizedBox(height: 25),
          Expanded(
            flex: 5,
            child: SizedBox(
              width: 60,
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: onDestinationSelected,
                selectedIndex: selectedIndex,
                destinations: items
                    .map(
                      (e) => NavigationRailDestination(
                        label: Text(e.label),
                        icon: NavIconBuilder(
                          type: e,
                          dynCount: dynCount,
                        ),
                        selectedIcon: NavIconBuilder(
                          type: e,
                          selected: true,
                          dynCount: dynCount,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Spacer(flex: 2),
          UserSection(
            unreadMessage: unreadMessage,
            msgBadgeMode: msgBadgeMode,
            onSearchPressed: onSearchPressed,
            onMessagePressed: onMessagePressed,
            onUserTap: onUserTap,
            isLogin: isLogin,
            faceUrl: faceUrl,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
```

**Key changes:**
- Removed `config` parameter
- Added `items` parameter (List<NavigationBarType>)
- Added `selectedIndex` parameter (int)
- Simplified selectedIndex to use parameter directly
- Removed config clamping logic

**Step 2: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/widgets/side_nav_bar.dart
```

Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/shell/presentation/widgets/side_nav_bar.dart
git commit -m "refactor(shell): simplify SideNavBar widget

- Remove NavigationConfig dependency
- Accept fixed items list and selectedIndex
- Simplify selectedIndex logic
- Widget is now more reusable and testable"
```

---

## Task 6: Update ShellPage widget calls

**Files:**
- Modify: `lib/features/shell/presentation/pages/shell_page.dart`

**Step 1: Update BottomNavigationBar call in build() method**

Find the BottomNavigationBar instantiation (around line 222) and update:

```dart
// BEFORE:
bottomNav = ShellBottomNavigationBar(
  config: config,
  dynCount: unreadDyn.count,
  onDestinationSelected: _handleNavTap,
),

// AFTER:
bottomNav = ShellBottomNavigationBar(
  items: _navigationItems,
  selectedIndex: selectedIndex,
  dynCount: unreadDyn.count,
  onDestinationSelected: _handleNavTap,
),
```

**Step 2: Update SideNavBar call in build() method**

Find the SideNavBar instantiation (around line 232) and update:

```dart
// BEFORE:
SideNavBar(
  config: config,
  dynCount: unreadDyn.count,
  dynamicBadgeMode: dynamicBadgeMode,
  unreadMessage: unreadMsg,
  msgBadgeMode: msgBadgeMode,
  theme: theme,
  onDestinationSelected: _handleNavTap,
  onSearchPressed: () => PageUtils.goNamed(AppRoutes.search),
  onMessagePressed: () => PageUtils.goNamed(AppRoutes.whisper),
  onUserTap: () => widget.navigationShell.goBranch(2),
  isLogin: Get.find<AccountService>().isLogin.value,
  faceUrl: Get.find<AccountService>().face.value,
),

// AFTER:
SideNavBar(
  items: _navigationItems,
  selectedIndex: selectedIndex,
  dynCount: unreadDyn.count,
  dynamicBadgeMode: dynamicBadgeMode,
  unreadMessage: unreadMsg,
  msgBadgeMode: msgBadgeMode,
  theme: theme,
  onDestinationSelected: _handleNavTap,
  onSearchPressed: () => PageUtils.goNamed(AppRoutes.search),
  onMessagePressed: () => PageUtils.goNamed(AppRoutes.whisper),
  onUserTap: () => widget.navigationShell.goBranch(2),
  isLogin: Get.find<AccountService>().isLogin.value,
  faceUrl: Get.find<AccountService>().face.value,
),
```

**Step 3: Remove unused variables**

Find and remove these variable reads if they still exist:

```dart
// DELETE these lines (if present):
final config = navConfigState.config;
```

**Step 4: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/pages/shell_page.dart
```

Expected: No errors

**Step 5: Commit**

```bash
git add lib/features/shell/presentation/pages/shell_page.dart
git commit -m "refactor(shell): update widget calls to use simplified navigation

- Pass _navigationItems to BottomNavigationBar and SideNavBar
- Pass selectedIndex directly instead of via config
- Remove unused config variable
- All navigation widgets now use fixed items list"
```

---

## Task 7: Remove unused import from ShellPage

**Files:**
- Modify: `lib/features/shell/presentation/pages/shell_page.dart`

**Step 1: Check for unused imports**

```bash
head -20 lib/features/shell/presentation/pages/shell_page.dart
```

**Step 2: Remove navigation_config.dart import if it exists**

If you see this line, remove it:

```dart
import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
```

**Step 3: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/pages/shell_page.dart
```

Expected: No errors, no unused import warnings for navigation_config

**Step 4: Commit**

```bash
git add lib/features/shell/presentation/pages/shell_page.dart
git commit -m "refactor(shell): remove unused NavigationConfig import

- Remove import for deleted navigation_config.dart
- Clean up unused imports"
```

---

## Task 8: Delete old NavigationConfig entity

**Files:**
- Delete: `lib/features/shell/domain/entities/navigation_config.dart`

**Step 1: Verify file exists**

```bash
ls -la lib/features/shell/domain/entities/navigation_config.dart
```

Expected: File exists

**Step 2: Delete the file**

```bash
rm lib/features/shell/domain/entities/navigation_config.dart
```

**Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: Errors in other files that reference this entity (we'll fix those in next tasks)

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(shell): delete NavigationConfig entity

- Remove 66-line entity file
- Replaced by simple NavigationState
- No longer need complex configuration object"
```

---

## Task 9: Delete NavigationRepository interface and implementation

**Files:**
- Delete: `lib/features/shell/domain/repositories/navigation_repository.dart`
- Delete: `lib/features/shell/data/repositories/navigation_repository_impl.dart`

**Step 1: Verify files exist**

```bash
ls -la lib/features/shell/domain/repositories/navigation_repository.dart
ls -la lib/features/shell/data/repositories/navigation_repository_impl.dart
```

Expected: Both files exist

**Step 2: Delete both files**

```bash
rm lib/features/shell/domain/repositories/navigation_repository.dart
rm lib/features/shell/data/repositories/navigation_repository_impl.dart
```

**Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: Errors in files that reference these (we'll fix in next tasks)

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(shell): delete NavigationRepository files

- Remove repository interface (10 lines)
- Remove repository implementation (20 lines)
- No longer need data layer for navigation"
```

---

## Task 10: Delete GetNavigationConfig use case

**Files:**
- Delete: `lib/features/shell/domain/usecases/get_navigation_config.dart`

**Step 1: Verify file exists**

```bash
ls -la lib/features/shell/domain/usecases/get_navigation_config.dart
```

Expected: File exists

**Step 2: Delete the file**

```bash
rm lib/features/shell/domain/usecases/get_navigation_config.dart
```

**Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: Fewer errors now

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(shell): delete GetNavigationConfig use case

- Remove use case file (20 lines)
- No longer need use case layer"
```

---

## Task 11: Delete NavigationLocalDataSource

**Files:**
- Delete: `lib/features/shell/data/datasources/navigation_local_datasource.dart`

**Step 1: Verify file exists**

```bash
ls -la lib/features/shell/data/datasources/navigation_local_datasource.dart
```

Expected: File exists

**Step 2: Delete the file**

```bash
rm lib/features/shell/data/datasources/navigation_local_datasource.dart
```

**Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: Even fewer errors now

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(shell): delete NavigationLocalDataSource

- Remove datasource file (30 lines)
- No longer need local data loading"
```

---

## Task 12: Fix provider imports and exports

**Files:**
- Modify: `lib/features/shell/presentation/providers/navigation_provider.dart`
- Modify: `lib/features/shell/presentation/providers/shell_providers.dart`

**Step 1: Check current exports**

```bash
cat lib/features/shell/presentation/providers/navigation_provider.dart
```

**Step 2: Update navigation_provider.dart to only export what's needed**

Replace content with:

```dart
export 'navigation_controller.dart';
```

**Step 3: Check shell_providers.dart**

```bash
cat lib/features/shell/presentation/providers/shell_providers.dart
```

**Step 4: Remove any references to deleted providers**

Remove lines like:
```dart
export 'navigation_provider.dart'; // if it references old NavigationConfigController
```

Or update to:
```dart
export 'navigation_controller.dart';
```

**Step 5: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/providers/
```

Expected: No errors

**Step 6: Commit**

```bash
git add lib/features/shell/presentation/providers/
git commit -m "refactor(shell): update provider exports

- Update navigation_provider.dart to export new controller
- Remove references to deleted NavigationConfigController
- Clean up provider exports"
```

---

## Task 13: Search and replace all NavigationConfig references

**Files:**
- Multiple (will be found by search)

**Step 1: Search for remaining NavigationConfig references**

```bash
grep -rn "NavigationConfig" lib/features/shell/ --include="*.dart"
```

**Step 2: Review each reference**

For each reference found, determine if it needs to be updated or removed.

Common fixes:
- Change `NavigationConfig` to `List<NavigationBarType>` where needed
- Change `.config` to `.selectedIndex` or `.items` as appropriate
- Remove config-related code

**Step 3: Fix any remaining references**

Based on what you find in Step 1, make the necessary fixes.

**Step 4: Run flutter analyze**

```bash
flutter analyze
```

Expected: No NavigationConfig-related errors

**Step 5: Commit**

```bash
git add -A
git commit -m "refactor(shell): fix remaining NavigationConfig references

- Update all references to use new simplified structure
- Replace config with items/selectedIndex where needed
- Ensure no NavigationConfig imports remain"
```

---

## Task 14: Final verification and testing

**Files:**
- All modified files

**Step 1: Run flutter analyze on entire project**

```bash
flutter analyze
```

Expected: No errors

**Step 2: Check file structure**

```bash
find lib/features/shell -name "*.dart" | grep -E "(navigation|config)" | sort
```

Expected: Should NOT see:
- navigation_config.dart
- navigation_repository.dart
- navigation_repository_impl.dart
- get_navigation_config.dart
- navigation_local_datasource.dart

Should see:
- navigation_state.dart
- navigation_controller.dart
- navigation_provider.dart

**Step 3: Verify component files still work**

```bash
ls -lh lib/features/shell/presentation/widgets/
```

Expected: All 6 component files still present and non-empty

**Step 4: Test build**

```bash
timeout 30 flutter run -d linux
```

Expected: App launches successfully with working navigation

Test navigation:
- ✅ Bottom navigation shows 3 items (home, dynamics, mine)
- ✅ Side navigation shows 3 items
- ✅ Tapping items switches correctly
- ✅ Selected state persists

**Step 5: Count lines of code reduction**

```bash
echo "Files deleted:"
echo "- navigation_config.dart (~66 lines)"
echo "- navigation_repository.dart (~10 lines)"
echo "- navigation_repository_impl.dart (~20 lines)"
echo "- get_navigation_config.dart (~20 lines)"
echo "- navigation_local_datasource.dart (~30 lines)"
echo "- Old navigation_provider.dart (~70 lines removed)"
echo ""
echo "Total reduction: ~216 lines"
```

**Step 6: Final commit**

```bash
git add -A
git commit -m "refactor(shell): complete navigation simplification

✅ Achievements:
- Deleted 5 over-engineered files (~146 lines)
- Simplified navigation provider (~70 lines removed)
- Created simple NavigationState (10 lines)
- Created simplified NavigationController (~40 lines)
- Total code reduction: ~216 lines
- Architecture: 5 layers → 1 layer
- Fixed navigation to 3 options: home, dynamics, mine

✅ All functionality preserved:
- Navigation switching works correctly
- Selected state maintained
- Bottom nav works (mobile portrait)
- Side nav works (desktop/tablet)
- All callbacks properly connected

✅ Code quality:
- flutter analyze passes
- Build successful on Linux
- All components working correctly"
```

---

## Verification Checklist

After completing all tasks, verify:

- [ ] NavigationState entity created
- [ ] NavigationController created and simplified
- [ ] ShellPage uses _navigationItems constant
- [ ] ShellPage uses navigationProvider instead of navigationConfigControllerProvider
- [ ] BottomNavigationBar uses items and selectedIndex parameters
- [ ] SideNavBar uses items and selectedIndex parameters
- [ ] All 5 old files deleted (config, repository x2, usecase, datasource)
- [ ] flutter analyze passes with no errors
- [ ] No NavigationConfig references remain
- [ ] Navigation works correctly in app
- [ ] All 3 navigation items visible and functional

---

## Rollback Plan

If issues arise:

```bash
# Reset to before refactoring
git log --oneline | grep "refactor(shell):"
git reset --hard <commit-before-refactoring>

# Or revert specific commits
git revert <oldest-refactor-commit>..<latest-refactor-commit>
```

---

**End of Implementation Plan**
