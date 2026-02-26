/// 持久化的热门视频数据
///
/// 用于 RiverPod 离线持久化的简化模型
class PersistedHotVideo {
  /// 视频列表（JSON 字符串）
  final List<Map<String, dynamic>> videos;

  /// 是否还有更多数据
  final bool hasMore;

  /// 当前页码
  final int currentPage;

  /// 缓存时间戳
  final int cachedAt;

  PersistedHotVideo({
    required this.videos,
    required this.hasMore,
    required this.currentPage,
    required this.cachedAt,
  });

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'videos': videos,
      'hasMore': hasMore,
      'currentPage': currentPage,
      'cachedAt': cachedAt,
    };
  }

  /// 从 JSON 创建
  factory PersistedHotVideo.fromJson(Map<String, dynamic> json) {
    return PersistedHotVideo(
      videos: (json['videos'] as List)
          .map((v) => Map<String, dynamic>.from(v))
          .toList(),
      hasMore: json['hasMore'] as bool,
      currentPage: json['currentPage'] as int,
      cachedAt: json['cachedAt'] as int,
    );
  }
}
