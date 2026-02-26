import 'package:PiliPlus/core/image_cache/image_preloader.dart';
import 'package:PiliPlus/core/storage/database/sqlite3_storage_provider.dart';
import 'package:PiliPlus/features/home_rcmd/domain/entities/persisted_recommendation.dart';
import 'package:PiliPlus/features/home_rcmd/domain/entities/recommendation_result.dart';
import 'package:PiliPlus/features/home_rcmd/domain/entities/video_recommendation.dart';
import 'package:PiliPlus/features/home_rcmd/domain/usecases/fetch_recommendations.dart';
import 'package:PiliPlus/features/home_rcmd/domain/usecases/get_recommendation_settings.dart';
import 'package:PiliPlus/features/home_rcmd/presentation/providers/recommendation_providers.dart';
import 'package:PiliPlus/models/home/rcmd/result.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 推荐状态
class RecommendationState {
  /// 推荐结果
  final RecommendationResult? result;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? errorMessage;

  /// 上次看到的位置索引
  final int? lastRefreshAt;

  /// 是否显示缓存数据（离线模式）
  final bool isOffline;

  const RecommendationState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
    this.lastRefreshAt,
    this.isOffline = false,
  });

  /// 复制并更新
  RecommendationState copyWith({
    RecommendationResult? result,
    bool? isLoading,
    String? errorMessage,
    int? lastRefreshAt,
    bool? isOffline,
  }) {
    return RecommendationState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  /// 获取视频列表
  List<dynamic> get displayList {
    if (result == null || result!.videos.isEmpty) {
      return [];
    }
    return result!.videos.map((v) => v.video).toList();
  }
}

/// 推荐Controller - 使用 RiverPod 的离线优先模式
class RecommendationController extends Notifier<RecommendationState> {
  late final FetchRecommendationsUseCase _fetchUseCase;
  late final GetRecommendationSettingsUseCase _settingsUseCase;

  int _currentFreshIdx = 0;
  bool _isEnd = false;
  bool _initialized = false;

  @override
  RecommendationState build() {
    _fetchUseCase = ref.read(fetchRecommendationsUseCaseProvider);
    _settingsUseCase = ref.read(getRecommendationSettingsUseCaseProvider);

    // 启用离线持久化
    persist(
      ref.watch(sqlite3StorageProvider.future),
      key: 'home_recommendations',
      decode: (data) {
        AppLog.info('Decoding persisted data', name: 'Recommendation');
        if (data == null || data is! Map) {
          AppLog.fine('No persisted data found, using initial state', name: 'Recommendation');
          // Return an empty state instead of throwing exception
          return const RecommendationState();
        }
        try {
          final json = data as Map<String, dynamic>;
          final persistedData = PersistedRecommendation.fromJson(json);
          AppLog.info(
            'Loaded ${persistedData.videos.length} persisted items',
            name: 'Recommendation',
          );
          return RecommendationState(
            result: RecommendationResult(
              videos: _convertPersistedVideos(persistedData.videos),
              hasMore: persistedData.hasMore,
              currentPage: persistedData.currentPage,
            ),
            isLoading: false,
            isOffline: true,
          );
        } catch (e) {
          AppLog.warning('Failed to decode persisted data: $e, using initial state', name: 'Recommendation');
          // Return an empty state instead of throwing
          return const RecommendationState();
        }
      },
      encode: (state) {
        // 只在有数据且不是加载状态时才保存
        AppLog.fine('encode called: result=${state.result != null}, videos=${state.result?.videos.length ?? 0}, isLoading=${state.isLoading}', name: 'Recommendation');

        if (state.result == null || state.result!.videos.isEmpty || state.isLoading) {
          AppLog.fine('Skipping persist: no valid data', name: 'Recommendation');
          return null;
        }

        final videos = state.result!.videos.map((v) => _videoToJson(v)).toList();
        AppLog.info('Persisting ${videos.length} items (hasData=true)', name: 'Recommendation');
        return PersistedRecommendation(
          videos: videos,
          hasMore: state.result!.hasMore,
          currentPage: state.result!.currentPage,
          cachedAt: DateTime.now().millisecondsSinceEpoch,
        ).toJson();
      },
      options: const StorageOptions(
        cacheTime: StorageCacheTime(Duration(hours: 1)),
      ),
    );

    return const RecommendationState(isLoading: true);
  }

  /// 将持久化的视频数据转换为 VideoRecommendation
  List<VideoRecommendation> _convertPersistedVideos(
    List<Map<String, dynamic>> videos,
  ) {
    return videos.map((json) {
      final videoItem = RecVideoItemAppModel.fromJson(json);
      return VideoRecommendation(
        video: videoItem,
        rcmdReason: json['rcmd_reason'] as String?,
      );
    }).toList();
  }

  /// 将 VideoRecommendation 转换为 JSON
  Map<String, dynamic> _videoToJson(VideoRecommendation v) {
    final json = v.video.toJson();
    if (v.rcmdReason != null) {
      json['rcmd_reason'] = v.rcmdReason;
    }
    return json;
  }

  /// 初始化 - 离线优先策略
  /// 只加载持久化数据，不自动触发网络请求
  Future<void> initialize() async {
    if (_initialized) {
      AppLog.fine('Already initialized, skipping', name: 'Recommendation');
      return;
    }
    _initialized = true;

    AppLog.info('Initializing RecommendationController', name: 'Recommendation');
    try {
      // 等待 Storage 准备好
      final storage = await ref.read(sqlite3StorageProvider.future);
      AppLog.info('Storage ready, checking for persisted data', name: 'Recommendation');

      // 检查是否有持久化的数据
      final persistedData = await storage.read('home_recommendations');
      if (persistedData != null && persistedData.data is Map) {
        AppLog.info('Found persisted data, loading...', name: 'Recommendation');
        try {
          final json = persistedData.data as Map<String, dynamic>;
          final persistedResult = PersistedRecommendation.fromJson(json);

          state = state.copyWith(
            result: RecommendationResult(
              videos: _convertPersistedVideos(persistedResult.videos),
              hasMore: persistedResult.hasMore,
              currentPage: persistedResult.currentPage,
            ),
            isOffline: true,
            isLoading: false,
          );
          AppLog.info('Loaded ${persistedResult.videos.length} items from cache', name: 'Recommendation');
        } catch (e) {
          AppLog.warning('Failed to load persisted data: $e', name: 'Recommendation');
          // 设置为空状态，让用户看到错误并可以手动刷新
          state = state.copyWith(isLoading: false);
        }
      } else {
        AppLog.info('No valid persisted data found (data: ${persistedData?.data})', name: 'Recommendation');
        // 设置为空状态，不自动触发网络请求
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      AppLog.warning('Failed to check persisted data: $e', name: 'Recommendation');
      // 设置为空状态，不自动触发网络请求
      state = state.copyWith(isLoading: false);
    }
  }

  /// 获取推荐视频
  Future<void> fetchRecommendations({bool isRefresh = true}) async {
    AppLog.info('fetchRecommendations called: isRefresh=$isRefresh, isLoading=${state.isLoading}, hasResult=${state.result != null}, isOffline=${state.isOffline}', name: 'Recommendation');

    if (state.isLoading && state.result != null && !state.isOffline) {
      AppLog.fine('fetchRecommendations skipped: already loading', name: 'Recommendation');
      return;
    }
    if (!isRefresh && _isEnd) {
      AppLog.fine('fetchRecommendations skipped: reached end', name: 'Recommendation');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final useAppApi = _settingsUseCase.useAppRcmd;
      final result = await _fetchUseCase(
        freshIdx: isRefresh ? 0 : _currentFreshIdx,
        useAppApi: useAppApi,
      );

      // 数据通过 persist 自动持久化
      // 如果 persist 不工作，我们手动保存
      if (isRefresh && result.videos.isNotEmpty) {
        _manualSaveToCache(result.videos);
      }

      if (isRefresh) {
        _currentFreshIdx = 0;
        _isEnd = false;

        AppLog.info('fetchRecommendations refresh: got ${result.videos.length} videos', name: 'Recommendation');

        final enableSaveLastData = _settingsUseCase.enableSaveLastData;
        final showSavedRcmdTip = _settingsUseCase.showSavedRcmdTip;

        if (enableSaveLastData && result.videos.isNotEmpty) {
          final lastRefreshAt = showSavedRcmdTip
              ? state.displayList.length
              : null;
          final videos = result.videos.length > 200
              ? result.videos.take(50).toList()
              : result.videos;

          state = state.copyWith(
            result: result.copyWith(videos: videos),
            isLoading: false,
            lastRefreshAt: lastRefreshAt,
            isOffline: false, // 切换到在线数据
          );
        } else {
          state = state.copyWith(
            result: result,
            isLoading: false,
            lastRefreshAt: null,
            isOffline: false,
          );
        }
      } else {
        if (result.videos.isEmpty) {
          _isEnd = true;
          state = state.copyWith(isLoading: false);
          return;
        }

        final currentVideos = state.result?.videos ?? [];
        final mergedVideos = [...currentVideos, ...result.videos];

        state = state.copyWith(
          result: result.copyWith(videos: mergedVideos),
          isLoading: false,
        );
      }

      _currentFreshIdx++;
    } catch (e) {
      // 如果是离线模式，保持缓存数据
      if (state.isOffline) {
        state = state.copyWith(isLoading: false);
        AppLog.warning('Network failed, keeping offline data', name: 'Recommendation');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  /// 手动保存到缓存
  Future<void> _manualSaveToCache(List<VideoRecommendation> videos) async {
    try {
      AppLog.info('Manual save started: ${videos.length} videos', name: 'Recommendation');
      final storage = await ref.read(sqlite3StorageProvider.future);
      final data = PersistedRecommendation(
        videos: videos.map((v) => _videoToJson(v)).toList(),
        hasMore: false,
        currentPage: 0,
        cachedAt: DateTime.now().millisecondsSinceEpoch,
      ).toJson();

      await storage.write(
        'home_recommendations',
        data,
        const StorageOptions(),
      );
      AppLog.info('Manually saved ${videos.length} items to cache successfully', name: 'Recommendation');

      // 预加载所有封面图片
      _preloadImagesInBackground(videos);
    } catch (e) {
      AppLog.severe('Failed to manually save to cache: $e', name: 'Recommendation');
    }
  }

  /// 后台预加载图片
  void _preloadImagesInBackground(List<VideoRecommendation> videos) {
    // 提取所有封面URL
    final coverUrls = videos
        .map((v) => v.video.cover)
        .where((cover) => cover != null && cover!.isNotEmpty)
        .cast<String>()
        .toList();

    if (coverUrls.isEmpty) return;

    AppLog.info('Starting background preload of ${coverUrls.length} images', name: 'Recommendation');

    // 在后台预加载，不阻塞主线程
    Future.microtask(() async {
      try {
        await ImagePreloader.preloadImages(coverUrls);
      } catch (e) {
        AppLog.warning('Background image preload failed: $e', name: 'Recommendation');
      }
    });
  }

  /// 刷新
  Future<void> onRefresh() => fetchRecommendations(isRefresh: true);

  /// 加载更多
  Future<void> onLoadMore() => fetchRecommendations(isRefresh: false);

  /// 重新加载
  Future<void> onReload() async {
    state = const RecommendationState(isLoading: true);
    await onRefresh();
  }

  /// 移除视频
  void removeVideo(int index) {
    final currentVideos = state.result?.videos ?? [];
    if (index >= 0 && index < currentVideos.length) {
      final newVideos = List<VideoRecommendation>.from(currentVideos)
        ..removeAt(index);

      final currentLastRefreshAt = state.lastRefreshAt;
      final int? newLastRefreshAt =
          currentLastRefreshAt != null && index < currentLastRefreshAt
          ? currentLastRefreshAt - 1
          : currentLastRefreshAt;

      state = state.copyWith(
        result: state.result?.copyWith(videos: newVideos),
        lastRefreshAt: newLastRefreshAt,
      );
    }
  }
}

/// 推荐Controller Provider
final recommendationControllerProvider =
    NotifierProvider<RecommendationController, RecommendationState>(
  RecommendationController.new,
);
