import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';

/// 视频播放URL实体
///
/// 封装视频播放所需的URL和相关信息
class VideoPlayUrlEntity {
  /// 播放URL数据
  final PlayUrlModel? data;

  /// 是否可用
  final bool isAvailable;

  /// 错误信息
  final String? errorMessage;

  const VideoPlayUrlEntity({
    this.data,
    this.isAvailable = true,
    this.errorMessage,
  });

  VideoPlayUrlEntity copyWith({
    PlayUrlModel? data,
    bool? isAvailable,
    String? errorMessage,
  }) {
    return VideoPlayUrlEntity(
      data: data ?? this.data,
      isAvailable: isAvailable ?? this.isAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 获取可用视频质量列表
  List<VideoQuality> get availableQualities {
    if (data?.acceptQuality != null) {
      return data!.acceptQuality!
          .map((qn) => VideoQuality.fromCode(qn))
          .toList();
    }
    return [];
  }

  /// 获取当前视频质量
  VideoQuality? get currentQuality {
    if (data?.quality != null) {
      return VideoQuality.fromCode(data!.quality!);
    }
    return null;
  }
}
