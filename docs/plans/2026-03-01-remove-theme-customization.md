# Remove Theme Customization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove all custom theme infrastructure and use Flutter's default Material 3 theme while preserving light/dark/system mode switching.

**Architecture:** Delete theme directory and related pages, simplify app.dart to use Flutter's default ThemeData, remove theme-related settings and storage keys.

**Tech Stack:** Flutter 3.41.2, Dart 3.10+, Material 3

---

## Task 1: Delete Theme Directory

**Files:**
- Delete: `lib/app/theme/entities/theme_type.dart`
- Delete: `lib/app/theme/entities/theme_colors.dart`
- Delete: `lib/app/theme/services/theme_service.dart`
- Delete: `lib/app/theme/extensions/theme_extensions.dart`
- Delete: `lib/app/theme/extensions/brightness_extensions.dart`
- Delete: `lib/app/theme/extensions/color_extensions.dart`
- Delete: `lib/app/theme/extensions/color_scheme_extensions.dart`

**Step 1: Delete the theme directory**

```bash
rm -rf lib/app/theme
```

**Step 2: Verify deletion**

```bash
ls -la lib/app/
```

Expected: `theme` directory no longer exists

**Step 3: Check for compilation errors**

```bash
flutter analyze
```

Expected: Multiple errors about missing imports (we'll fix these in subsequent tasks)

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(theme): delete theme directory

Remove all theme-related files:
- theme_type.dart (ThemeType enum)
- theme_colors.dart (19 color themes)
- theme_service.dart (ThemeService class)
- theme_extensions/ (extension exports)

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 2: Delete Color Selection Page

**Files:**
- Delete: `lib/features/setting/presentation/pages/pages/color_select.dart`

**Step 1: Delete color selection page**

```bash
rm lib/features/setting/presentation/pages/pages/color_select.dart
```

**Step 2: Verify deletion**

```bash
ls -la lib/features/setting/presentation/pages/pages/
```

Expected: `color_select.dart` no longer exists

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor(theme): delete color selection page

Remove ColorSelectPage which allowed users to:
- Select theme mode (light/dark/system)
- Choose from 19 color themes
- Select scheme variant

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Modify app.dart - Use Default Theme

**Files:**
- Modify: `lib/app/app.dart:1-49`

**Step 1: Read current app.dart**

```bash
cat lib/app/app.dart
```

**Step 2: Remove theme-related imports**

Edit `lib/app/app.dart`, remove these lines:
- Line 2: `import 'package:PiliPlus/app/theme/entities/theme_colors.dart';`
- Line 3: `import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';`
- Line 4: `import 'package:PiliPlus/app/theme/services/theme_service.dart';`

**Step 3: Remove darkThemeData field**

Edit `lib/app/app.dart`, remove line 15:
```dart
static ThemeData? darkThemeData;
```

**Step 4: Simplify build method**

Replace the entire `build` method (lines 21-47) with:

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp.router(
    title: Constants.appName,
    theme: ThemeData(useMaterial3: true),
    darkTheme: ThemeData(useMaterial3: true),
    themeMode: Pref.themeMode,
    localizationsDelegates: const [
      GlobalCupertinoLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    locale: const Locale("zh", "CN"),
    supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
    routerConfig: goRouter(),
    scrollBehavior: CustomScrollBehavior(
      PlatformUtils.isDesktop ? desktopDragDevices : mobileDragDevices,
    ),
  );
}
```

**Step 5: Verify syntax**

```bash
flutter analyze lib/app/app.dart
```

Expected: No errors specific to app.dart

**Step 6: Commit**

```bash
git add lib/app/app.dart
git commit -m "refactor(theme): simplify app.dart to use default theme

- Remove custom theme imports
- Remove darkThemeData field
- Use Flutter's default ThemeData with useMaterial3: true
- Preserve themeMode for light/dark/system switching

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 4: Remove Theme Settings from style_settings.dart

**Files:**
- Modify: `lib/features/setting/presentation/pages/models/style_settings.dart`

**Step 1: Remove theme-related imports**

Edit `style_settings.dart`, remove these lines:
- Line 23: `import 'package:PiliPlus/app/theme/entities/theme_colors.dart';`
- Line 24: `import 'package:PiliPlus/app/theme/entities/theme_type.dart';`
- Line 34: `import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';`

**Step 2: Remove darkVideoPage setting**

Remove lines 106-116:
```dart
SwitchModel(
  title: '视频播放页使用深色主题',
  leading: const Icon(Icons.dark_mode_outlined),
  setKey: SettingBoxKey.darkVideoPage,
  defaultVal: false,
  onChanged: (value) {
    if (value && MyApp.darkThemeData == null) {
      Get.forceAppUpdate();
    }
  },
),
```

**Step 3: Remove themeType setting**

Remove lines 247-252:
```dart
NormalModel(
  onTap: _showThemeTypeDialog,
  leading: const Icon(Icons.flashlight_on_outlined),
  title: '主题模式',
  getSubtitle: () => '当前模式：${Pref.themeType.desc}',
),
```

**Step 4: Remove isPureBlackTheme setting**

Remove lines 253-263:
```dart
SwitchModel(
  leading: const Icon(Icons.invert_colors),
  title: '纯黑主题',
  setKey: SettingBoxKey.isPureBlackTheme,
  defaultVal: false,
  onChanged: (value) {
    if (Get.isDarkMode || Pref.darkVideoPage) {
      Get.forceAppUpdate();
    }
  },
),
```

**Step 5: Remove color theme setting**

Remove lines 264-277:
```dart
NormalModel(
  onTap: (context, setState) => PageUtils.pushNamed(AppRoutes.colorSetting),
  leading: const Icon(Icons.color_lens_outlined),
  title: '应用主题',
  getTrailing: (theme) => SizedBox.square(
    dimension: 20,
    child: ColorPalette(
      colorScheme: colorThemeTypes[Pref.customColor].color
          .asColorSchemeSeed(Pref.schemeVariant, theme.brightness),
      selected: false,
      showBgColor: false,
    ),
  ),
),
```

**Step 6: Remove _showThemeTypeDialog function**

Remove lines 815-835:
```dart
Future<void> _showThemeTypeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<ThemeType>(
    context: context,
    builder: (context) => SelectDialog<ThemeType>(
      title: '主题模式',
      value: Pref.themeType,
      values: ThemeType.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    try {
      Get.find<MineController>().themeType.value = res;
    } catch (_) {}
    GStorage.settingRepository.setInt(SettingBoxKey.themeMode, res.index);
    Get.changeThemeMode(res.toThemeMode);
    setState();
  }
}
```

**Step 7: Verify syntax**

```bash
flutter analyze lib/features/setting/presentation/pages/models/style_settings.dart
```

Expected: No errors (may have unused import warnings for other removed imports)

**Step 8: Commit**

```bash
git add lib/features/setting/presentation/pages/models/style_settings.dart
git commit -m "refactor(theme): remove theme customization settings

Remove settings items:
- Video page dark theme toggle
- Theme mode selector (light/dark/system)
- Pure black theme toggle
- Custom color theme picker

Remove functions:
- _showThemeTypeDialog()

Remove imports:
- theme_colors.dart
- theme_type.dart
- theme_extensions.dart

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 5: Remove Theme Storage Keys

**Files:**
- Modify: `lib/core/storage/domain/keys/setting/ui_setting_keys.dart`

**Step 1: Remove customColor constant**

Edit `ui_setting_keys.dart`, remove line 129:
```dart
customColor = 'customColor',
```

**Step 2: Remove schemeVariant constant**

Edit `ui_setting_keys.dart`, remove line 48:
```dart
schemeVariant = 'schemeVariant',
```

**Step 3: Remove isPureBlackTheme constant**

Edit `ui_setting_keys.dart`, remove line 84:
```dart
isPureBlackTheme = 'isPureBlackTheme',
```

**Step 4: Remove darkVideoPage constant**

Edit `ui_setting_keys.dart`, remove line 94:
```dart
darkVideoPage = 'darkVideoPage',
```

**Step 5: Verify syntax**

```bash
flutter analyze lib/core/storage/domain/keys/setting/ui_setting_keys.dart
```

Expected: No errors

**Step 6: Commit**

```bash
git add lib/core/storage/domain/keys/setting/ui_setting_keys.dart
git commit -m "refactor(theme): remove unused theme storage keys

Remove keys:
- customColor (selected color theme index)
- schemeVariant (FlexSchemeVariant selection)
- isPureBlackTheme (pure black dark mode)
- darkVideoPage (video page dark mode)

Keep themeMode for light/dark/system switching.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 6: Remove Color Setting Route

**Files:**
- Modify: `lib/app/router/app_routes.dart` (or equivalent route config file)

**Step 1: Find route configuration file**

```bash
grep -r "colorSetting\|ColorSelectPage" lib/app/router/
```

Expected: Found in app_routes.dart or similar

**Step 2: Read route file**

```bash
cat lib/app/router/app_routes.dart
```

**Step 3: Remove colorSetting route definition**

Remove the route constant and path definition for color setting. Example (exact format may vary):

```dart
// Remove this line or similar:
static const String colorSetting = '/colorSetting';
```

**Step 4: Remove from go routes configuration**

If using go_router, remove the route from the GoRoute configuration.

**Step 5: Verify syntax**

```bash
flutter analyze lib/app/router/
```

Expected: No errors

**Step 6: Commit**

```bash
git add lib/app/router/
git commit -m "refactor(theme): remove color setting route

Remove route configuration for deleted ColorSelectPage.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 7: Fix Remaining Import Errors

**Step 1: Run full analysis**

```bash
flutter analyze
```

**Step 2: Fix any remaining import errors**

For each file with import errors:
1. Open the file
2. Remove imports to deleted theme files
3. Remove any usage of deleted types (ThemeType, colorThemeTypes, etc.)

Common fixes:
- Remove `import 'package:PiliPlus/app/theme/...'` lines
- Remove `ThemeType` references
- Remove `colorThemeTypes` references
- Remove `ThemeService` references
- Remove `asColorSchemeSeed` extension calls

**Step 3: Re-analyze until clean**

```bash
flutter analyze
```

Expected: No errors (warnings are acceptable if non-breaking)

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(theme): fix remaining import errors

Clean up imports and references to deleted theme files across codebase.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 8: Test Application Build

**Step 1: Clean build**

```bash
flutter clean
flutter pub get
```

**Step 2: Build application**

```bash
flutter build linux --debug
```

Or for android:
```bash
flutter build apk --debug
```

Expected: Build succeeds without errors

**Step 3: Check for runtime theme errors**

Look for any theme-related runtime errors in the build output.

**Step 4: Commit if any fixes needed**

If build required fixes:
```bash
git add -A
git commit -m "fix(theme): resolve build errors

Fix any compilation or build errors discovered during build.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 9: Manual Testing

**Step 1: Run application**

```bash
flutter run -d linux
```

Or for android:
```bash
flutter run -d android
```

**Step 2: Test theme mode switching**

Navigate to Settings → Style Settings and verify:
1. App launches successfully
2. Light/Dark/System mode still works (if still in settings)
3. No crashes when switching themes
4. All pages render with default Material 3 theme

**Step 3: Verify removed features are gone**

Confirm these are no longer accessible:
1. Color selection page
2. Theme variant selector
3. Pure black theme toggle
4. Dark video page toggle
5. Custom color picker

**Step 4: Test key pages**

Navigate to and verify:
1. Home page displays correctly
2. Video page displays correctly
3. Settings page displays correctly
4. All UI components render with default theme

**Step 5: Document any issues**

If issues found, create tasks to fix them.

**Step 6: Commit final fixes**

```bash
git add -A
git commit -m "fix(theme): address issues found during testing

Fix any UI or functional issues discovered during manual testing.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 10: Update Documentation

**Files:**
- Update: `docs/plans/2026-03-01-remove-theme-customization-design.md`

**Step 1: Mark design as implemented**

Add to design document:
```markdown
## Implementation Status

**Status:** ✅ Completed
**Date:** 2026-03-01
**Commits:** [List commit hashes]

All tasks completed successfully.
```

**Step 2: Update CLAUDE.md if needed**

If CLAUDE.md mentions theme customization, add note about simplification.

**Step 3: Commit documentation**

```bash
git add docs/
git commit -m "docs: mark theme removal as complete

Update design document with implementation status.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Verification Checklist

After completing all tasks, verify:

- [ ] `flutter analyze` passes with no errors
- [ ] `flutter build` succeeds
- [ ] App launches without crashes
- [ ] Light/Dark/System mode switching works
- [ ] All pages render with default Material 3 theme
- [ ] Removed features (color picker, variants, etc.) are inaccessible
- [ ] No runtime errors in logs
- [ ] Documentation updated

---

## Notes

**Storage Migration:**
- Old theme settings remain in storage but are ignored
- Users will see default blue theme on first run after this change
- No explicit migration needed - app gracefully handles missing keys

**Theme Mode Preservation:**
- `Pref.themeMode` is preserved for light/dark/system switching
- This is a core Flutter feature and should remain

**Future Enhancement:**
- If custom theming is needed, use `ColorScheme.fromSeed()`
- Consider Dynamic Color for Android 13+
- Use flutter_theme package for advanced theming needs

---

## Estimated Time

- Tasks 1-6: 30 minutes (file deletions and modifications)
- Task 7: 15-30 minutes (fixing import errors)
- Task 8: 10 minutes (build verification)
- Task 9: 20-30 minutes (manual testing)
- Task 10: 5 minutes (documentation)

**Total: ~1.5-2 hours**
