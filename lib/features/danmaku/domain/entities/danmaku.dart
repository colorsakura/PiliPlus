/// Danmaku entity
class DanmakuEntity {
  final String content;
  final int mode;
  final int? color;
  final int? fontSize;
  final int? progress;
  final bool? isColorful;
  final int? pool;

  const DanmakuEntity({
    required this.content,
    this.mode = 1, // 1-滚动
    this.color,
    this.fontSize,
    this.progress,
    this.isColorful,
    this.pool,
  });

  /// Scrolling danmaku (default)
  const DanmakuEntity.scrolling({
    required String content,
    int? color,
    int? fontSize,
    int? progress,
    bool? isColorful,
    int? pool,
  }) : this(
          content: content,
          mode: 1,
          color: color,
          fontSize: fontSize,
          progress: progress,
          isColorful: isColorful,
          pool: pool,
        );

  /// Bottom danmaku
  const DanmakuEntity.bottom({
    required String content,
    int? color,
    int? fontSize,
    int? progress,
    bool? isColorful,
    int? pool,
  }) : this(
          content: content,
          mode: 4,
          color: color,
          fontSize: fontSize,
          progress: progress,
          isColorful: isColorful,
          pool: pool,
        );

  /// Top danmaku
  const DanmakuEntity.top({
    required String content,
    int? color,
    int? fontSize,
    int? progress,
    bool? isColorful,
    int? pool,
  }) : this(
          content: content,
          mode: 5,
          color: color,
          fontSize: fontSize,
          progress: progress,
          isColorful: isColorful,
          pool: pool,
        );
}

/// Danmaku send result entity
class DanmakuSendResultEntity {
  final bool success;
  final String? message;
  final String? danmakuId;

  const DanmakuSendResultEntity({
    required this.success,
    this.message,
    this.danmakuId,
  });
}
