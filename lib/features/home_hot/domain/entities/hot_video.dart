import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/models/model_video.dart';

/// 热门视频实体
///
/// 包装热门视频项
class HotVideo {
  /// 视频数据模型
  final HotVideoItemModel video;

  const HotVideo({
    required this.video,
  });

  /// 视频ID (aid)
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

  /// 分区名称
  String? get tname => video.tname;

  /// 视频数量（合集用）
  int? get videos => video.videos;

  /// 从 JSON 创建
  factory HotVideo.fromJson(Map<String, dynamic> json) {
    return HotVideo(
      video: HotVideoItemModel.fromJson(json),
    );
  }

  /// 转换为 JSON
  /// 由于 HotVideoItemModel 没有 toJson 方法，我们需要手动构建
  Map<String, dynamic> toJson() {
    return {
      'aid': video.aid,
      'bvid': video.bvid,
      'title': video.title,
      'cover': video.cover,
      'duration': video.duration,
      'owner': {
        'mid': video.owner.mid,
        'name': video.owner.name,
      },
      'stat': {
        'view': video.stat.view,
        'danmu': video.stat.danmu,
      },
      'tname': video.tname,
      'videos': video.videos,
    };
  }
}
