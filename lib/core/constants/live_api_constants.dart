/// 直播相关 API 常量
///
/// 定义所有直播相关的 API 端点
library;

/// 直播相关 API 常量
abstract class LiveApiConstants {
  /// 直播间信息
  static const String liveRoomInfo = '/xlive/web-room/v2/index/getRoomPlayInfo';

  /// 发送直播弹幕
  static const String sendLiveMsg = '/msg/send';

  /// 直播间信息（H5）
  static const String liveRoomInfoH5 =
      '/xlive/web-room/v1/index/getH5InfoByRoom';

  /// 直播间弹幕历史
  static const String liveRoomDmPrefetch = '/xlive/web-room/v1/dM/gethistory';

  /// 直播间弹幕 Token
  static const String liveRoomDmToken = '/xlive/web-room/v1/index/getDanmuInfo';

  /// 获取直播间表情
  static const String getLiveEmoticons =
      '/xlive/web-ucenter/v2/emoticon/GetEmoticons';

  /// 直播首页推荐
  static const String liveFeedIndex = '/xlive/app-interface/v2/index/feed';

  /// 关注的直播
  static const String liveFollow = '/xlive/web-ucenter/user/following';

  /// 直播第二页列表
  static const String liveSecondList = '/xlive/app-interface/v2/second/getList';

  /// 直播分区列表
  static const String liveAreaList =
      '/xlive/app-interface/v2/index/getAreaList';

  /// 直播房间分区列表
  static const String liveRoomAreaList = '/room/v1/Area/getList';

  /// 获取直播收藏标签
  static const String getLiveFavTag =
      '/xlive/app-interface/v2/second/get_fav_tag';

  /// 设置直播收藏标签
  static const String setLiveFavTag =
      '/xlive/app-interface/v2/second/set_fav_tag';

  /// 直播搜索
  static const String liveSearch = '/xlive/app-interface/v2/search_live';

  /// 根据用户获取直播信息
  static const String getLiveInfoByUser =
      '/xlive/web-room/v1/index/getInfoByUser';

  /// 直播静音设置
  static const String liveSetSilent = '/liveact/user_silent';

  /// 添加屏蔽关键词
  static const String addShieldKeyword =
      '/xlive/web-ucenter/v1/banned/AddShieldKeyword';

  /// 删除屏蔽关键词
  static const String delShieldKeyword =
      '/xlive/web-ucenter/v1/banned/DelShieldKeyword';

  /// 直播屏蔽用户
  static const String liveShieldUser = '/liveact/shield_user';

  /// 直播点赞上报
  static const String liveLikeReport =
      '/xlive/app-ucenter/v1/like_info_v3/like/likeReportV3';

  /// 超级聊天消息列表
  static const String superChatMsg = '/av/v1/SuperChat/getMessageList';

  /// 直播弹幕上报
  static const String liveDmReport = '/xlive/web-ucenter/v1/dMReport/Report';

  /// 直播贡献榜
  static const String liveContributionRank =
      '/xlive/general-interface/v1/rank/queryContributionRank';

  /// 超级聊天举报
  static const String superChatReport = '/av/v1/SuperChat/report';
}
