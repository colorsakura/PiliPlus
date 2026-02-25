import 'package:PiliPlus/features/about/domain/entities/app_info.dart';
import 'package:PiliPlus/features/about/domain/entities/cache_info.dart';
import 'package:PiliPlus/features/about/domain/usecases/clear_cache.dart';
import 'package:PiliPlus/features/about/domain/usecases/get_app_info.dart';
import 'package:PiliPlus/features/about/domain/usecases/get_cache_info.dart';
import 'package:PiliPlus/features/about/presentation/providers/about_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// About页面状态
class AboutState {
  /// 应用信息
  final AppInfoEntity? appInfo;

  /// 缓存信息
  final CacheInfoEntity? cacheInfo;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? errorMessage;

  const AboutState({
    this.appInfo,
    this.cacheInfo,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 复制并更新
  AboutState copyWith({
    AppInfoEntity? appInfo,
    CacheInfoEntity? cacheInfo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AboutState(
      appInfo: appInfo ?? this.appInfo,
      cacheInfo: cacheInfo ?? this.cacheInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// About页面Controller
class AboutController extends Notifier<AboutState> {
  late final GetAppInfoUseCase _getAppInfoUseCase;
  late final GetCacheInfoUseCase _getCacheInfoUseCase;
  late final ClearCacheUseCase _clearCacheUseCase;

  @override
  AboutState build() {
    _getAppInfoUseCase = ref.read(getAppInfoUseCaseProvider);
    _getCacheInfoUseCase = ref.read(getCacheInfoUseCaseProvider);
    _clearCacheUseCase = ref.read(clearCacheUseCaseProvider);

    return const AboutState();
  }

  /// 初始化
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final appInfo = await _getAppInfoUseCase();
      final cacheInfo = await _getCacheInfoUseCase();
      state = state.copyWith(
        appInfo: appInfo,
        cacheInfo: cacheInfo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 刷新缓存信息
  Future<void> refreshCacheInfo() async {
    try {
      final cacheInfo = await _getCacheInfoUseCase();
      state = state.copyWith(cacheInfo: cacheInfo);
    } catch (e) {
      // 忽略错误，保持原有状态
    }
  }

  /// 清除缓存
  Future<bool> clearCache() async {
    try {
      final success = await _clearCacheUseCase();
      if (success) {
        await refreshCacheInfo();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

/// AboutController Provider
final aboutControllerProvider = NotifierProvider<AboutController, AboutState>(
  AboutController.new,
);
