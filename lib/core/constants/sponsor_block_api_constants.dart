/// SponsorBlock 相关 API 常量
///
/// 定义所有 SponsorBlock 相关的 API 端点
library;

/// SponsorBlock 相关 API 常量
abstract class SponsorBlockApiConstants {
  /// 获取跳过片段
  static const String skipSegments = 'skipSegments';

  /// 对片段投票
  static const String voteOnSponsorTime = 'voteOnSponsorTime';

  /// 标记片段已查看
  static const String viewedVideoSponsorTime = 'viewedVideoSponsorTime';

  /// 端口视频（B站 <-> YouTube 绑定）
  static const String portVideo = 'portVideo';

  /// 用户信息
  static const String userInfo = 'userInfo';

  /// 服务状态
  static const String uptimeStatus = 'status/uptime';
}
