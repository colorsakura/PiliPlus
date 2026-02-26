/// Music detail entity
class MusicDetailEntity {
  final String? musicId;
  final String? title;
  final String? author;
  final String? cover;
  final String? audioUrl;
  final int? duration;
  final bool? isLiked;
  final int? likeCount;
  final int? playCount;
  final MusicCommentEntity? comment;

  const MusicDetailEntity({
    this.musicId,
    this.title,
    this.author,
    this.cover,
    this.audioUrl,
    this.duration,
    this.isLiked,
    this.likeCount,
    this.playCount,
    this.comment,
  });
}

/// Music comment entity
class MusicCommentEntity {
  final int? oid;
  final int? pageType;
  final int? count;

  const MusicCommentEntity({
    this.oid,
    this.pageType,
    this.count,
  });
}

/// Music recommend entity
class MusicRecommendEntity {
  final String? musicId;
  final String? title;
  final String? author;
  final String? cover;
  final int? duration;

  const MusicRecommendEntity({
    this.musicId,
    this.title,
    this.author,
    this.cover,
    this.duration,
  });
}
