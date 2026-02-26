/// 视频关系实体
///
/// 表示用户与视频的交互状态（点赞、投币、收藏）
class VideoRelationEntity {
  /// 是否已点赞
  final bool liked;

  /// 是否已投币
  final int coined; // 0: 未投币, 1: 投1币, 2: 投2币

  /// 是否已收藏
  final bool favorited;

  /// 投币数量
  final int coinCount;

  /// 收藏数
  final int favoriteCount;

  /// 点赞数
  final int likeCount;

  const VideoRelationEntity({
    required this.liked,
    required this.coined,
    required this.favorited,
    this.coinCount = 0,
    this.favoriteCount = 0,
    this.likeCount = 0,
  });

  VideoRelationEntity copyWith({
    bool? liked,
    int? coined,
    bool? favorited,
    int? coinCount,
    int? favoriteCount,
    int? likeCount,
  }) {
    return VideoRelationEntity(
      liked: liked ?? this.liked,
      coined: coined ?? this.coined,
      favorited: favorited ?? this.favorited,
      coinCount: coinCount ?? this.coinCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }

  /// 从模型创建实体
  factory VideoRelationEntity.fromMap(Map<String, dynamic> map) {
    return VideoRelationEntity(
      liked: map['like'] == true || map['like'] == 1,
      coined: map['coin'] as int? ?? 0,
      favorited: map['favorite'] == true || map['favorite'] == 1,
      coinCount: map['coin_number'] as int? ?? 0,
      favoriteCount: map['fav_number'] as int? ?? 0,
      likeCount: map['like_number'] as int? ?? 0,
    );
  }
}
