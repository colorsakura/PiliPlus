import 'package:PiliPlus/models/later/list.dart';

/// 稍后再看项实体
class LaterItemEntity {
  /// 视频AV号
  final int? aid;

  /// 视频数量
  final int? videos;

  /// 封面
  final String? pic;

  /// 标题
  final String? title;

  /// 副标题
  final String? subtitle;

  /// 发布时间
  final int? pubdate;

  /// 时长
  final int? duration;

  /// 重定向URL
  final String? redirectUrl;

  /// 权限
  final dynamic rights;

  /// 作者
  final dynamic owner;

  /// 统计
  final dynamic stat;

  /// 分P
  final List<dynamic>? pages;

  /// 番剧信息
  final dynamic bangumi;

  /// CID
  final int? cid;

  /// 进度
  final int? progress;

  /// BV号
  final String? bvid;

  /// 是否PGC
  final bool? isPgc;

  /// PGC标签
  final String? pgcLabel;

  /// 是否PUGV
  final bool? isPugv;

  /// 合集ID
  final int? seasonId;

  /// 是否付费
  final bool? isCharging;

  /// 维度
  final dynamic dimension;

  const LaterItemEntity({
    this.aid,
    this.videos,
    this.pic,
    this.title,
    this.subtitle,
    this.pubdate,
    this.duration,
    this.redirectUrl,
    this.rights,
    this.owner,
    this.stat,
    this.pages,
    this.bangumi,
    this.cid,
    this.progress,
    this.bvid,
    this.isPgc,
    this.pgcLabel,
    this.isPugv,
    this.seasonId,
    this.isCharging,
    this.dimension,
  });

  /// 从模型创建实体
  factory LaterItemEntity.fromModel(LaterItemModel model) {
    return LaterItemEntity(
      aid: model.aid,
      videos: model.videos,
      pic: model.pic,
      title: model.title,
      subtitle: model.subtitle,
      pubdate: model.pubdate,
      duration: model.duration,
      redirectUrl: model.redirectUrl,
      rights: model.rights,
      owner: model.owner,
      stat: model.stat,
      pages: model.pages,
      bangumi: model.bangumi,
      cid: model.cid,
      progress: model.progress,
      bvid: model.bvid,
      isPgc: model.isPgc,
      pgcLabel: model.pgcLabel,
      isPugv: model.isPugv,
      seasonId: model.seasonId,
      isCharging: model.isCharging,
      dimension: model.dimension,
    );
  }

  /// 转换为模型
  LaterItemModel toModel() {
    return LaterItemModel(
      aid: aid,
      videos: videos,
      pic: pic,
      title: title,
      subtitle: subtitle,
      pubdate: pubdate,
      duration: duration,
      redirectUrl: redirectUrl,
      rights: rights as dynamic,
      owner: owner as dynamic,
      stat: stat as dynamic,
      pages: pages?.cast(),
      bangumi: bangumi as dynamic,
      cid: cid,
      progress: progress,
      bvid: bvid,
      isPgc: isPgc,
      pgcLabel: pgcLabel,
      isPugv: isPugv,
      seasonId: seasonId,
      isCharging: isCharging,
      dimension: dimension as dynamic,
    );
  }

  /// 生成唯一标识符
  String get id => 'later_$aid';
}
