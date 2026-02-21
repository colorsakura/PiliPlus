import 'package:PiliPlus/app/app.dart';
import 'package:PiliPlus/services/app_initializer/app_initializer.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() async {
  // 阻塞阶段 - 必须在 runApp 前完成
  await AppInitializer.blockingPhase();

  // SmartDialog 配置 - 在 runApp 前设置
  SmartDialog.config.toast = SmartConfigToast(
    displayType: SmartToastType.onlyRefresh,
  );

  // 动态颜色初始化 (如果启用)
  if (Pref.dynamicColor) {
    await MyApp.initPlatformState();
  }

  // 启动应用
  runApp(const ProviderScope(child: MyApp()));

  // 核心阶段 - runApp 后异步执行
  await AppInitializer.corePhase();

  // 辅助阶段 - 按需初始化
  if (PlatformUtils.isDesktop) {
    await Future.wait([
      AppInitializer.initWebView(),
      AppInitializer.initWindowManager(),
    ]);
  }
}
