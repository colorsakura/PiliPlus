import 'package:PiliPlus/features/video/domain/entities/video_ai_conclusion_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_detail_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_play_info_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_play_url_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_relation_entity.dart';
import 'package:PiliPlus/models/video/play/url.dart';

/// 视频仓库接口
///
/// 定义所有视频相关的数据操作
abstract interface class VideoRepository {
  /// 获取视频详情
  ///
  /// [bvid] 视频BV号
  /// [aid] 视频AV号
  Future<VideoDetailEntity> getVideoInfo({
    String? bvid,
    int? aid,
  });

  /// 获取视频播放URL
  ///
  /// [cid] 视频分P的cid
  /// [qn] 视频质量
  /// [bvid] 视频BV号
  /// [aid] 视频AV号
  /// [session] 会话ID
  Future<VideoPlayUrlEntity> getVideoPlayUrl({
    required int cid,
    required int qn,
    int? fnval,
    int? fnver,
    bool? fourk,
    String? bvid,
    int? aid,
    String? session,
  });

  /// 点赞视频
  ///
  /// [bvid] 视频BV号
  /// [like] 是否点赞
  Future<void> likeVideo({
    required String bvid,
    required bool like,
  });

  /// 投币视频
  ///
  /// [bvid] 视频BV号
  /// [num] 投币数量 (1-2)
  /// [selectLike] 是否同时点赞
  Future<void> coinVideo({
    required String bvid,
    required int num,
    bool? selectLike,
  });

  /// 收藏视频
  ///
  /// [bvid] 视频BV号
  /// [addMediaIds] 添加到的收藏夹ID列表
  /// [delMediaIds] 取消收藏的收藏夹ID列表
  Future<void> favVideo({
    required String bvid,
    required List<int> addMediaIds,
    required List<int> delMediaIds,
  });

  /// 一键三连
  ///
  /// [bvid] 视频BV号
  Future<Map<String, dynamic>> ugcTriple({
    required String bvid,
  });

  /// 获取视频关系（点赞、投币、收藏状态）
  ///
  /// [bvid] 视频BV号
  Future<VideoRelationEntity> getVideoRelation({
    required String bvid,
  });

  /// 获取相关视频
  ///
  /// [bvid] 视频BV号
  Future<List<dynamic>> getRelatedVideos({
    required String bvid,
  });

  /// 发送弹幕
  ///
  /// [msg] 弹幕内容
  /// [oid] 视频cid
  /// [progress] 弹幕出现位置（毫秒）
  /// [type] 视频类型 (1:UGC, 3:PGC)
  /// [color] 弹幕颜色
  Future<void> sendDanmaku({
    required String msg,
    required int oid,
    required int progress,
    required int type,
    int? color,
  });

  /// 获取AI总结
  ///
  /// [bvid] 视频BV号
  /// [cid] 视频分P的cid
  /// [upMid] UP主mid
  Future<VideoAIConclusionEntity> getAIConclusion({
    required String bvid,
    required int cid,
    int? upMid,
  });

  /// 获取播放信息
  ///
  /// [bvid] 视频BV号
  /// [aid] 视频AV号
  /// [cid] 视频分P的cid
  /// [seasonId] 番剧seasonId
  /// [epId] 番剧epId
  Future<VideoPlayInfoEntity> getPlayInfo({
    String? bvid,
    String? aid,
    required int cid,
    int? seasonId,
    int? epId,
  });

  /// 获取字幕VTT格式
  ///
  /// [subtitleUrl] 字幕URL
  Future<String?> getVTTSubtitles({
    required String subtitleUrl,
  });
}
