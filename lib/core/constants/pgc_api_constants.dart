/// PGC（专业生成内容）相关 API 常量
///
/// 定义所有 PGC 相关的 API 端点
library;

/// PGC 相关 API 常量
abstract class PgcApiConstants {
  // ==================== PGC 索引 ====================
  /// PGC 索引条件
  static const String pgcIndexCondition = '/pgc/season/index/condition';

  /// PGC 索引结果
  static const String pgcIndexResult = '/pgc/season/index/result';

  // ==================== PGC 时间线 ====================
  /// PGC 时间线
  static const String pgcTimeline = '/pgc/web/timeline';

  // ==================== PGC 评论 ====================
  /// PGC 评论点赞
  static const String pgcReviewLike = '/pgc/review/action/like';

  /// PGC 评论踩
  static const String pgcReviewDislike = '/pgc/review/action/dislike';

  /// PGC 评论发布
  static const String pgcReviewPost = '/pgc/review/short/post';

  /// PGC 评论修改
  static const String pgcReviewMod = '/pgc/review/short/modify';

  /// PGC 评论删除
  static const String pgcReviewDel = '/pgc/review/short/del';

  // ==================== 季度状态 ====================
  /// 季度用户状态
  static const String seasonStatus = '/pgc/view/web/season/user/status';

  // ==================== PGC 收藏 ====================
  /// PGC 收藏列表
  static const String favPgc = '/x/space/bangumi/follow/list';
}
