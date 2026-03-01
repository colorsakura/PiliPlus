# Remove Theme Customization - Design Document

**Date:** 2026-03-01
**Status:** Approved
**Author:** Claude Code

## Overview

Remove all custom theme infrastructure from the PiliPlus app and use Flutter's default Material 3 theme, while preserving basic light/dark/system mode switching capabilities.

## Motivation

Simplify the codebase by removing complex theme customization features (19 color options, scheme variants, pure black theme) and rely on Flutter's well-designed default theme system.

## Approach

**Option Chosen:** Use Flutter's default theme (Material 3 defaults)

This provides:
- Simpler codebase (~500 lines removed)
- No theme synchronization issues
- Faster app startup (no theme computation)
- Consistency with Flutter ecosystem

## Design Details

### Files to Delete

```
lib/app/theme/
├── entities/
│   ├── theme_type.dart         # ThemeType enum
│   └── theme_colors.dart       # 19 color theme definitions
├── services/
│   └── theme_service.dart      # ThemeService class
└── extensions/
    └── theme_extensions.dart   # Extension exports

lib/features/setting/presentation/pages/pages/
└── color_select.dart           # Color selection page
```

### Files to Modify

#### 1. `lib/app/app.dart`

**Changes:**
- Remove imports:
  - `package:PiliPlus/app/theme/entities/theme_colors.dart`
  - `package:PiliPlus/app/theme/extensions/theme_extensions.dart`
  - `package:PiliPlus/app/theme/services/theme_service.dart`
- Remove `static ThemeData? darkThemeData` field
- Replace theme data generation with Flutter defaults:
  ```dart
  theme: ThemeData(useMaterial3: true),
  darkTheme: ThemeData(useMaterial3: true),
  themeMode: Pref.themeMode, // Keep for light/dark/system
  ```
- Remove custom brand color logic

#### 2. `lib/features/setting/presentation/pages/models/style_settings.dart`

**Remove these settings items:**
- Lines 106-116: "视频播放页使用深色主题" (darkVideoPage)
- Lines 247-252: "主题模式" (themeType dialog)
- Lines 253-263: "纯黑主题" (isPureBlackTheme)
- Lines 264-277: "应用主题" (color picker)

**Remove functions:**
- `_showThemeTypeDialog()` (lines 815-835)

**Remove imports:**
- `package:PiliPlus/app/theme/entities/theme_colors.dart`
- `package:PiliPlus/app/theme/entities/theme_type.dart`
- `package:PiliPlus/app/theme/extensions/theme_extensions.dart`

#### 3. `lib/core/storage/domain/keys/setting/ui_setting_keys.dart`

**Remove constants:**
- `customColor` (line 129)
- `schemeVariant` (line 48)
- `isPureBlackTheme` (line 84)
- `darkVideoPage` (line 94)

**Keep:**
- `themeMode` (line 127) - for light/dark/system switching

### Storage Cleanup

**Remove storage keys:**
- `SettingBoxKey.customColor`
- `SettingBoxKey.schemeVariant`
- `SettingBoxKey.isPureBlackTheme`
- `SettingBoxKey.darkVideoPage`

**Storage migration (optional):**
- These keys can remain in storage with old values (ignored)
- Or explicitly cleared via app migration logic

### Router Changes

**Remove route:**
- `AppRoutes.colorSetting` → `ColorSelectPage`

**File:** `lib/app/router/app_router.dart` and related route configuration

### Provider Changes

**Remove providers in `color_select.dart`:**
- `currentColorProvider`
- `themeTypeProvider`

These are only used in the deleted page.

## Impact Analysis

### Breaking Changes

**User Impact:**
- ✗ Custom color selection lost (19 color options)
- ✗ Scheme variant selection lost (tonal, content, etc.)
- ✗ Pure black theme option removed
- ✗ Dark video page option removed
- ✓ Light/Dark/System mode switching **preserved**

**Data Migration:**
- Old theme settings remain in storage but are ignored
- No migration needed - app will use defaults

### Preserved Functionality

1. **Theme Mode Switching:**
   - Light mode
   - Dark mode
   - System (follow OS) mode
   - Controlled via `Pref.themeMode`

2. **Material 3 Features:**
   - All Material 3 components work normally
   - Dynamic color (if Android 13+)
   - Default Material 3 color schemes

### Benefits

1. **Code Simplification:**
   - ~500 lines of theme code removed
   - 5 files deleted
   - Simpler app.dart logic

2. **Performance:**
   - Faster app startup (no theme computation)
   - Smaller app bundle

3. **Maintainability:**
   - No custom theme sync issues
   - Leverages Flutter's well-tested defaults
   - Easier to upgrade Flutter versions

## Testing Checklist

- [ ] App builds successfully
- [ ] Light/Dark/System mode switching works
- [ ] All pages render correctly with default theme
- [ ] Settings page loads without errors
- [ ] No runtime errors related to theme
- [ ] Navigation to removed color setting page is removed from all entry points

## Alternatives Considered

### B. Keep current theme structure with hardcoded colors
**Rejected:** More complex than needed for this requirement

### C. Minimal custom theme
**Rejected:** Still requires maintaining custom theme code

## Implementation Order

1. Delete theme directory and files
2. Modify app.dart to use default theme
3. Remove theme settings from style_settings.dart
4. Remove storage keys
5. Remove route configuration
6. Test and verify

## Future Considerations

If custom theming is needed in the future, consider:
- Using Flutter's ColorScheme.fromSeed() for simpler customization
- Leveraging Dynamic Color (Android 13+) for system-based theming
- Using flutter_theme package for more flexible theming
