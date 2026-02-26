/// 搜索结果基础实体
///
/// 所有搜索结果的基类
class SearchResultEntity {
  /// 结果类型
  final String? type;

  const SearchResultEntity({
    this.type,
  });
}

/// 搜索视频实体
class SearchVideoEntity extends SearchResultEntity {
  /// 视频ID
  final int? id;

  /// 视频AV号
  final int? aid;

  /// 视频BV号
  final String? bvid;

  /// 标题
  final String? title;

  /// 简介
  final String? desc;

  /// 封面
  final String? cover;

  /// 发布时间
  final int? pubdate;

  /// 创建时间
  final int? ctime;

  /// 时长（秒）
  final int? duration;

  /// UP主信息
  final SearchOwnerEntity? owner;

  /// 统计信息
  final SearchStatEntity? stat;

  /// 是否联合投稿
  final int? isUnionVideo;

  /// 标题列表（用于富文本显示）
  final List<({bool isEm, String text})>? titleList;

  const SearchVideoEntity({
    super.type,
    this.id,
    this.aid,
    this.bvid,
    this.title,
    this.desc,
    this.cover,
    this.pubdate,
    this.ctime,
    this.duration,
    this.owner,
    this.stat,
    this.isUnionVideo,
    this.titleList,
  });

  SearchVideoEntity copyWith({
    String? type,
    int? id,
    int? aid,
    String? bvid,
    String? title,
    String? desc,
    String? cover,
    int? pubdate,
    int? ctime,
    int? duration,
    SearchOwnerEntity? owner,
    SearchStatEntity? stat,
    int? isUnionVideo,
    List<({bool isEm, String text})>? titleList,
  }) {
    return SearchVideoEntity(
      type: type ?? this.type,
      id: id ?? this.id,
      aid: aid ?? this.aid,
      bvid: bvid ?? this.bvid,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      cover: cover ?? this.cover,
      pubdate: pubdate ?? this.pubdate,
      ctime: ctime ?? this.ctime,
      duration: duration != null ? duration : this.duration,
      owner: owner ?? this.owner,
      stat: stat ?? this.stat,
      isUnionVideo: isUnionVideo ?? this.isUnionVideo,
      titleList: titleList ?? this.titleList,
    );
  }
}

/// 搜索UP主信息实体
class SearchOwnerEntity {
  /// 用户ID
  final int? mid;

  /// 用户名
  final String? name;

  /// 头像
  final String? face;

  const SearchOwnerEntity({
    this.mid,
    this.name,
    this.face,
  });

  SearchOwnerEntity copyWith({
    int? mid,
    String? name,
    String? face,
  }) {
    return SearchOwnerEntity(
      mid: mid ?? this.mid,
      name: name ?? this.name,
      face: face ?? this.face,
    );
  }
}

/// 搜索统计信息实体
class SearchStatEntity {
  /// 播放数
  final int? view;

  /// 弹幕数
  final int? danmu;

  /// 收藏数
  final int? favorite;

  /// 评论数
  final int? reply;

  /// 点赞数
  final int? like;

  const SearchStatEntity({
    this.view,
    this.danmu,
    this.favorite,
    this.reply,
    this.like,
  });

  SearchStatEntity copyWith({
    int? view,
    int? danmu,
    int? favorite,
    int? reply,
    int? like,
  }) {
    return SearchStatEntity(
      view: view ?? this.view,
      danmu: danmu ?? this.danmu,
      favorite: favorite ?? this.favorite,
      reply: reply ?? this.reply,
      like: like ?? this.like,
    );
  }
}

/// 搜索用户实体
class SearchUserEntity extends SearchResultEntity {
  /// 用户ID
  final int? mid;

  /// 用户名
  final String? uname;

  /// 签名
  final String? usign;

  /// 粉丝数
  final int? fans;

  /// 投稿数
  final int? videos;

  /// 头像
  final String? upic;

  /// 直播状态
  final int? isLive;

  /// 直播间ID
  final int? roomId;

  /// 等级
  final int? level;

  const SearchUserEntity({
    super.type,
    this.mid,
    this.uname,
    this.usign,
    this.fans,
    this.videos,
    this.upic,
    this.isLive,
    this.roomId,
    this.level,
  });

  SearchUserEntity copyWith({
    String? type,
    int? mid,
    String? uname,
    String? usign,
    int? fans,
    int? videos,
    String? upic,
    int? isLive,
    int? roomId,
    int? level,
  }) {
    return SearchUserEntity(
      type: type ?? this.type,
      mid: mid ?? this.mid,
      uname: uname ?? this.uname,
      usign: usign ?? this.usign,
      fans: fans ?? this.fans,
      videos: videos ?? this.videos,
      upic: upic ?? this.upic,
      isLive: isLive ?? this.isLive,
      roomId: roomId ?? this.roomId,
      level: level ?? this.level,
    );
  }

  /// 是否正在直播
  bool get isLiveing => isLive == 1;
}
