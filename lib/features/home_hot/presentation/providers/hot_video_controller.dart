import 'package:PiliPlus/core/storage/database/sqlite3_storage_provider.dart';
import 'package:PiliPlus/features/home_hot/domain/entities/hot_video.dart';
import 'package:PiliPlus/features/home_hot/domain/entities/hot_video_result.dart';
import 'package:PiliPlus/features/home_hot/domain/usecases/fetch_hot_videos.dart';
import 'package:PiliPlus/features/home_hot/presentation/providers/hot_video_providers.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
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

  const HotVideoState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 复制并更新
  HotVideoState copyWith({
    HotVideoResult? result,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HotVideoState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 获取视频列表
  List<HotVideoItemModel> get displayList {
    if (result == null || result!.videos.isEmpty) {
      return [];
    }
    return result!.videos.map((v) => v.video).toList();
  }
}

/// 热门视频Controller
class HotVideoController extends Notifier<HotVideoState> {
  late final FetchHotVideosUseCase _fetchUseCase;

  int _currentPage = 1;
  bool _isEnd = false;

  @override
  HotVideoState build() {
    _fetchUseCase = ref.read(fetchHotVideosUseCaseProvider);

    // 启用离线持久化
    persist(
      ref.watch(sqlite3StorageProvider.future),
      key: 'home_hot',
      decode: (data) {
        if (data == null || data is! Map) {
          throw Exception('No persisted data found');
        }
        final json = data as Map<String, dynamic>;
        final resultJson = json['result'] as Map<String, dynamic>?;
        if (resultJson == null) {
          throw Exception('No result in persisted data');
        }
        final videos = (resultJson['videos'] as List?)
                ?.map((e) => HotVideo.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        return HotVideoState(
          result: HotVideoResult(
            videos: videos,
            hasMore: resultJson['hasMore'] as bool? ?? true,
            currentPage: resultJson['currentPage'] as int? ?? 1,
          ),
          isLoading: false,
        );
      },
      encode: (state) {
        if (state.result == null) return null;
        return {
          'result': {
            'videos': state.result!.videos.map((v) => v.toJson()).toList(),
            'hasMore': state.result!.hasMore,
          },
        };
      },
      options: const StorageOptions(
        cacheTime: StorageCacheTime(Duration(hours: 2)),
      ),
    );

    return const HotVideoState(isLoading: true);
  }

  /// 初始化并加载数据
  Future<void> initialize() async {
    // 尝试从缓存加载数据
    try {
      final storage = await ref.read(sqlite3StorageProvider.future);
      final persistedData = await storage.read('home_hot');
      if (persistedData != null && persistedData.data is Map) {
        final json = persistedData.data as Map<String, dynamic>;
        final resultJson = json['result'] as Map<String, dynamic>?;
        if (resultJson != null) {
          final videos = (resultJson['videos'] as List?)
                  ?.map((e) => HotVideo.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
          state = HotVideoState(
            result: HotVideoResult(
              videos: videos,
              hasMore: resultJson['hasMore'] as bool? ?? true,
              currentPage: resultJson['currentPage'] as int? ?? 1,
            ),
            isLoading: false,
          );
        }
      }
    } catch (e) {
      // 忽略错误，继续加载网络数据
    }

    // 发起网络请求更新数据
    fetchHotVideos(isRefresh: true);
  }

  /// 获取热门视频
  Future<void> fetchHotVideos({bool isRefresh = true}) async {
    if (state.isLoading && state.result != null) return;
    if (!isRefresh && _isEnd) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _fetchUseCase(
        pn: isRefresh ? 1 : _currentPage,
        ps: 20,
      );

      if (isRefresh) {
        _currentPage = 1;
        _isEnd = false;

        state = state.copyWith(
          result: result,
          isLoading: false,
        );

        // 手动保存到缓存
        _saveToCache();
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
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

  /// 手动保存到缓存
  Future<void> _saveToCache() async {
    try {
      final storage = await ref.read(sqlite3StorageProvider.future);
      if (state.result != null) {
        await storage.write(
          'home_hot',
          {
            'result': {
              'videos': state.result!.videos.map((v) => v.toJson()).toList(),
              'hasMore': state.result!.hasMore,
              'currentPage': state.result!.currentPage,
            },
          },
          const StorageOptions(),
        );
      }
    } catch (e) {
      // 忽略保存错误
    }
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
