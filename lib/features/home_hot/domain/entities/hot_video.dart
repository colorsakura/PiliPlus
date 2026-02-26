import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/models/model_video.dart';

/// 热门视频实体
///
/// 包装热门视频项
class HotVideo {
  /// 视频数据模型
  final HotVideoItemModel video;

  /// 原始 JSON 数据（用于持久化）
  final Map<String, dynamic>? rawJson;

  const HotVideo({
    required this.video,
    this.rawJson,
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
      rawJson: json,
    );
  }

  /// 从模型创建
  factory HotVideo.fromModel(HotVideoItemModel model) {
    return HotVideo(
      video: model,
      rawJson: _modelToJson(model),
    );
  }

  /// 转换为 JSON（返回原始 JSON 数据，如果没有则生成）
  Map<String, dynamic> toJson() => rawJson ?? _modelToJson(video);

  /// 将 HotVideoItemModel 转换为 JSON（模拟 API 响应格式）
  static Map<String, dynamic> _modelToJson(HotVideoItemModel model) {
    final stat = model.stat is HotStat ? model.stat as HotStat : null;

    return {
      'aid': model.aid,
      'bvid': model.bvid,
      'cid': model.cid,
      'videos': model.videos,
      'tid': model.tid,
      'tname': model.tname,
      'copyright': model.copyright,
      'pic': model.cover,
      'title': model.title,
      'pubdate': model.pubdate,
      'ctime': model.ctime,
      'desc': model.desc,
      'state': model.state,
      'duration': model.duration,
      'owner': {
        'mid': model.owner.mid,
        'name': model.owner.name,
      },
      'stat': {
        'view': model.stat.view,
        'danmaku': model.stat.danmu,
        'like': model.stat.like,
        if (stat != null) ...{
          'reply': stat.reply,
          'favorite': stat.favorite,
          'coin': stat.coin,
          'share': stat.share,
          'now_rank': stat.nowRank,
          'his_rank': stat.hisRank,
          'dislike': stat.dislike,
          'vt': stat.vt,
          'vv': stat.vv,
        },
      },
      if (model.dimension != null)
        'dimension': {
          'width': model.dimension!.width,
          'height': model.dimension!.height,
        },
      'first_frame': model.firstFrame,
      'pub_location': model.pubLocation,
      'rcmd_reason': model.rcmdReason,
      'pgc_label': model.pgcLabel,
      'redirect_url': model.redirectUrl,
      'progress': model.progress,
      'rights': {
        'is_cooperation': model.isCooperation,
      },
      if (model.isCharging == true)
        'charging_pay': {'level': 1},
    };
  }
}
