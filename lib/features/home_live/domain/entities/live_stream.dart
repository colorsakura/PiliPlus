import 'package:PiliPlus/models/live/live_feed_index/card_data_list_item.dart';

/// 直播流实体
///
/// 表示单个直播房间/流的信息
class LiveStream {
  /// 直播间ID
  final int roomId;

  /// 主播ID
  final int uid;

  /// 主播名称
  final String uname;

  /// 主播头像
  final String? face;

  /// 房间标题
  final String? title;

  /// 分区ID
  final int? areaId;

  /// 父分区ID
  final int? parentAreaId;

  /// 分区名称
  final String? areaName;

  /// 封面图
  final String? cover;

  /// 在线人数
  final int? online;

  const LiveStream({
    required this.roomId,
    required this.uid,
    required this.uname,
    this.face,
    this.title,
    this.areaId,
    this.parentAreaId,
    this.areaName,
    this.cover,
    this.online,
  });

  /// 从 CardLiveItem 创建
  factory LiveStream.fromCardLiveItem(CardLiveItem item) {
    return LiveStream(
      roomId: item.roomid ?? 0,
      uid: item.uid ?? 0,
      uname: item.uname ?? '',
      face: item.face,
      title: item.title,
      areaId: item.areaV2Id,
      parentAreaId: item.areaV2ParentId,
      areaName: item.areaV2Name,
      cover: item.cover,
      online: null, // CardLiveItem 没有 online 字段
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'uid': uid,
      'uname': uname,
      'face': face,
      'title': title,
      'areaId': areaId,
      'parentAreaId': parentAreaId,
      'areaName': areaName,
      'cover': cover,
      'online': online,
    };
  }

  /// 从 JSON 创建
  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      roomId: json['roomId'] as int,
      uid: json['uid'] as int,
      uname: json['uname'] as String,
      face: json['face'] as String?,
      title: json['title'] as String?,
      areaId: json['areaId'] as int?,
      parentAreaId: json['parentAreaId'] as int?,
      areaName: json['areaName'] as String?,
      cover: json['cover'] as String?,
      online: json['online'] as int?,
    );
  }
}
