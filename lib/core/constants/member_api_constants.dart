/// 成员相关 API 常量
///
/// 定义所有成员相关的 API 端点
library;

/// 成员相关 API 常量
abstract class MemberApiConstants {
  /// 举报成员
  static const String reportMember = '/x/member/web/report';

  /// 用户空间文章
  static const String spaceArticle = '/x/space/wbi/article';

  /// 用户空间番剧/系列列表
  static const String seasonSeries = '/x/polymer/web-space/seasons_series_list';

  /// 用户空间视频投稿
  static const String spaceArchive = '/x/space/wbi/arc';

  /// 用户空间充电投稿
  static const String spaceChargingArchive = '/x/space/wbi/arc/charging';

  /// 用户空间番剧投稿
  static const String spaceSeason = '/x/space/wbi/season/arc';

  /// 用户空间系列投稿
  static const String spaceSeries = '/x/space/wbi/series/arc';

  /// 用户空间国创投稿
  static const String spaceBangumi = '/x/space/wbi/bangumi/arc';

  /// 用户空间漫画投稿
  static const String spaceComic = '/x/v2/space/comic';

  /// 用户空间音频投稿
  static const String spaceAudio = '/audio/music-service/web/song/upper';

  /// 用户空间课程投稿
  static const String spaceCheese = '/pugv/app/web/season/page';

  /// 用户空间信息
  static const String space = '/x/space/wbi/acc/info';

  /// 成员信息
  static const String memberInfo = '/x/space/wbi/acc/info';

  /// 用户统计
  static const String userStat = '/x/relation/stat';

  /// 成员卡片信息
  static const String memberCardInfo = '/x/web-interface/card';

  /// 搜索投稿
  static const String searchArchive = '/x/space/wbi/arc/search';

  /// 成员动态
  static const String memberDynamic = '/x/polymer/web-dynamic/v1/feed/space';

  /// 搜索动态
  static const String dynSearch = '/x/polymer/web-dynamic/v1/feed/space/search';

  /// 关注分组
  static const String followUpTag = '/x/relation/tags';

  /// 添加特别关注
  static const String addSpecial = '/x/relation/tag/special/add';

  /// 删除特别关注
  static const String delSpecial = '/x/relation/tag/special/del';

  /// 批量添加关注
  static const String addUsers = '/x/relation/tags/addUsers';

  /// 关注分组列表
  static const String followUpGroup = '/x/relation/tag';

  /// 创建关注分组
  static const String createFollowTag = '/x/relation/tag/create';

  /// 修改关注分组
  static const String updateFollowTag = '/x/relation/tag/update';

  /// 删除关注分组
  static const String delFollowTag = '/x/relation/tag/del';

  /// 获取置顶视频
  static const String getTopVideo = '/x/space/top/arc';

  /// 获取成员浏览数据
  static const String getMemberView = '/x/space/upstat';

  /// 搜索关注
  static const String followSearch = '/x/relation/followings/search';

  /// 用户空间动态（opus）
  static const String spaceOpus = '/x/polymer/web-dynamic/v1/opus/feed/space';

  /// UP主影响力排行
  static const String upowerRank = '/x/upower/up/member/rank/v2';

  /// 投币视频列表
  static const String coinArc = '/x/v2/space/coinarc';

  /// 点赞视频列表
  static const String likeArc = '/x/v2/space/likearc';

  /// 用户空间商店
  static const String spaceShop =
      '/mall/community-hub/small_shop/feed/tab/item';
}
