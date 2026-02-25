/// 直播相关 API 常量
///
/// 定义所有直播相关的 API 端点
library;

/// 直播相关 API 常量
abstract class LiveApiConstants {
  // ==================== 直播列表 ====================
  /// 直播推荐列表
  static const String liveList = 'https://api.live.bilibili.com/xlive/web-interface/v1/second/getUserRecommend';

  /// 直播首页推荐
  static const String liveFeedIndex = 'https://api.live.bilibili.com/xlive/web-interface/v1/webMain/getList';

  /// 关注的直播
  static const String liveFollow = 'https://api.live.bilibili.com/xlive/web-ucenter/v1/webUser/getFollowList';

  /// 直播分区列表
  static const String liveAreaList = 'https://api.live.bilibili.com/xlive/web-interface/v1/index/getAreaList';

  /// 直播房间分区列表
  static const String liveRoomAreaList = 'https://api.live.bilibili.com/xlive/web-interface/v1/webMain/getAreaRoomList';

  /// 直播搜索
  static const String liveSearch = 'https://api.live.bilibili.com/xlive/web-interface/v1/search/getSearchResult';

  // ==================== 直播间信息 ====================
  /// 直播间信息
  static const String liveRoomInfo = 'https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo';

  /// 直播间信息（H5）
  static const String liveRoomInfoH5 = 'https://api.live.bilibili.com/xlive/web-room/v1/index/getH5InfoByRoom';

  /// 直播间 init 请求
  static const String liveRoomInit = 'https://api.live.bilibili.com/xlive/web-room/v1/index/getInfoByRoom';

  // ==================== 弹幕相关 ====================
  /// 发送直播弹幕
  static const String sendLiveMsg = 'https://api.live.bilibili.com/msg/send';

  /// 直播间弹幕历史
  static const String liveRoomDmPrefetch = 'https://api.live.bilibili.com/xlive/web-room/v1/dM/gethistory';

  /// 直播间弹幕 Token
  static const String liveRoomDmToken = 'https://api.live.bilibili.com/xlive/web-room/v1/index/getDanmuInfo';

  // ==================== 礼物/超级聊天 ====================
  /// 超级聊天消息列表
  static const String superChatMsg = 'https://api.live.bilibili.com/av/v1/SuperChat/getMessageList';

  /// 礼物列表
  static const String giftList = 'https://api.live.bilibili.com/xlive/web-interface/v1/gift/getGiftConfig';

  /// 送礼物
  static const String sendGift = 'https://api.live.bilibili.com/xlive/web-interface/v1/gift/send';

  // ==================== 直播互动 ====================
  /// 直播点赞
  static const String likeReport = 'https://api.live.bilibili.com/xlive/web-ucenter/v1/webHeartBeat/likeReportV3';

  /// 直播弹幕互动上报
  static const String dmReport = 'https://api.live.bilibili.com/xlive/web-ucenter/v1/webHeartBeat/dmReport';

  /// 直播贡献排行榜
  static const String contributionRank = 'https://api.live.bilibili.com/xlive/web-room/v1/gift/getRoomGiftTopList';

  // ==================== 直播设置 ====================
  /// 直播免打扰设置
  static const String setSilent = 'https://api.live.bilibili.com/xlive/web-interface/v1/webUser/updateSilentConfigure';

  /// 直播屏蔽用户
  static const String shieldUser = 'https://api.live.bilibili.com/xlive/web-interface/v1/webUser/addFilter';

  // ==================== 直播日志 ====================
  /// 直播点赞日志
  static const String likeLog = 'https://api.live.bilibili.com/xlive/web-interface/v1/webHeartBeat/likeLogV3';

  /// 直播弹幕日志
  static const String dmLog = 'https://api.live.bilibili.com/xlive/web-interface/v1/webHeartBeat/dmLogV3';
}
