/// 首页推荐缓存实体
///
/// 用于存储首页推荐视频的缓存数据
class HomeCacheEntity {
  /// 唯一标识
  final int id;

  /// 视频 AV ID
  final int aid;

  /// 视频 BV ID
  final String bvid;

  /// 视频 CID
  final int cid;

  /// 封面 URL
  final String cover;

  /// 标题
  final String title;

  /// UP 主 ID
  final int ownerMid;

  /// UP 主名称
  final String ownerName;

  /// UP 主头像
  final String? ownerFace;

  /// 时长（秒）
  final int duration;

  /// 播放数
  final int view;

  /// 弹幕数
  final int danmaku;

  /// 点赞数
  final int? like;

  /// 推荐理由
  final String? rcmdReason;

  /// 跳转类型
  final String? goto;

  /// 跳转参数
  final int? param;

  /// URI
  final String? uri;

  /// 描述
  final String? desc;

  /// 卡片类型
  final String? cardType;

  /// PGC 徽章
  final String? pgcBadge;

  /// 是否已关注
  final int isFollowed;

  /// 缓存时间戳
  final int cachedAt;

  /// 缓存过期时间戳
  final int expireAt;

  HomeCacheEntity({
    required this.id,
    required this.aid,
    required this.bvid,
    required this.cid,
    required this.cover,
    required this.title,
    required this.ownerMid,
    required this.ownerName,
    this.ownerFace,
    required this.duration,
    required this.view,
    required this.danmaku,
    this.like,
    this.rcmdReason,
    this.goto,
    this.param,
    this.uri,
    this.desc,
    this.cardType,
    this.pgcBadge,
    required this.isFollowed,
    required this.cachedAt,
    required this.expireAt,
  });

  /// 从数据库行创建实体
  factory HomeCacheEntity.fromMap(Map<String, dynamic> map) {
    return HomeCacheEntity(
      id: map['id'] as int,
      aid: map['aid'] as int,
      bvid: map['bvid'] as String,
      cid: map['cid'] as int,
      cover: map['cover'] as String,
      title: map['title'] as String,
      ownerMid: map['owner_mid'] as int,
      ownerName: map['owner_name'] as String,
      ownerFace: map['owner_face'] as String?,
      duration: map['duration'] as int,
      view: map['view'] as int,
      danmaku: map['danmaku'] as int,
      like: map['like'] as int?,
      rcmdReason: map['rcmd_reason'] as String?,
      goto: map['goto'] as String?,
      param: map['param'] as int?,
      uri: map['uri'] as String?,
      desc: map['desc'] as String?,
      cardType: map['card_type'] as String?,
      pgcBadge: map['pgc_badge'] as String?,
      isFollowed: map['is_followed'] as int,
      cachedAt: map['cached_at'] as int,
      expireAt: map['expire_at'] as int,
    );
  }

  /// 转换为数据库行（包含 id）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aid': aid,
      'bvid': bvid,
      'cid': cid,
      'cover': cover,
      'title': title,
      'owner_mid': ownerMid,
      'owner_name': ownerName,
      'owner_face': ownerFace,
      'duration': duration,
      'view': view,
      'danmaku': danmaku,
      'like': like,
      'rcmd_reason': rcmdReason,
      'goto': goto,
      'param': param,
      'uri': uri,
      'desc': desc,
      'card_type': cardType,
      'pgc_badge': pgcBadge,
      'is_followed': isFollowed,
      'cached_at': cachedAt,
      'expire_at': expireAt,
    };
  }

  /// 转换为用于插入的数据库行（不包含 id，让数据库自动生成）
  Map<String, dynamic> toInsertMap() {
    return {
      'aid': aid,
      'bvid': bvid,
      'cid': cid,
      'cover': cover,
      'title': title,
      'owner_mid': ownerMid,
      'owner_name': ownerName,
      'owner_face': ownerFace,
      'duration': duration,
      'view': view,
      'danmaku': danmaku,
      'like': like,
      'rcmd_reason': rcmdReason,
      'goto': goto,
      'param': param,
      'uri': uri,
      'desc': desc,
      'card_type': cardType,
      'pgc_badge': pgcBadge,
      'is_followed': isFollowed,
      'cached_at': cachedAt,
      'expire_at': expireAt,
    };
  }

  /// 检查是否已过期
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch > expireAt;
  }

  /// 复制并修改部分字段
  HomeCacheEntity copyWith({
    int? id,
    int? aid,
    String? bvid,
    int? cid,
    String? cover,
    String? title,
    int? ownerMid,
    String? ownerName,
    String? ownerFace,
    int? duration,
    int? view,
    int? danmaku,
    int? like,
    String? rcmdReason,
    String? goto,
    int? param,
    String? uri,
    String? desc,
    String? cardType,
    String? pgcBadge,
    int? isFollowed,
    int? cachedAt,
    int? expireAt,
  }) {
    return HomeCacheEntity(
      id: id ?? this.id,
      aid: aid ?? this.aid,
      bvid: bvid ?? this.bvid,
      cid: cid ?? this.cid,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      ownerMid: ownerMid ?? this.ownerMid,
      ownerName: ownerName ?? this.ownerName,
      ownerFace: ownerFace ?? this.ownerFace,
      duration: duration ?? this.duration,
      view: view ?? this.view,
      danmaku: danmaku ?? this.danmaku,
      like: like ?? this.like,
      rcmdReason: rcmdReason ?? this.rcmdReason,
      goto: goto ?? this.goto,
      param: param ?? this.param,
      uri: uri ?? this.uri,
      desc: desc ?? this.desc,
      cardType: cardType ?? this.cardType,
      pgcBadge: pgcBadge ?? this.pgcBadge,
      isFollowed: isFollowed ?? this.isFollowed,
      cachedAt: cachedAt ?? this.cachedAt,
      expireAt: expireAt ?? this.expireAt,
    );
  }
}
