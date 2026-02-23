// ignore_for_file: constant_identifier_names

/// 本地缓存相关键
///
/// 用于临时存储的数据，如搜索历史、黑名单等
abstract final class LocalCacheKeys {
  static const String historyPause = 'historyPause',
      blackMids = 'blackMids',
      danmakuFilterRules = 'danmakuFilterRules',
      mixinKey = 'mixinKey',
      timeStamp = 'timeStamp',
      buvid = 'buvid';
}
