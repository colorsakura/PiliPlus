import 'package:PiliPlus/features/home_rcmd/domain/entities/recommendation_result.dart';
import 'package:PiliPlus/features/home_rcmd/domain/entities/video_recommendation.dart';
import 'package:PiliPlus/features/home_rcmd/domain/usecases/fetch_recommendations.dart';
import 'package:PiliPlus/features/home_rcmd/domain/usecases/get_recommendation_settings.dart';
import 'package:PiliPlus/features/home_rcmd/presentation/providers/recommendation_providers.dart';
import 'package:PiliPlus/utils/log.dart';
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

  const RecommendationState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
    this.lastRefreshAt,
  });

  /// 复制并更新
  RecommendationState copyWith({
    RecommendationResult? result,
    bool? isLoading,
    String? errorMessage,
    int? lastRefreshAt,
  }) {
    return RecommendationState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
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

/// 推荐Controller
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

    return const RecommendationState();
  }

  /// 初始化
  Future<void> initialize() async {
    if (_initialized) {
      AppLog.fine('Already initialized, skipping', name: 'Recommendation');
      return;
    }
    _initialized = true;
    AppLog.info('Initializing RecommendationController', name: 'Recommendation');
  }

  /// 获取推荐视频
  Future<void> fetchRecommendations({bool isRefresh = true}) async {
    AppLog.info('fetchRecommendations called: isRefresh=$isRefresh, isLoading=${state.isLoading}, hasResult=${state.result != null}', name: 'Recommendation');

    if (state.isLoading && state.result != null) {
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
          );
        } else {
          state = state.copyWith(
            result: result,
            isLoading: false,
            lastRefreshAt: null,
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
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
