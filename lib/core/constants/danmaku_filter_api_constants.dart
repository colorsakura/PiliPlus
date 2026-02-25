/// 弹幕过滤相关 API 常量
///
/// 定义所有弹幕过滤相关的 API 端点
library;

/// 弹幕过滤相关 API 常量
abstract class DanmakuFilterApiConstants {
  /// 获取弹幕过滤规则
  static const String danmakuFilter = '/x/dm/filter/user';

  /// 添加弹幕过滤规则
  static const String danmakuFilterAdd = '/x/dm/filter/user/add';

  /// 删除弹幕过滤规则
  static const String danmakuFilterDel = '/x/dm/filter/user/del';
}
