import 'package:PiliPlus/app/router/app_router.dart';
import 'package:PiliPlus/app/theme/entities/theme_colors.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:PiliPlus/app/theme/services/theme_service.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/shared/widgets/back_detector.dart';
import 'package:PiliPlus/shared/widgets/scroll_behavior.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/toast_utils.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ColorScheme? _light, _dark;

  static ThemeData? darkThemeData;

  /// 全局导航Key，用于访问导航状态
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static void _onBack() {
    if (ToastUtils.checkExist()) {
      ToastUtils.dismiss();
      return;
    }

    // Use go_router for back navigation
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamicColor = Pref.dynamicColor && _light != null && _dark != null;
    late final brandColor = colorThemeTypes[Pref.customColor].color;
    late final variant = Pref.schemeVariant;

    return MaterialApp.router(
      title: Constants.appName,
      theme: ThemeService.getThemeData(
        colorScheme: dynamicColor
            ? _light!
            : brandColor.asColorSchemeSeed(variant, .light),
        isDynamic: dynamicColor,
      ),
      darkTheme: ThemeService.getThemeData(
        isDark: true,
        colorScheme: dynamicColor
            ? _dark!
            : brandColor.asColorSchemeSeed(variant, .dark),
        isDynamic: dynamicColor,
      ),
      themeMode: Pref.themeMode,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: const Locale("zh", "CN"),
      supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
      routerConfig: goRouter(),
      builder: _builder,
      scrollBehavior: CustomScrollBehavior(
        PlatformUtils.isDesktop ? desktopDragDevices : mobileDragDevices,
      ),
    );
  }

  static Widget _builder(BuildContext context, Widget? child) {
    var uiScale = Pref.uiScale;

    // 确保 uiScale 有效（> 0），否则使用默认值 1.0
    // uiScale = 0.0 会导致除以零错误，产生无限大的尺寸
    if (uiScale <= 0.0 || !uiScale.isFinite) {
      uiScale = 1.0;
    }

    final mediaQuery = MediaQuery.of(context);
    final defaultTextScale = Pref.defaultTextScale;

    // 确保 textScale 有效（> 0），否则使用默认值 1.0
    // textScale = 0.0 会导致文字不显示（缩放为 0）
    final effectiveTextScale = (defaultTextScale > 0 && defaultTextScale.isFinite)
        ? defaultTextScale
        : 1.0;

    final textScaler = TextScaler.linear(effectiveTextScale);

    // 检查 MediaQuery 的值是否有效（非 NaN 且非无限大）
    final isValidSize = mediaQuery.size.width.isFinite &&
        mediaQuery.size.height.isFinite &&
        mediaQuery.size.width > 0 &&
        mediaQuery.size.height > 0;
    final isValidViewPadding = mediaQuery.viewPadding.top.isFinite &&
        mediaQuery.viewPadding.bottom.isFinite &&
        mediaQuery.viewPadding.left.isFinite &&
        mediaQuery.viewPadding.right.isFinite;

    // 如果 viewPadding 无效，使用安全的默认值
    final safeViewPadding = isValidViewPadding
        ? mediaQuery.viewPadding
        : EdgeInsets.zero;

    // 确保 size 是有效的
    final safeSize = isValidSize ? mediaQuery.size : const Size(1280, 720);

    if (uiScale != 1.0 && isValidSize && isValidViewPadding) {
      child = MediaQuery(
        data: mediaQuery.copyWith(
          textScaler: textScaler,
          size: mediaQuery.size / uiScale,
          padding: mediaQuery.padding / uiScale,
          viewInsets: mediaQuery.viewInsets / uiScale,
          viewPadding: mediaQuery.viewPadding / uiScale,
          devicePixelRatio: mediaQuery.devicePixelRatio * uiScale,
        ),
        child: child!,
      );
    } else {
      // 使用安全的默认值创建 MediaQuery
      child = MediaQuery(
        data: MediaQueryData(
          size: safeSize,
          devicePixelRatio: mediaQuery.devicePixelRatio,
          textScaler: textScaler,
          platformBrightness: mediaQuery.platformBrightness,
          viewPadding: safeViewPadding,
          padding: mediaQuery.padding,
          viewInsets: mediaQuery.viewInsets,
          systemGestureInsets: mediaQuery.systemGestureInsets,
          alwaysUse24HourFormat: mediaQuery.alwaysUse24HourFormat,
          disableAnimations: mediaQuery.disableAnimations,
          invertColors: mediaQuery.invertColors,
          accessibleNavigation: mediaQuery.accessibleNavigation,
          boldText: mediaQuery.boldText,
          highContrast: mediaQuery.highContrast,
        ),
        child: child!,
      );
    }
    if (PlatformUtils.isDesktop) {
      return BackDetector(
        onBack: _onBack,
        child: child,
      );
    }
    return child;
  }

  /// from [DynamicColorBuilderState.initPlatformState]
  static Future<bool> initPlatformState() async {
    if (_light != null || _dark != null) return true;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();

      if (corePalette != null) {
        if (kDebugMode) {
          AppLog.fine('Dynamic color: Core palette detected', name: 'App');
        }
        _light = corePalette.toColorScheme();
        _dark = corePalette.toColorScheme(brightness: Brightness.dark);
        return true;
      }
    } on PlatformException {
      if (kDebugMode) {
        AppLog.fine(
          'Dynamic color: Failed to obtain core palette',
          name: 'App',
        );
      }
    }

    try {
      final Color? accentColor = await DynamicColorPlugin.getAccentColor();

      if (accentColor != null) {
        if (kDebugMode) {
          AppLog.fine('Dynamic color: Accent color detected', name: 'App');
        }
        final variant = Pref.schemeVariant;
        _light = accentColor.asColorSchemeSeed(variant, .light);
        _dark = accentColor.asColorSchemeSeed(variant, .dark);
        return true;
      }
    } on PlatformException {
      if (kDebugMode) {
        AppLog.fine(
          'Dynamic color: Failed to obtain accent color',
          name: 'App',
        );
      }
    }
    if (kDebugMode) {
      AppLog.fine('Dynamic color: Not detected on this device', name: 'App');
    }
    await GStorage.settingRepository.setBool(SettingBoxKey.dynamicColor, false);
    return false;
  }
}
