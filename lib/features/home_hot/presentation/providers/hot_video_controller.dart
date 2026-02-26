import 'package:PiliPlus/core/image_cache/image_preloader.dart';
import 'package:PiliPlus/core/storage/database/sqlite3_storage_provider.dart';
import 'package:PiliPlus/features/home_hot/domain/entities/hot_video.dart';
import 'package:PiliPlus/features/home_hot/domain/entities/hot_video_result.dart';
import 'package:PiliPlus/features/home_hot/domain/entities/persisted_hot_video.dart';
import 'package:PiliPlus/features/home_hot/domain/usecases/fetch_hot_videos.dart';
import 'package:PiliPlus/features/home_hot/presentation/providers/hot_video_providers.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 热门视频状态
class HotVideoState {
  /// 热门视频结果
  final HotVideoResult? result;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? errorMessage;

  /// 是否显示缓存数据（离线模式）
  final bool isOffline;

  const HotVideoState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
    this.isOffline = false,
  });

  /// 复制并更新
  HotVideoState copyWith({
    HotVideoResult? result,
    bool? isLoading,
    String? errorMessage,
    bool? isOffline,
  }) {
    return HotVideoState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  /// 获取视频列表
  List<HotVideo> get displayList {
    if (result == null || result!.videos.isEmpty) {
      return [];
    }
    return result!.videos;
  }
}

/// 热门视频Controller - 使用 RiverPod 的离线优先模式
class HotVideoController extends Notifier<HotVideoState> {
  late final FetchHotVideosUseCase _fetchUseCase;

  int _currentPage = 1;
  bool _isEnd = false;
  bool _initialized = false;

  @override
  HotVideoState build() {
    _fetchUseCase = ref.read(fetchHotVideosUseCaseProvider);

    // 启用离线持久化
    persist(
      ref.watch(sqlite3StorageProvider.future),
      key: 'home_hot_videos',
      decode: (data) {
        AppLog.info('Decoding persisted data', name: 'HotVideo');
        if (data == null || data is! Map) {
          AppLog.warning('No valid persisted data found (data: $data)', name: 'HotVideo');
          throw Exception('No valid persisted data found');
        }
        try {
          final json = data as Map<String, dynamic>;
          final persistedData = PersistedHotVideo.fromJson(json);
          AppLog.info(
            'Loaded ${persistedData.videos.length} persisted items',
            name: 'HotVideo',
          );
          return HotVideoState(
            result: HotVideoResult(
              videos: _convertPersistedVideos(persistedData.videos),
              hasMore: persistedData.hasMore,
              currentPage: persistedData.currentPage,
            ),
            isLoading: false,
            isOffline: true,
          );
        } catch (e) {
          AppLog.severe('Failed to decode persisted data: $e', name: 'HotVideo');
          rethrow;
        }
      },
      encode: (state) {
        // 只在有数据且不是加载状态时才保存
        AppLog.fine('encode called: result=${state.result != null}, videos=${state.result?.videos.length ?? 0}, isLoading=${state.isLoading}', name: 'HotVideo');

        if (state.result == null || state.result!.videos.isEmpty || state.isLoading) {
          AppLog.fine('Skipping persist: no valid data', name: 'HotVideo');
          return null;
        }

        final videos = state.result!.videos.map((v) => v.toJson()).toList();
        AppLog.info('Persisting ${videos.length} items (hasData=true)', name: 'HotVideo');
        return PersistedHotVideo(
          videos: videos,
          hasMore: state.result!.hasMore,
          currentPage: state.result!.currentPage,
          cachedAt: DateTime.now().millisecondsSinceEpoch,
        ).toJson();
      },
      options: const StorageOptions(
        cacheTime: StorageCacheTime(Duration(hours: 2)),
      ),
    );

    return const HotVideoState(isLoading: true);
  }

  /// 将持久化的视频数据转换为 HotVideo
  List<HotVideo> _convertPersistedVideos(
    List<Map<String, dynamic>> videos,
  ) {
    return videos.map((json) => HotVideo.fromJson(json)).toList();
  }

  /// 初始化 - 离线优先策略
  /// 加载持久化数据，不自动刷新
  Future<void> initialize() async {
    if (_initialized) {
      AppLog.fine('Already initialized, skipping', name: 'HotVideo');
      return;
    }
    _initialized = true;

    AppLog.info('Initializing HotVideoController', name: 'HotVideo');
    try {
      // 等待 Storage 准备好
      final storage = await ref.read(sqlite3StorageProvider.future);
      AppLog.info('Storage ready, checking for persisted data', name: 'HotVideo');

      // 检查是否有持久化的数据
      final persistedData = await storage.read('home_hot_videos');
      if (persistedData != null && persistedData.data is Map) {
        AppLog.info('Found persisted data, loading...', name: 'HotVideo');
        try {
          final json = persistedData.data as Map<String, dynamic>;
          final persistedResult = PersistedHotVideo.fromJson(json);

          state = state.copyWith(
            result: HotVideoResult(
              videos: _convertPersistedVideos(persistedResult.videos),
              hasMore: persistedResult.hasMore,
              currentPage: persistedResult.currentPage,
            ),
            isOffline: true,
            isLoading: false,
          );
          AppLog.info('Loaded ${persistedResult.videos.length} items from cache', name: 'HotVideo');
        } catch (e) {
          AppLog.warning('Failed to load persisted data: $e', name: 'HotVideo');
        }
      } else {
        AppLog.info('No valid persisted data found (data: ${persistedData?.data})', name: 'HotVideo');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      AppLog.warning('Failed to check persisted data: $e', name: 'HotVideo');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 获取热门视频
  Future<void> fetchHotVideos({bool isRefresh = true}) async {
    AppLog.info('fetchHotVideos called: isRefresh=$isRefresh, isLoading=${state.isLoading}, hasResult=${state.result != null}, isOffline=${state.isOffline}', name: 'HotVideo');

    if (state.isLoading && state.result != null && !state.isOffline) {
      AppLog.fine('fetchHotVideos skipped: already loading', name: 'HotVideo');
      return;
    }
    if (!isRefresh && _isEnd) {
      AppLog.fine('fetchHotVideos skipped: reached end', name: 'HotVideo');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _fetchUseCase(
        pn: isRefresh ? 1 : _currentPage,
        ps: 20,
      );

      if (isRefresh) {
        _currentPage = 1;
        _isEnd = false;

        AppLog.info('fetchHotVideos refresh: got ${result.videos.length} videos', name: 'HotVideo');

        state = state.copyWith(
          result: result,
          isLoading: false,
          isOffline: false, // 切换到在线数据
        );

        // 手动保存到缓存
        if (result.videos.isNotEmpty) {
          _manualSaveToCache(result.videos);
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
          result: result.copyWith(
            videos: mergedVideos,
            currentPage: _currentPage,
          ),
          isLoading: false,
        );
      }

      _currentPage++;
    } catch (e) {
      // 如果是离线模式，保持缓存数据
      if (state.isOffline) {
        state = state.copyWith(isLoading: false);
        AppLog.warning('Network failed, keeping offline data', name: 'HotVideo');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  /// 手动保存到缓存
  Future<void> _manualSaveToCache(List<HotVideo> videos) async {
    try {
      AppLog.info('Manual save started: ${videos.length} videos', name: 'HotVideo');
      final storage = await ref.read(sqlite3StorageProvider.future);
      final data = PersistedHotVideo(
        videos: videos.map((v) => v.toJson()).toList(),
        hasMore: false,
        currentPage: 0,
        cachedAt: DateTime.now().millisecondsSinceEpoch,
      ).toJson();

      await storage.write(
        'home_hot_videos',
        data,
        const StorageOptions(),
      );
      AppLog.info('Manually saved ${videos.length} items to cache successfully', name: 'HotVideo');

      // 预加载所有封面图片
      _preloadImagesInBackground(videos);
    } catch (e) {
      AppLog.severe('Failed to manually save to cache: $e', name: 'HotVideo');
    }
  }

  /// 后台预加载图片
  void _preloadImagesInBackground(List<HotVideo> videos) {
    // 提取所有封面URL
    final coverUrls = <String>[
      for (final v in videos)
        if (v.cover case final cover? when cover.isNotEmpty) cover,
    ];

    if (coverUrls.isEmpty) return;

    AppLog.info('Starting background preload of ${coverUrls.length} images', name: 'HotVideo');

    // 在后台预加载，不阻塞主线程
    Future.microtask(() async {
      try {
        await ImagePreloader.preloadImages(coverUrls);
      } catch (e) {
        AppLog.warning('Background image preload failed: $e', name: 'HotVideo');
      }
    });
  }

  /// 刷新
  Future<void> onRefresh() => fetchHotVideos(isRefresh: true);

  /// 加载更多
  Future<void> onLoadMore() => fetchHotVideos(isRefresh: false);

  /// 重新加载
  Future<void> onReload() async {
    state = const HotVideoState(isLoading: true);
    await onRefresh();
  }

  /// 移除视频
  void removeVideo(int index) {
    final currentVideos = state.result?.videos ?? [];
    if (index >= 0 && index < currentVideos.length) {
      final newVideos = List<HotVideo>.from(currentVideos)..removeAt(index);

      state = state.copyWith(
        result: state.result?.copyWith(videos: newVideos),
      );
    }
  }
}

/// 热门视频Controller Provider
final hotVideoControllerProvider =
    NotifierProvider<HotVideoController, HotVideoState>(
      HotVideoController.new,
    );
