import 'package:PiliPlus/app/app.dart';
import 'package:PiliPlus/services/app_initializer/app_initializer.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // 阻塞阶段 - 必须在 runApp 前完成
  await AppInitializer.blockingPhase();

  // 启动应用
  runApp(const ProviderScope(child: MyApp()));

  // 核心阶段 - runApp 后异步执行
  await AppInitializer.corePhase();

  // 辅助阶段 - 按需初始化
  if (PlatformUtils.isDesktop) {
    await AppInitializer.initWebView();
  }
}
