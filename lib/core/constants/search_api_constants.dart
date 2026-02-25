/// 搜索相关 API 常量
///
/// 定义所有搜索相关的 API 端点
library;

/// 搜索相关 API 常量
abstract class SearchApiConstants {
  // ==================== 搜索建议 ====================
  /// 搜索建议
  static const String searchSuggest =
      'https://s.search.bilibili.com/main/suggest';

  // ==================== 分类搜索 ====================
  /// 分类搜索
  static const String searchByType = '/x/web-interface/wbi/search/type';

  /// 综合搜索
  static const String searchAll = '/x/web-interface/wbi/search/all/v2';

  // ==================== PGC搜索 ====================
  /// 番剧信息
  static const String pgcInfo = '/pgc/view/web/season';

  /// 课程信息
  static const String pugvInfo = '/pugv/view/web/season';

  /// 剧集信息
  static const String episodeInfo = '/pgc/season/episode/web/info';

  /// AV号转CID
  static const String ab2c = '/x/player/pagelist';

  // ==================== 搜索推荐 ====================
  /// 搜索推荐
  static const String searchRecommend = '/x/v2/search/recommend';

  /// 搜索热搜榜
  static const String searchTrending = '/x/v2/search/trending/ranking';

  // ==================== 话题搜索 ====================
  /// 话题发布搜索
  static const String topicPubSearch = '/x/topic/pub/search';
}
