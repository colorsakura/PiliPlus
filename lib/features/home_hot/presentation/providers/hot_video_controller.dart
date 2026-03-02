import 'package:PiliPlus/features/home_hot/domain/entities/hot_video.dart';
import 'package:PiliPlus/features/home_hot/domain/entities/hot_video_result.dart';
import 'package:PiliPlus/features/home_hot/domain/usecases/fetch_hot_videos.dart';
import 'package:PiliPlus/features/home_hot/presentation/providers/hot_video_providers.dart';
import 'package:PiliPlus/utils/log.dart';
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
  List<HotVideo> get displayList {
    if (result == null || result!.videos.isEmpty) {
      return [];
    }
    return result!.videos;
  }
}

/// 热门视频Controller
class HotVideoController extends Notifier<HotVideoState> {
  late final FetchHotVideosUseCase _fetchUseCase;

  int _currentPage = 1;
  bool _isEnd = false;
  bool _initialized = false;

  @override
  HotVideoState build() {
    _fetchUseCase = ref.read(fetchHotVideosUseCaseProvider);

    return const HotVideoState();
  }

  /// 初始化
  Future<void> initialize() async {
    if (_initialized) {
      AppLog.fine('Already initialized, skipping', name: 'HotVideo');
      return;
    }
    _initialized = true;
    AppLog.info('Initializing HotVideoController', name: 'HotVideo');
  }

  /// 获取热门视频
  Future<void> fetchHotVideos({bool isRefresh = true}) async {
    AppLog.info('fetchHotVideos called: isRefresh=$isRefresh, isLoading=${state.isLoading}, hasResult=${state.result != null}', name: 'HotVideo');

    if (state.isLoading && state.result != null) {
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
        );
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
