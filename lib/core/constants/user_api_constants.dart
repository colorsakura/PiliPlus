/// 用户相关 API 常量
///
/// 定义所有用户相关的 API 端点
library;

/// 用户相关 API 常量
abstract class UserApiConstants {
  /// 用户导航信息
  static const String userInfo = '/x/web-interface/nav';

  /// 用户统计数据（所有者）
  static const String userStatOwner = '/x/web-interface/nav/stat';

  /// 稍后再看列表
  static const String seeYouLater = '/x/v2/history/toview/web';

  /// 观看历史列表
  static const String historyList = '/x/web-interface/history/cursor';

  /// 观看历史暂停状态
  static const String historyStatus = '/x/v2/history/shadow?jsonp=jsonp';

  /// 暂停观看历史
  static const String pauseHistory = '/x/v2/history/shadow/set';

  /// 清空观看历史
  static const String clearHistory = '/x/v2/history/clear';

  /// 删除观看历史
  static const String delHistory = '/x/v2/history/delete';

  /// 搜索观看历史
  static const String searchHistory = '/x/web-interface/history/search';

  /// 添加到稍后再看
  static const String toViewLater = '/x/v2/history/toview/add';

  /// 从稍后再看删除
  static const String toViewDel = '/x/v2/history/toview/v2/dels';

  /// 清空稍后再看
  static const String toViewClear = '/x/v2/history/toview/clear';

  /// 关系API
  static const String relation = '/x/relation';

  /// 用户收藏夹列表
  static const String userSubFolder = '/x/v3/fav/folder/collected/list';

  /// 视频标签
  static const String videoTags = '/x/web-interface/view/detail/tag';

  /// 媒体列表
  static const String mediaList = '/x/v2/medialist/resource/list';

  /// 获取硬币数量
  static const String getCoin = '/x/space/acc/info';

  /// 动态举报
  static const String dynamicReport = '/x/dynamic/feed/dynamic_report/add';

  /// 空间设置
  static const String spaceSetting = '/x/space/setting/app';

  /// 修改空间设置
  static const String spaceSettingMod = '/x/space/privacy/batch/modify';

  /// VIP经验增加
  static const String vipExpAdd = '/x/vip/experience/add';

  /// 硬币日志
  static const String coinLog = '/x/member/web/coin/log';

  /// 登录日志
  static const String loginLog = '/x/member/web/login/log';

  /// 经验日志
  static const String expLog = '/x/member/web/exp/log';

  /// UP主实名信息
  static const String userRealName = '/x/member/app/up/realname';

  /// 关注的UP主
  static const String followedUp = '/x/relation/followings/followed_upper';

  /// 共同关注
  static const String sameFollowing = '/x/relation/same/followings';
}
