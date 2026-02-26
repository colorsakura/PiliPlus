/// 视频播放信息实体
///
/// 包含视频播放时的统计信息
class VideoPlayInfoEntity {
  /// 当前观看进度（秒）
  final int progress;

  /// 播放时长（秒）
  final int duration;

  /// 是否已看完
  final bool isFinished;

  const VideoPlayInfoEntity({
    required this.progress,
    required this.duration,
    this.isFinished = false,
  });

  VideoPlayInfoEntity copyWith({
    int? progress,
    int? duration,
    bool? isFinished,
  }) {
    return VideoPlayInfoEntity(
      progress: progress ?? this.progress,
      duration: duration ?? this.duration,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  /// 从API响应创建实体
  factory VideoPlayInfoEntity.fromMap(Map<String, dynamic> map) {
    return VideoPlayInfoEntity(
      progress: map['progress'] as int? ?? 0,
      duration: map['duration'] as int? ?? 0,
      isFinished: map['finished'] as bool? ?? false,
    );
  }
}
