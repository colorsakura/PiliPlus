import 'package:PiliPlus/app/router/go_router_config.dart';
import 'package:PiliPlus/app/theme/entities/theme_colors.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:PiliPlus/app/theme/services/theme_service.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/shared/widgets/back_detector.dart';
import 'package:PiliPlus/shared/widgets/custom_toast.dart';
import 'package:PiliPlus/shared/widgets/scroll_behavior.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ColorScheme? _light, _dark;

  static ThemeData? darkThemeData;

  static void _onBack() {
    if (SmartDialog.checkExist()) {
      SmartDialog.dismiss();
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
      builder: FlutterSmartDialog.init(
        toastBuilder: (msg) => CustomToast(msg: msg),
        loadingBuilder: (msg) => LoadingWidget(msg: msg),
        builder: _builder,
      ),
      scrollBehavior: CustomScrollBehavior(
        PlatformUtils.isDesktop ? desktopDragDevices : mobileDragDevices,
      ),
    );
  }

  static Widget _builder(BuildContext context, Widget? child) {
    final uiScale = Pref.uiScale;
    final mediaQuery = MediaQuery.of(context);
    final textScaler = TextScaler.linear(Pref.defaultTextScale);
    if (uiScale != 1.0) {
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
      child = MediaQuery(
        data: mediaQuery.copyWith(textScaler: textScaler),
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
    GStorage.setting.put(SettingBoxKey.dynamicColor, false);
    return false;
  }
}
