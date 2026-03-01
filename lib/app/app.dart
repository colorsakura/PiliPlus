import 'package:PiliPlus/app/router/app_router.dart';
import 'package:PiliPlus/app/theme/entities/theme_colors.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:PiliPlus/app/theme/services/theme_service.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/shared/widgets/scroll_behavior.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData? darkThemeData;

  /// 全局导航Key，用于访问导航状态
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    late final brandColor = colorThemeTypes[Pref.customColor].color;
    late final variant = Pref.schemeVariant;

    return MaterialApp.router(
      title: Constants.appName,
      theme: ThemeService.getThemeData(
        colorScheme: brandColor.asColorSchemeSeed(variant, Brightness.light),
      ),
      darkTheme: ThemeService.getThemeData(
        isDark: true,
        colorScheme: brandColor.asColorSchemeSeed(variant, Brightness.dark),
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
      scrollBehavior: CustomScrollBehavior(
        PlatformUtils.isDesktop ? desktopDragDevices : mobileDragDevices,
      ),
    );
  }
}
