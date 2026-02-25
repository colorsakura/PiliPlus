/// 动态相关 API 常量
///
/// 定义所有动态相关的 API 端点
library;

/// 动态相关 API 常量
abstract class DynamicsApiConstants {
  // ==================== 动态列表 ====================
  /// 关注动态列表
  static const String followDynamic = '/x/polymer/web-dynamic/v1/feed/all';

  /// UP主列表
  static const String dynUplist = '/x/polymer/web-dynamic/v1/uplist';

  /// 关注推荐
  static const String followUp = '/x/polymer/web-dynamic/v1/portal';

  // ==================== 动态详情 ====================
  /// 动态详情
  static const String dynamicDetail = '/x/polymer/web-dynamic/v1/detail';

  /// 图文详情
  static const String dynPic = '/x/polymer/web-dynamic/v1/detail/pic';

  /// 专栏详情（opus）
  static const String opusDetail = '/x/polymer/web-dynamic/v1/opus/detail';

  // ==================== 动态互动 ====================
  /// 动态点赞
  static const String thumbDynamic = '/x/dynamic/feed/dyn/thumb';

  /// 动态置顶
  static const String setTopDyn = '/x/dynamic/feed/space/set_top';

  /// 取消置顶
  static const String rmTopDyn = '/x/dynamic/feed/space/rm_top';

  // ==================== 动态创建/编辑 ====================
  /// 创建动态
  static const String createDynamic = '/x/dynamic/feed/create/dyn';

  /// 创建文本动态
  static const String createTextDynamic = '/dynamic_svr/v1/dynamic_svr/create';

  /// 编辑动态
  static const String editDyn = '/x/dynamic/feed/edit/dyn';

  // ==================== 专栏相关 ====================
  /// 专栏信息
  static const String articleInfo = '/x/article/viewinfo';

  /// 专栏阅读
  static const String articleView = '/x/article/view';

  /// 专栏列表
  static const String articleList = '/x/article/list/web/articles';

  // ==================== 投票相关 ====================
  /// 投票信息
  static const String voteInfo = '/x/vote/vote_info';

  /// 进行投票
  static const String doVote = '/x/vote/do_vote';

  /// 创建投票
  static const String createVote = '/x/vote/create';

  /// 更新投票
  static const String updateVote = '/x/vote/update';

  /// 关注的用户投票
  static const String followeeVotes = '/x/polymer/web-dynamic/v1/up/vote';

  // ==================== 话题相关 ====================
  /// 话题详情
  static const String topicTop = '/x/polymer/web-dynamic/v1/topic/detail';

  /// 话题动态流
  static const String topicFeed = '/x/polymer/web-dynamic/v1/feed/topic';

  /// 话题推荐
  static const String dynTopicRcmd = '/x/topic/web/dynamic/rcmd';

  // ==================== 预约相关 ====================
  /// 点击预约
  static const String dynReserve = '/x/dynamic/feed/reserve/click';

  /// 创建预约
  static const String createReserve = '/x/new-reserve/up/reserve/create';

  /// 更新预约
  static const String updateReserve = '/x/new-reserve/up/reserve/update';

  /// 预约信息
  static const String reserveInfo = '/x/new-reserve/up/reserve/info';

  // ==================== 提及相关 ====================
  /// @提及搜索
  static const String dynMention = '/x/polymer/web-dynamic/v1/mention/search';

  // ==================== 私密设置 ====================
  /// 动态私密发布设置
  static const String dynPrivatePubSetting = '/x/dynamic/feed/private/setting';
}
