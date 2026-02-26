/// Article statistics entity
class ArticleStatEntity {
  final int? like;
  final int? favorite;
  final int? reply;
  final int? share;
  final bool? isLiked;
  final bool? isFavorited;

  const ArticleStatEntity({
    this.like,
    this.favorite,
    this.reply,
    this.share,
    this.isLiked,
    this.isFavorited,
  });
}

/// Opus article content entity
class OpusContentEntity {
  final String? id;
  final String? idStr;
  final String? title;
  final String? cover;
  final int? publishTime;
  final String? commentIdStr;
  final int? commentType;
  final List<dynamic>? content;
  final ArticleStatEntity? stat;

  const OpusContentEntity({
    this.id,
    this.idStr,
    this.title,
    this.cover,
    this.publishTime,
    this.commentIdStr,
    this.commentType,
    this.content,
    this.stat,
  });
}

/// Read article content entity
class ReadContentEntity {
  final String? id;
  final String? title;
  final String? cover;
  final int? publishTime;
  final String? dynIdStr;
  final String? content;
  final String? originImageUrl;
  final int? type;
  final List<dynamic>? ops;

  const ReadContentEntity({
    this.id,
    this.title,
    this.cover,
    this.publishTime,
    this.dynIdStr,
    this.content,
    this.originImageUrl,
    this.type,
    this.ops,
  });
}
