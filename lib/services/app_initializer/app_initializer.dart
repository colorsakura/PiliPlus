import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/core/storage/database/database_manager.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/cache_manager.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/log.dart';
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
      AppLog.info('Blocking phase already completed', name: 'AppInitializer');
      return;
    }

    final stopwatch = Stopwatch()..start();
    AppLog.info('Starting blocking phase', name: 'AppInitializer');

    try {
      await _initFlutterBindings();
      AppLog.fine('Flutter bindings initialized', name: 'AppInitializer');

      await _initAppPaths();
      AppLog.fine('App paths initialized', name: 'AppInitializer');

      // 完整存储初始化（因为 AccountService.onInit 需要 userInfo）
      await _initFullStorage();
      AppLog.fine('Full storage initialized', name: 'AppInitializer');

      await _initGetXServices();
      AppLog.fine('GetX services registered', name: 'AppInitializer');

      _blockingPhaseCompleted = true;
      stopwatch.stop();
      AppLog.info(
        'Blocking phase completed in ${stopwatch.elapsedMilliseconds}ms',
        name: 'AppInitializer',
      );
    } catch (e, stack) {
      AppLog.severe(
        'Blocking phase failed: $e',
        name: 'AppInitializer',
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// 核心阶段 - 在 runApp 后异步执行
  ///
  /// 初始化应用核心功能:
  /// - 下载路径初始化
  /// - 数据库初始化
  /// - HTTP 客户端
  /// - 平台设置 (屏幕方向、系统 UI)
  static Future<void> corePhase() async {
    if (_corePhaseCompleted) {
      AppLog.info('Core phase already completed', name: 'AppInitializer');
      return;
    }

    final stopwatch = Stopwatch()..start();
    AppLog.info('Starting core phase', name: 'AppInitializer');

    // 创建完成信号 (在方法开始就创建,允许 await)
    _corePhaseCompleter ??= Completer<void>();

    try {
      await _initDownloadPaths();
      AppLog.fine('Download paths initialized', name: 'AppInitializer');

      await _initDatabase();
      AppLog.fine('Database initialized', name: 'AppInitializer');

      await _setupPlatform();
      AppLog.fine('Platform settings configured', name: 'AppInitializer');

      CacheManager.autoClearCache();
      AppLog.fine('Cache cleared', name: 'AppInitializer');

      await _initHttpClient();
      AppLog.fine('HTTP client initialized', name: 'AppInitializer');

      _corePhaseCompleted = true;
      _corePhaseCompleter!.complete();
      stopwatch.stop();
      AppLog.info(
        'Core phase completed in ${stopwatch.elapsedMilliseconds}ms',
        name: 'AppInitializer',
      );
    } catch (e, stack) {
      AppLog.severe(
        'Core phase failed: $e',
        name: 'AppInitializer',
        stackTrace: stack,
      );
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
    AppLog.fine('Waiting for core phase to complete', name: 'AppInitializer');
    await _corePhaseCompleter?.future;
    AppLog.fine('Core phase ready', name: 'AppInitializer');
  }

  /// 辅助阶段: 初始化音频服务
  static Future<void> initAudioService() async {
    await ensureCoreReady();
    if (_audioServiceInitialized) {
      AppLog.info('Audio service already initialized', name: 'AppInitializer');
      return;
    }

    AppLog.info('Initializing audio service', name: 'AppInitializer');
    try {
      await setupServiceLocator();
      _audioServiceInitialized = true;
      AppLog.info('Audio service initialized', name: 'AppInitializer');
    } catch (e) {
      AppLog.severe(
        'Audio service initialization failed: $e',
        name: 'AppInitializer',
      );
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
    AppLog.info('Initializing WebView', name: 'AppInitializer');

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
      AppLog.info('WebView initialized', name: 'AppInitializer');
    } catch (e) {
      AppLog.severe(
        'WebView initialization failed: $e',
        name: 'AppInitializer',
      );
    }
  }

  // ============ 私有辅助方法 ============

  static Future<void> _initFlutterBindings() async {
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
  }

  static Future<void> _initAppPaths() async {
    appSupportDirPath = (await getApplicationSupportDirectory()).path;
  }

  static Future<void> _initCriticalStorage() async {
    try {
      await GStorage.initCritical();
    } catch (e) {
      await Utils.copyText(e.toString());
      AppLog.severe('GStorage initCritical error: $e', name: 'AppInitializer');
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

  static Future<void> _initDatabase() async {
    try {
      await DatabaseManager.init();
      AppLog.info('DatabaseManager initialized', name: 'AppInitializer');
    } catch (e) {
      AppLog.severe(
        'Database initialization failed: $e',
        name: 'AppInitializer',
      );
      // 数据库初始化失败不应阻止应用运行
    }
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
          await GStorage.settingRepository.remove(SettingBoxKey.downloadPath);
          if (kDebugMode) {
            AppLog.fine('Download path error: $e', name: 'AppInitializer');
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
        final String? storageDisplay = GStorage.settingRepository.getString(
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
