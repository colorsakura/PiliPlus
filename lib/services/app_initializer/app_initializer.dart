import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/common/widgets/scale_app.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/cache_manager.dart';
import 'package:PiliPlus/utils/calc_window_position.dart' as utils;
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart' hide calcWindowPosition;

/// 应用初始化管理器
///
/// 将启动流程分为三个阶段:
/// 1. 阻塞阶段 (blocking) - runApp 前必须完成
/// 2. 核心阶段 (core) - runApp 后异步执行
/// 3. 辅助阶段 (auxiliary) - 按需懒加载
class AppInitializer {
  // 私有构造函数
  AppInitializer._();

  // 阶段完成标志
  static bool _blockingPhaseCompleted = false;
  static bool _corePhaseCompleted = false;

  // 核心阶段完成信号
  static Completer<void>? _corePhaseCompleter;

  // 辅助服务初始化标志
  static bool _audioServiceInitialized = false;
  static bool _webViewInitialized = false;
  static bool _windowManagerInitialized = false;

  // WebView 环境实例 (桌面端)
  static WebViewEnvironment? webViewEnvironment;

  /// 是否完成阻塞阶段
  static bool get blockingPhaseCompleted => _blockingPhaseCompleted;

  /// 是否完成核心阶段
  static bool get corePhaseCompleted => _corePhaseCompleted;

  /// 阻塞阶段 - 必须在 runApp 前完成
  ///
  /// 只初始化显示 UI 必需的组件:
  /// - Flutter 框架绑定
  /// - MediaKit
  /// - 应用路径
  /// - 完整存储初始化 (所有 Box，确保服务可用)
  /// - GetX 服务注册 (确保在 runApp 前可用)
  static Future<void> blockingPhase() async {
    if (_blockingPhaseCompleted) {
      debugPrint('AppInitializer: blockingPhase already completed');
      return;
    }

    final stopwatch = Stopwatch()..start();
    debugPrint('🚀 AppInitializer: Starting blocking phase');

    try {
      await _initFlutterBindings();
      debugPrint('  ✓ Flutter bindings initialized');

      await _initAppPaths();
      debugPrint('  ✓ App paths initialized');

      // 完整存储初始化（因为 AccountService.onInit 需要 userInfo）
      await _initFullStorage();
      debugPrint('  ✓ Full storage initialized');

      await _initGetXServices();
      debugPrint('  ✓ GetX services registered');

      await _initHttpClient();
      debugPrint('  ✓ HTTP client initialized');

      _blockingPhaseCompleted = true;
      stopwatch.stop();
      debugPrint(
        '✅ AppInitializer: Blocking phase completed in ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stack) {
      debugPrint('❌ AppInitializer: Blocking phase failed: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// 核心阶段 - 在 runApp 后异步执行
  ///
  /// 初始化应用核心功能:
  /// - 下载路径初始化
  /// - HTTP 客户端
  /// - 平台设置 (屏幕方向、系统 UI)
  static Future<void> corePhase() async {
    if (_corePhaseCompleted) {
      debugPrint('AppInitializer: corePhase already completed');
      return;
    }

    final stopwatch = Stopwatch()..start();
    debugPrint('⚙️ AppInitializer: Starting core phase');

    // 创建完成信号 (在方法开始就创建,允许 await)
    _corePhaseCompleter ??= Completer<void>();

    try {
      await _initDownloadPaths();
      debugPrint('  ✓ Download paths initialized');

      await _setupPlatform();
      debugPrint('  ✓ Platform settings configured');

      CacheManager.autoClearCache();
      debugPrint('  ✓ Cache cleared');

      _corePhaseCompleted = true;
      _corePhaseCompleter!.complete();
      stopwatch.stop();
      debugPrint(
        '✅ AppInitializer: Core phase completed in ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stack) {
      debugPrint('❌ AppInitializer: Core phase failed: $e');
      debugPrint('Stack: $stack');
      // 核心阶段失败不应阻止应用运行
      _corePhaseCompleter!.completeError(e, stack);
      rethrow;
    }
  }

  /// 确保核心阶段完成
  ///
  /// 供依赖核心服务的代码调用
  static Future<void> ensureCoreReady() async {
    if (_corePhaseCompleted) return;
    debugPrint('⏳ AppInitializer: Waiting for core phase to complete');
    await _corePhaseCompleter?.future;
    debugPrint('✓ AppInitializer: Core phase ready');
  }

  /// 辅助阶段: 初始化音频服务
  static Future<void> initAudioService() async {
    await ensureCoreReady();
    if (_audioServiceInitialized) {
      debugPrint('⏭️  AppInitializer: Audio service already initialized');
      return;
    }

    debugPrint('🎵 AppInitializer: Initializing audio service');
    try {
      await setupServiceLocator();
      _audioServiceInitialized = true;
      debugPrint('✅ AppInitializer: Audio service initialized');
    } catch (e) {
      debugPrint('❌ AppInitializer: Audio service initialization failed: $e');
    }
  }

  /// 辅助阶段: 初始化 WebView (仅桌面)
  ///
  /// 注意: flutter_inappwebview 不支持 Linux 平台
  /// 支持的平台: Windows, macOS, Android, iOS, Web
  static Future<void> initWebView() async {
    // Linux 不支持 flutter_inappwebview
    if (!PlatformUtils.isDesktop || Platform.isLinux || _webViewInitialized) {
      return;
    }

    await ensureCoreReady();
    debugPrint('🌐 AppInitializer: Initializing WebView');

    try {
      if (await WebViewEnvironment.getAvailableVersion() != null) {
        final appSupportDirPath =
            (await _getApplicationSupportDirectory()).path;
        webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(
            userDataFolder: path.join(
              appSupportDirPath,
              'flutter_inappwebview',
            ),
          ),
        );
      }
      _webViewInitialized = true;
      debugPrint('✅ AppInitializer: WebView initialized');
    } catch (e) {
      debugPrint('❌ AppInitializer: WebView initialization failed: $e');
    }
  }

  /// 辅助阶段: 初始化窗口管理器 (仅桌面)
  static Future<void> initWindowManager() async {
    if (!PlatformUtils.isDesktop || _windowManagerInitialized) {
      return;
    }

    await ensureCoreReady();
    debugPrint('🪟 AppInitializer: Initializing window manager');

    try {
      await _initWindowManagerInternal();
      _windowManagerInitialized = true;
      debugPrint('✅ AppInitializer: Window manager initialized');
    } catch (e) {
      debugPrint('❌ AppInitializer: Window manager initialization failed: $e');
    }
  }

  // ============ 私有辅助方法 ============

  static Future<void> _initFlutterBindings() async {
    ScaledWidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
  }

  static Future<void> _initAppPaths() async {
    appSupportDirPath = (await getApplicationSupportDirectory()).path;
  }

  static Future<void> _initCriticalStorage() async {
    try {
      await GStorage.initCritical();
      // 设置 UI 缩放
      ScaledWidgetsFlutterBinding.instance.scaleFactor = Pref.uiScale;
    } catch (e) {
      await Utils.copyText(e.toString());
      if (kDebugMode) debugPrint('GStorage initCritical error: $e');
      exit(0);
    }
  }

  static Future<void> _initFullStorage() async {
    // 完整存储初始化
    // 先初始化关键 setting Box（用于读取 UI 缩放等设置）
    await _initCriticalStorage();
    // 再初始化其他 Box
    await GStorage.init();
  }

  static Future<void> _initDownloadPaths() async {
    await Future.wait([
      _initDownPath(),
      _initTmpPath(),
    ]);
  }

  /// 初始化下载路径 - 从 main.dart 迁移
  static Future<void> _initDownPath() async {
    if (PlatformUtils.isDesktop) {
      final customDownPath = Pref.downloadPath;
      if (customDownPath != null && customDownPath.isNotEmpty) {
        try {
          final dir = Directory(customDownPath);
          if (!dir.existsSync()) {
            await dir.create(recursive: true);
          }
          downloadPath = customDownPath;
        } catch (e) {
          downloadPath = defDownloadPath;
          await GStorage.setting.delete(SettingBoxKey.downloadPath);
          if (kDebugMode) {
            debugPrint('download path error: $e');
          }
        }
      } else {
        downloadPath = defDownloadPath;
      }
    } else if (Platform.isAndroid) {
      final externalStorageDirPath =
          (await getExternalStorageDirectory())?.path;
      downloadPath = externalStorageDirPath != null
          ? path.join(externalStorageDirPath, PathUtils.downloadDir)
          : defDownloadPath;
    } else {
      downloadPath = defDownloadPath;
    }
  }

  /// 初始化临时目录路径 - 从 main.dart 迁移
  static Future<void> _initTmpPath() async {
    tmpDirPath = (await getTemporaryDirectory()).path;
  }

  static Future<void> _initHttpClient() async {
    HttpOverrides.global = _CustomHttpOverrides();
    Request();
    Request.setCookie();
    RequestUtils.syncHistoryStatus();
  }

  // ignore: unnecessary_async
  static Future<void> _initGetXServices() async {
    Get
      ..lazyPut(AccountService.new)
      ..lazyPut(DownloadService.new);
  }

  static Future<void> _setupPlatform() async {
    if (PlatformUtils.isMobile) {
      await Future.wait([
        SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.portraitUp,
            if (Pref.horizontalScreen) ...[
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
          ],
        ),
        _setupMobileSpecific(),
      ]);
    } else if (Platform.isWindows) {
      // WebView 初始化延迟到辅助阶段
    }
  }

  /// 移动端特定设置
  static Future<void> _setupMobileSpecific() async {
    PiliScheme.init();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    if (Platform.isAndroid) {
      FlutterDisplayMode.supported.then((mode) {
        final String? storageDisplay = GStorage.setting.get(
          SettingBoxKey.displayMode,
        );
        DisplayMode? displayMode;
        if (storageDisplay != null) {
          displayMode = mode.firstWhereOrNull(
            (e) => e.toString() == storageDisplay,
          );
        }
        FlutterDisplayMode.setPreferredMode(displayMode ?? DisplayMode.auto);
      });
    }
  }

  /// 初始化窗口管理器 (桌面端)
  static Future<void> _initWindowManagerInternal() async {
    await windowManager.ensureInitialized();

    final windowOptions = WindowOptions(
      minimumSize: const Size(400, 720),
      skipTaskbar: false,
      titleBarStyle: Pref.showWindowTitleBar
          ? TitleBarStyle.normal
          : TitleBarStyle.hidden,
      title: Constants.appName,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      final windowSize = Pref.windowSize;
      await windowManager.setBounds(
        await utils.calcWindowPosition(windowSize) & windowSize,
      );
      if (Pref.isWindowMaximized) await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static Future<Directory> _getApplicationSupportDirectory() {
    return getApplicationSupportDirectory();
  }
}

/// Custom HTTP overrides for development and testing
class _CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    if (kDebugMode || Pref.badCertificateCallback) {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    return client;
  }
}
