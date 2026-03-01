# Shell Page Component Extraction Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor shell_page.dart (485 lines) into 7 modular components to improve maintainability and follow single responsibility principle.

**Architecture:** Extract 6 UI components from ShellPage into separate StatelessWidget files in presentation/widgets/ directory, maintaining all functionality while reducing main file to ~150 lines.

**Tech Stack:** Flutter 3.41.2, Dart 3.10+, Riverpod 3.2.1, go_router 17.1.0

**Prerequisites:**
- Read design document: `docs/plans/2026-03-01-shell-page-component-extraction-design.md`
- Project uses clean architecture (see `docs/CLEAN_ARCHITECTURE_MIGRATION.md`)

---

## Task 1: Create widgets directory

**Files:**
- Create: `lib/features/shell/presentation/widgets/` (directory)

**Step 1: Create widgets directory**

```bash
mkdir -p lib/features/shell/presentation/widgets
```

**Step 2: Verify directory created**

```bash
ls -la lib/features/shell/presentation/
```

Expected: Should see `widgets/` directory listed

**Step 3: Create .gitkeep to ensure empty directory is tracked**

```bash
touch lib/features/shell/presentation/widgets/.gitkeep
```

**Step 4: Commit**

```bash
git add lib/features/shell/presentation/widgets/.gitkeep
git commit -m "refactor(shell): create widgets directory for component extraction"
```

---

## Task 2: Create NavIconBuilder component

**Files:**
- Create: `lib/features/shell/presentation/widgets/nav_icon_builder.dart`
- Reference: `lib/features/shell/presentation/pages/shell_page.dart:354-373`

**Step 1: Create nav_icon_builder.dart**

```dart
import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:flutter/material.dart';

/// 导航图标构建器
///
/// 根据导航类型和选中状态构建图标，为动态页面显示未读角标
class NavIconBuilder extends StatelessWidget {
  const NavIconBuilder({
    super.key,
    required this.type,
    this.selected = false,
    required this.dynCount,
  });

  final NavigationBarType type;
  final bool selected;
  final int dynCount;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? type.selectIcon : type.icon;

    // 动态页面显示角标
    if (type == NavigationBarType.dynamics) {
      return Badge(
        isLabelVisible: dynCount > 0,
        label: Text(dynCount.toString()),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: icon,
      );
    }

    return icon;
  }
}
```

**Step 2: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/widgets/nav_icon_builder.dart
```

Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/shell/presentation/widgets/nav_icon_builder.dart
git commit -m "refactor(shell): extract NavIconBuilder component

- Extract icon building logic from shell_page.dart
- Support badge display for dynamics page
- Use StatelessWidget for pure UI component"
```

---

## Task 3: Create UserAvatarButton component

**Files:**
- Create: `lib/features/shell/presentation/widgets/user_avatar_button.dart`
- Reference: `lib/features/shell/presentation/pages/shell_page.dart:409-451`

**Step 1: Create user_avatar_button.dart**

```dart
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:flutter/material.dart';

/// 用户头像按钮
///
/// 显示用户头像或默认图标，处理登录/未登录状态
class UserAvatarButton extends StatelessWidget {
  const UserAvatarButton({
    super.key,
    required this.isLogin,
    this.faceUrl,
    required this.onTap,
    required this.theme,
  });

  final bool isLogin;
  final String? faceUrl;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "我的",
      child: GestureDetector(
        onTap: onTap,
        child: isLogin
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  NetworkImgLayer(
                    type: ImageType.avatar,
                    width: 34,
                    height: 34,
                    src: faceUrl,
                  ),
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: onTap,
                      ),
                    ),
                  ),
                ],
              )
            : Icon(
                Icons.person_outline,
                size: 34,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
      ),
    );
  }
}
```

**Step 2: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/widgets/user_avatar_button.dart
```

Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/shell/presentation/widgets/user_avatar_button.dart
git commit -m "refactor(shell): extract UserAvatarButton component

- Extract user avatar rendering logic
- Support logged-in/not-logged-in states
- Remove Obx dependency, use plain parameters"
```

---

## Task 4: Create MessageBadgeButton component

**Files:**
- Create: `lib/features/shell/presentation/widgets/message_badge_button.dart`
- Reference: `lib/features/shell/presentation/pages/shell_page.dart:453-484`

**Step 1: Read shell_page.dart to find showMsgBadge utility**

```bash
grep -n "showMsgBadge" lib/features/shell/presentation/pages/shell_page.dart
```

Expected: Find the showMsgBadge function usage

**Step 2: Find where showMsgBadge is defined**

```bash
grep -rn "bool showMsgBadge" lib/
```

Expected: Find the utility function location (likely in utils or providers)

**Step 3: Create message_badge_button.dart**

```dart
import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:flutter/material.dart';

/// 消息角标按钮
///
/// 显示消息图标和未读角标，支持数字/圆点/隐藏模式
class MessageBadgeButton extends StatelessWidget {
  const MessageBadgeButton({
    super.key,
    required this.unreadMessage,
    required this.badgeMode,
    required this.onPressed,
  });

  final UnreadMessage unreadMessage;
  final DynamicBadgeMode badgeMode;
  final VoidCallback onPressed;

  /// 判断是否显示消息角标按钮
  static bool showMsgBadge(DynamicBadgeMode mode) {
    return mode != DynamicBadgeMode.hidden;
  }

  @override
  Widget build(BuildContext context) {
    if (!showMsgBadge(badgeMode)) {
      return const SizedBox.shrink();
    }

    return Badge(
      isLabelVisible: unreadMessage.hasUnread,
      label: badgeMode == DynamicBadgeMode.number &&
              unreadMessage.displayText.isNotEmpty
          ? Text(unreadMessage.displayText)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: IconButton(
        tooltip: '消息',
        icon: const Icon(
          Icons.notifications_none,
          semanticLabel: '消息',
        ),
        onPressed: onPressed,
      ),
    );
  }
}
```

**Step 4: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/widgets/message_badge_button.dart
```

Expected: No errors

**Step 5: Commit**

```bash
git add lib/features/shell/presentation/widgets/message_badge_button.dart
git commit -m "refactor(shell): extract MessageBadgeButton component

- Extract message badge rendering logic
- Support number/dot/hidden badge modes
- Include showMsgBadge utility as static method"
```

---

## Task 5: Create UserSection component

**Files:**
- Create: `lib/features/shell/presentation/widgets/user_section.dart`
- Reference: `lib/features/shell/presentation/pages/shell_page.dart:377-407`

**Step 1: Create user_section.dart**

```dart
import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/user_avatar_button.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/message_badge_button.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:flutter/material.dart';

/// 用户区域组合组件
///
/// 垂直排列搜索、消息、头像三个组件
class UserSection extends StatelessWidget {
  const UserSection({
    super.key,
    required this.theme,
    required this.dynCount,
    required this.dynamicBadgeMode,
    required this.unreadMessage,
    required this.msgBadgeMode,
    required this.onSearchPressed,
    required this.onMessagePressed,
    required this.onUserTap,
    required this.isLogin,
    this.faceUrl,
  });

  final ThemeData theme;
  final int dynCount;
  final DynamicBadgeMode dynamicBadgeMode;
  final UnreadMessage unreadMessage;
  final DynamicBadgeMode msgBadgeMode;
  final VoidCallback onSearchPressed;
  final VoidCallback onMessagePressed;
  final VoidCallback onUserTap;
  final bool isLogin;
  final String? faceUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          tooltip: '搜索',
          icon: const Icon(
            Icons.search_outlined,
            semanticLabel: '搜索',
          ),
          onPressed: onSearchPressed,
        ),
        MessageBadgeButton(
          unreadMessage: unreadMessage,
          badgeMode: msgBadgeMode,
          onPressed: onMessagePressed,
        ),
        UserAvatarButton(
          isLogin: isLogin,
          faceUrl: faceUrl,
          onTap: onUserTap,
          theme: theme,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
```

**Step 2: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/widgets/user_section.dart
```

Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/shell/presentation/widgets/user_section.dart
git commit -m "refactor(shell): extract UserSection component

- Combine search, message badge, and user avatar
- Vertical layout for sidebar navigation
- Use composition of extracted components"
```

---

## Task 6: Create BottomNavigationBar component

**Files:**
- Create: `lib/features/shell/presentation/widgets/bottom_nav_bar.dart`
- Reference: `lib/features/shell/presentation/pages/shell_page.dart:265-296`

**Step 1: Create bottom_nav_bar.dart**

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
    required this.config,
    required this.dynCount,
    required this.onDestinationSelected,
  });

  final NavigationConfig config;
  final int dynCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: config.navigationBars.isEmpty
          ? 0
          : config.selectedIndex.clamp(
              0,
              config.navigationBars.length - 1,
            ),
      onTap: onDestinationSelected,
      iconSize: 16,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      items: config.navigationBars
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

**Step 2: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/widgets/bottom_nav_bar.dart
```

Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/shell/presentation/widgets/bottom_nav_bar.dart
git commit -m "refactor(shell): extract BottomNavigationBar component

- Extract bottom navigation bar for mobile portrait mode
- Use NavIconBuilder for consistent icon rendering
- Support badge display on navigation items"
```

---

## Task 7: Create SideNavBar component

**Files:**
- Create: `lib/features/shell/presentation/widgets/side_nav_bar.dart`
- Reference: `lib/features/shell/presentation/pages/shell_page.dart:298-350`

**Step 1: Create side_nav_bar.dart**

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
    required this.config,
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

  final NavigationConfig config;
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
                selectedIndex: config.navigationBars.isEmpty
                    ? 0
                    : config.selectedIndex.clamp(
                        0,
                        config.navigationBars.length - 1,
                      ),
                destinations: config.navigationBars
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
            theme: theme,
            dynCount: dynCount,
            dynamicBadgeMode: dynamicBadgeMode,
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

**Step 2: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/widgets/side_nav_bar.dart
```

Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/shell/presentation/widgets/side_nav_bar.dart
git commit -m "refactor(shell): extract SideNavBar component

- Extract sidebar navigation for desktop/tablet landscape mode
- Integrate UserSection for bottom area
- Use NavigationRail with consistent icon rendering"
```

---

## Task 8: Refactor ShellPage to use new components

**Files:**
- Modify: `lib/features/shell/presentation/pages/shell_page.dart:1-485`

**Step 1: Read current shell_page.dart to understand structure**

```bash
head -30 lib/features/shell/presentation/pages/shell_page.dart
```

**Step 2: Add imports for new components at top of file**

After line 12 (after other feature imports), add:

```dart
import 'package:PiliPlus/features/shell/presentation/widgets/bottom_nav_bar.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/side_nav_bar.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/nav_icon_builder.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/user_avatar_button.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/message_badge_button.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/user_section.dart';
```

**Step 3: Run flutter analyze to check imports**

```bash
flutter analyze lib/features/shell/presentation/pages/shell_page.dart
```

Expected: No errors (imports working but not used yet)

**Step 4: Replace _buildBottomNav method call in build() method**

Find line around 215:
```dart
bottomNav = _buildBottomNav(config, unreadDyn.count),
```

Replace with:
```dart
bottomNav = ShellBottomNavigationBar(
  config: config,
  dynCount: unreadDyn.count,
  onDestinationSelected: _handleNavTap,
),
```

**Step 5: Replace _buildSideBar method call in build() method**

Find line around 221:
```dart
_buildSideBar(config, theme, unreadDyn.count),
```

Replace with:
```dart
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
```

**Step 6: Run flutter analyze**

```bash
flutter analyze lib/features/shell/presentation/pages/shell_page.dart
```

Expected: No errors

**Step 7: Verify build method compiles**

```bash
flutter analyze
```

Expected: No errors

**Step 8: Commit**

```bash
git add lib/features/shell/presentation/pages/shell_page.dart
git commit -m "refactor(shell): use extracted components in ShellPage

- Replace _buildBottomNav with ShellBottomNavigationBar component
- Replace _buildSideBar with SideNavBar component
- Add necessary callback handlers for component interactions
- Pass AccountService values as parameters (remove Obx dependency)"
```

---

## Task 9: Remove obsolete private methods from ShellPage

**Files:**
- Modify: `lib/features/shell/presentation/pages/shell_page.dart`

**Step 1: Remove _buildBottomNav method**

Find and delete lines 265-296:
```dart
/// 构建底部导航栏（移动端竖屏）
Widget _buildBottomNav(NavigationConfig config, int dynCount) {
  // ... entire method
}
```

**Step 2: Remove _buildSideBar method**

Find and delete lines 298-350:
```dart
/// 构建侧边导航栏（桌面端/平板）
Widget _buildSideBar(NavigationConfig config, ThemeData theme, int dynCount) {
  // ... entire method
}
```

**Step 3: Remove _buildIcon method**

Find and delete lines 354-373:
```dart
/// 构建导航图标
Widget _buildIcon({
  required NavigationBarType type,
  bool selected = false,
  required int dynCount,
}) {
  // ... entire method
}
```

**Step 4: Remove _buildUserAndSearchVertical method**

Find and delete lines 377-407:
```dart
/// 构建用户头像和搜索按钮（垂直布局）
Widget _buildUserAndSearchVertical(
  ThemeData theme,
  int dynCount,
  DynamicBadgeMode dynamicBadgeMode,
) {
  // ... entire method
}
```

**Step 5: Remove _buildUserAvatar method**

Find and delete lines 409-451:
```dart
/// 构建用户头像
Widget _buildUserAvatar(ThemeData theme, AccountService accountService) {
  // ... entire method
}
```

**Step 6: Remove _buildMsgBadge method**

Find and delete lines 453-484:
```dart
/// 构建消息按钮（带未读角标）
Widget _buildMsgBadge(
  UnreadMessage unreadMsg,
  DynamicBadgeMode msgBadgeMode,
) {
  // ... entire method
}
```

**Step 7: Run flutter analyze**

```bash
flutter analyze
```

Expected: No errors

**Step 8: Verify file is now approximately 150 lines**

```bash
wc -l lib/features/shell/presentation/pages/shell_page.dart
```

Expected: Around 150 lines (reduced from 485)

**Step 9: Commit**

```bash
git add lib/features/shell/presentation/pages/shell_page.dart
git remove lib/features/shell/presentation/widgets/.gitkeep
git commit -m "refactor(shell): remove obsolete private methods from ShellPage

- Delete _buildBottomNav, _buildSideBar, _buildIcon methods
- Delete _buildUserAndSearchVertical, _buildUserAvatar, _buildMsgBadge methods
- Reduce file from 485 lines to ~150 lines
- All functionality moved to extracted components"
```

---

## Task 10: Final verification and testing

**Files:**
- Test: All modified files

**Step 1: Run flutter analyze on entire project**

```bash
flutter analyze
```

Expected: No errors or warnings

**Step 2: Check file structure**

```bash
tree -L 3 lib/features/shell/presentation/
```

Expected output:
```
lib/features/shell/presentation/
├── pages
│   └── shell_page.dart
└── widgets
    ├── bottom_nav_bar.dart
    ├── side_nav_bar.dart
    ├── nav_icon_builder.dart
    ├── user_avatar_button.dart
    ├── message_badge_button.dart
    └── user_section.dart
```

**Step 3: Verify component files exist and are non-empty**

```bash
ls -lh lib/features/shell/presentation/widgets/
```

Expected: All 6 component files listed with sizes > 0

**Step 4: Run Linux platform test (30 second timeout)**

```bash
timeout 30 flutter run -d linux
```

Expected: App launches without errors, test navigation:
- ✅ Bottom navigation bar visible (if portrait mode)
- ✅ Side navigation bar visible (if landscape mode)
- ✅ User avatar displays correctly
- ✅ Message badge displays if unread messages exist
- ✅ Navigation switches between tabs correctly
- ✅ Search button opens search page
- ✅ Avatar click navigates to user profile

Press Ctrl+C after 30 seconds to stop

**Step 5: Verify code reduction**

```bash
echo "Original shell_page.dart lines: 485"
echo "New shell_page.dart lines: $(wc -l < lib/features/shell/presentation/pages/shell_page.dart)"
echo "New component files total lines: $(wc -l < lib/features/shell/presentation/widgets/*.dart | tail -1)"
```

Expected: shell_page.dart reduced to ~150 lines

**Step 6: Final commit**

```bash
git add -A
git commit -m "refactor(shell): complete component extraction

✅ Achievements:
- Reduced shell_page.dart from 485 to ~150 lines (70% reduction)
- Created 6 reusable UI components
- Improved code maintainability and single responsibility
- Maintained all original functionality
- Passed flutter analyze
- Tested on Linux platform

Components extracted:
- NavIconBuilder: Icon and badge rendering
- UserAvatarButton: User avatar with login state
- MessageBadgeButton: Message badge with modes
- UserSection: Combined user area
- ShellBottomNavigationBar: Mobile bottom navigation
- SideNavBar: Desktop/tablet sidebar navigation"
```

---

## Verification Checklist

After completing all tasks, verify:

- [ ] All 6 component files created in `lib/features/shell/presentation/widgets/`
- [ ] `shell_page.dart` reduced to ~150 lines
- [ ] All private `_build*()` methods removed
- [ ] `flutter analyze` passes with no errors
- [ ] App launches successfully on Linux
- [ ] Bottom navigation works (portrait mode)
- [ ] Side navigation works (landscape/desktop mode)
- [ ] User avatar displays correctly (logged in/out states)
- [ ] Message badge displays correctly (number/dot/hidden modes)
- [ ] All navigation items switch correctly
- [ ] No Obx() dependencies in new components
- [ ] All functionality preserved from original implementation

---

## Notes for Implementation

### Key Changes from Original Code

1. **AccountService Obx Removal:**
   - Original: `Obx(() => NetworkImgLayer(src: accountService.face.value))`
   - New: Pass `isLogin` and `faceUrl` as plain parameters from ShellPage

2. **NavigationShell Access:**
   - Original: Direct access in `_buildUserAvatar`
   - New: Pass via `onTap` callback parameter

3. **Provider Reading:**
   - Original: Read providers in component methods
   - New: Read in ShellPage, pass as parameters

### Import Dependencies

All new components may need these imports (adjust as needed):
```dart
import 'package:PiliPlus/features/shell/domain/entities/...';
import 'package:PiliPlus/models/common/...';
import 'package:PiliPlus/shared/widgets/...';
import 'package:flutter/material.dart';
```

### Code Style Consistency

- Use `const` constructors where possible
- Prefer named parameters for clarity
- Include documentation comments for public APIs
- Follow existing project naming conventions (snake_case for files)

---

## Rollback Plan

If issues arise:

```bash
# Reset to before refactoring
git reflog
git reset --hard <commit-before-refactoring>

# Or revert specific commits
git revert <commit-hash-range>
```

---

**End of Implementation Plan**
