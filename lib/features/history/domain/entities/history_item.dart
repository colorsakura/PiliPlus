import 'package:PiliPlus/models/history/history.dart';
import 'package:PiliPlus/models/history/list.dart';

/// 历史记录项实体
///
/// 封装观看历史记录信息
class HistoryItemEntity {
  /// 标题
  final String? title;

  /// 长标题
  final String? longTitle;

  /// 封面
  final String? cover;

  /// 封面列表
  final List<String>? covers;

  /// URI
  final String? uri;

  /// 历史记录信息
  final History history;

  /// 视频数量
  final int? videos;

  /// 作者名称
  final String? authorName;

  /// 作者头像
  final String? authorFace;

  /// 作者ID
  final int? authorMid;

  /// 观看时间
  final int? viewAt;

  /// 观看进度 (-1表示已看完)
  final int? progress;

  /// 徽章
  final String? badge;

  /// 显示标题
  final String? showTitle;

  /// 时长
  final int? duration;

  /// 当前
  final String? current;

  /// 总数
  final int? total;

  /// 新描述
  final String? newDesc;

  /// 是否完成
  final int? isFinish;

  /// 是否收藏
  final int? isFav;

  /// KID
  final int? kid;

  /// 标签名称
  final String? tagName;

  /// 直播状态
  final int? liveStatus;

  const HistoryItemEntity({
    this.title,
    this.longTitle,
    this.cover,
    this.covers,
    this.uri,
    required this.history,
    this.videos,
    this.authorName,
    this.authorFace,
    this.authorMid,
    this.viewAt,
    this.progress,
    this.badge,
    this.showTitle,
    this.duration,
    this.current,
    this.total,
    this.newDesc,
    this.isFinish,
    this.isFav,
    this.kid,
    this.tagName,
    this.liveStatus,
  });

  /// 是否已看完
  bool get isViewed => progress == -1;

  /// 从模型创建实体
  factory HistoryItemEntity.fromModel(dynamic model) {
    // 这里假设传入的是 HistoryItemModel
    return HistoryItemEntity(
      title: model.title as String?,
      longTitle: model.longTitle as String?,
      cover: model.cover as String?,
      covers: model.covers as List<String>?,
      uri: model.uri as String?,
      history: model.history as History,
      videos: model.videos as int?,
      authorName: model.authorName as String?,
      authorFace: model.authorFace as String?,
      authorMid: model.authorMid as int?,
      viewAt: model.viewAt as int?,
      progress: model.progress as int?,
      badge: model.badge as String?,
      showTitle: model.showTitle as String?,
      duration: model.duration as int?,
      current: model.current as String?,
      total: model.total as int?,
      newDesc: model.newDesc as String?,
      isFinish: model.isFinish as int?,
      isFav: model.isFav as int?,
      kid: model.kid as int?,
      tagName: model.tagName as String?,
      liveStatus: model.liveStatus as int?,
    );
  }

  /// 创建一个不可变副本（不支持 const）
  HistoryItemEntity copyWith({
    String? title,
    String? longTitle,
    String? cover,
    List<String>? covers,
    String? uri,
    History? history,
    int? videos,
    String? authorName,
    String? authorFace,
    int? authorMid,
    int? viewAt,
    int? progress,
    String? badge,
    String? showTitle,
    int? duration,
    String? current,
    int? total,
    String? newDesc,
    int? isFinish,
    int? isFav,
    int? kid,
    String? tagName,
    int? liveStatus,
  }) {
    return HistoryItemEntity(
      title: title ?? this.title,
      longTitle: longTitle ?? this.longTitle,
      cover: cover ?? this.cover,
      covers: covers ?? this.covers,
      uri: uri ?? this.uri,
      history: history ?? this.history,
      videos: videos ?? this.videos,
      authorName: authorName ?? this.authorName,
      authorFace: authorFace ?? this.authorFace,
      authorMid: authorMid ?? this.authorMid,
      viewAt: viewAt ?? this.viewAt,
      progress: progress ?? this.progress,
      badge: badge ?? this.badge,
      showTitle: showTitle ?? this.showTitle,
      duration: duration ?? this.duration,
      current: current ?? this.current,
      total: total ?? this.total,
      newDesc: newDesc ?? this.newDesc,
      isFinish: isFinish ?? this.isFinish,
      isFav: isFav ?? this.isFav,
      kid: kid ?? this.kid,
      tagName: tagName ?? this.tagName,
      liveStatus: liveStatus ?? this.liveStatus,
    );
  }

  /// 生成删除标识符
  String get deleteKey => '${history.business}_$kid';

  /// 转换为模型
  HistoryItemModel toModel() {
    return HistoryItemModel(
      title: title,
      longTitle: longTitle,
      cover: cover,
      covers: covers,
      uri: uri,
      history: history,
      videos: videos,
      authorName: authorName,
      authorFace: authorFace,
      authorMid: authorMid,
      viewAt: viewAt,
      progress: progress,
      badge: badge,
      showTitle: showTitle,
      duration: duration,
      current: current,
      total: total,
      newDesc: newDesc,
      isFinish: isFinish,
      isFav: isFav,
      kid: kid,
      tagName: tagName,
      liveStatus: liveStatus,
    );
  }
}
