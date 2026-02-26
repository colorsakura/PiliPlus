/// AI总结实体
///
/// 视频AI生成的总结内容
class VideoAIConclusionEntity {
  /// 总结状态
  final int? code;

  /// 总结内容
  final String? conclusion;

  /// 总结要点列表
  final List<String>? keyPoints;

  /// 模型信息
  final String? model;

  const VideoAIConclusionEntity({
    this.code,
    this.conclusion,
    this.keyPoints,
    this.model,
  });

  VideoAIConclusionEntity copyWith({
    int? code,
    String? conclusion,
    List<String>? keyPoints,
    String? model,
  }) {
    return VideoAIConclusionEntity(
      code: code ?? this.code,
      conclusion: conclusion ?? this.conclusion,
      keyPoints: keyPoints ?? this.keyPoints,
      model: model ?? this.model,
    );
  }

  /// 从API响应创建实体
  factory VideoAIConclusionEntity.fromMap(Map<String, dynamic> map) {
    final summary = map['summary'] as Map<String, dynamic>?;
    final model = map['model'] as String?;

    final points = summary?['points'];
    List<String>? keyPointsList;
    if (points != null && points is List) {
      keyPointsList = List<String>.from(points);
    }

    return VideoAIConclusionEntity(
      code: map['code'] as int?,
      conclusion: summary?['text'] as String?,
      model: model,
      keyPoints: keyPointsList,
    );
  }
}
