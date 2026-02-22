import 'package:PiliPlus/models/model_video.dart';

/// 视频推荐实体
///
/// 包装推荐视频项及其相关的UI状态
class VideoRecommendation {
  /// 视频项（可能是 Web 或 App 模型）
  final dynamic video;

  /// 推荐原因
  final String? rcmdReason;

  const VideoRecommendation({
    required this.video,
    this.rcmdReason,
  });

  /// 视频ID（aid）
  int get id => video.aid ?? 0;

  /// 视频BV号
  String? get bvid => video.bvid;

  /// 视频封面
  String? get cover => video.cover;

  /// 视频标题
  String get title => video.title;

  /// 视频时长（秒）
  int get duration => video.duration;

  /// UP主信息
  BaseOwner get owner => video.owner;

  /// 视频统计信息
  BaseStat get stat => video.stat;

  /// 是否已关注
  bool get isFollowed => video.isFollowed;
}
