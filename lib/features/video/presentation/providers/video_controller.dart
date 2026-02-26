import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/video/domain/entities/video_ai_conclusion_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_detail_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_play_url_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_relation_entity.dart';
import 'package:PiliPlus/features/video/domain/usecases/get_ai_conclusion.dart';
import 'package:PiliPlus/features/video/domain/usecases/get_video_detail.dart';
import 'package:PiliPlus/features/video/domain/usecases/get_video_play_url.dart';
import 'package:PiliPlus/features/video/domain/usecases/get_video_relation.dart';
import 'package:PiliPlus/features/video/domain/usecases/like_video.dart';
import 'package:PiliPlus/features/video/presentation/providers/video_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 视频状态
class VideoState {
  /// 视频详情
  final VideoDetailEntity? videoDetail;

  /// 视频关系（点赞、投币、收藏）
  final VideoRelationEntity? videoRelation;

  /// AI总结
  final VideoAIConclusionEntity? aiConclusion;

  /// 当前选中的分P索引
  final int currentCidIndex;

  /// 是否正在加载
  final bool isLoading;

  /// 是否加载失败
  final bool hasError;

  /// 错误信息
  final String? errorMessage;

  const VideoState({
    this.videoDetail,
    this.videoRelation,
    this.aiConclusion,
    this.currentCidIndex = 0,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  VideoState copyWith({
    VideoDetailEntity? videoDetail,
    VideoRelationEntity? videoRelation,
    VideoAIConclusionEntity? aiConclusion,
    int? currentCidIndex,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return VideoState(
      videoDetail: videoDetail ?? this.videoDetail,
      videoRelation: videoRelation ?? this.videoRelation,
      aiConclusion: aiConclusion ?? this.aiConclusion,
      currentCidIndex: currentCidIndex ?? this.currentCidIndex,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 获取当前分P的cid
  int? get currentCid {
    if (videoDetail?.pages != null &&
        videoDetail!.pages!.isNotEmpty &&
        currentCidIndex < videoDetail!.pages!.length) {
      return videoDetail!.pages![currentCidIndex].cid;
    }
    return videoDetail?.cid;
  }

  /// 获取当前视频bvid
  String? get currentBvid => videoDetail?.bvid;
}

/// 视频Controller
class VideoController extends Notifier<VideoState> {
  late final GetVideoDetailUseCase _getVideoDetailUseCase;
  late final GetVideoRelationUseCase _getVideoRelationUseCase;
  late final GetAIConclusionUseCase _getAIConclusionUseCase;
  late final LikeVideoUseCase _likeVideoUseCase;
  late final GetVideoPlayUrlUseCase _getVideoPlayUrlUseCase;

  @override
  VideoState build() {
    _getVideoDetailUseCase = ref.read(getVideoDetailUseCaseProvider);
    _getVideoRelationUseCase = ref.read(getVideoRelationUseCaseProvider);
    _getAIConclusionUseCase = ref.read(getAIConclusionUseCaseProvider);
    _likeVideoUseCase = ref.read(likeVideoUseCaseProvider);
    _getVideoPlayUrlUseCase = ref.read(getVideoPlayUrlUseCaseProvider);

    return const VideoState();
  }

  /// 初始化视频
  Future<void> initVideo({
    required String bvid,
    int? aid,
  }) async {
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      // 并行获取视频详情和关系
      final results = await Future.wait([
        _getVideoDetailUseCase(bvid: bvid, aid: aid),
        _getVideoRelationUseCase(bvid: bvid),
      ]);

      state = state.copyWith(
        videoDetail: results[0] as VideoDetailEntity,
        videoRelation: results[1] as VideoRelationEntity,
        isLoading: false,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// 切换分P
  void changeCidIndex(int index) {
    state = state.copyWith(currentCidIndex: index);
  }

  /// 点赞/取消点赞
  Future<void> toggleLike() async {
    final bvid = state.currentBvid;
    if (bvid == null) return;

    final currentRelation = state.videoRelation;
    if (currentRelation == null) return;

    // 乐观更新
    final newLiked = !currentRelation.liked;
    state = state.copyWith(
      videoRelation: currentRelation.copyWith(liked: newLiked),
    );

    try {
      await _likeVideoUseCase(
        bvid: bvid,
        like: newLiked,
      );
    } catch (e) {
      // 失败则回滚
      state = state.copyWith(
        videoRelation: currentRelation,
      );
    }
  }

  /// 获取AI总结
  Future<void> fetchAIConclusion() async {
    final bvid = state.currentBvid;
    final cid = state.currentCid;
    if (bvid == null || cid == null) return;

    try {
      final conclusion = await _getAIConclusionUseCase(
        bvid: bvid,
        cid: cid,
      );
      state = state.copyWith(aiConclusion: conclusion);
    } catch (e) {
      // AI总结失败不影响主流程
      // 可以记录错误
    }
  }

  /// 获取视频播放URL
  Future<VideoPlayUrlEntity> getVideoPlayUrl({
    required int qn,
    int? fnval,
    int? fnver,
    bool? fourk,
    String? session,
  }) async {
    final bvid = state.currentBvid;
    final cid = state.currentCid;
    if (bvid == null || cid == null) {
      throw const ValidationFailure('视频信息未加载');
    }

    return await _getVideoPlayUrlUseCase(
      bvid: bvid,
      cid: cid,
      qn: qn,
      fnval: fnval,
      fnver: fnver,
      fourk: fourk,
      session: session,
    );
  }

  /// 重置状态
  void reset() {
    state = const VideoState();
  }
}

/// 视频Controller Provider
final videoControllerProvider =
    NotifierProvider<VideoController, VideoState>(
  VideoController.new,
);

/// 根据bvid获取视频Provider
/// 这允许在不同的页面使用不同的视频实例
final videoControllerFamilyProvider =
    Provider.family<VideoController, String>((ref, bvid) {
  // 获取或创建controller
  final container = ref.container;
  // 注意：实际实现可能需要使用其他方式来管理多个实例
  // 这里简化为使用同一个provider
  return container.read(videoControllerProvider.notifier);
});
