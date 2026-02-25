/// 视频相关 API 常量
///
/// 定义所有视频播放、详情、互动相关的 API 端点
library;

/// 视频相关 API 常量
abstract class VideoApiConstants {
  /// 首页推荐视频
  static const String recommendListApp = 'https://app.bilibili.com/x/v2/feed/index';
  static const String recommendListWeb = '/x/web-interface/wbi/index/top/feed/rcmd';

  /// APP端不感兴趣、取消不感兴趣
  static const String feedDislike = 'https://app.bilibili.com/x/feed/dislike';
  static const String feedDislikeCancel = 'https://app.bilibili.com/x/feed/dislike/cancel';

  /// 热门视频
  static const String hotList = '/x/web-interface/popular';

  // ==================== 视频流 ====================
  /// 番剧视频流
  static const String pgcUrl = '/pgc/player/web/v2/playurl';

  /// PUGV 视频流
  static const String pugvUrl = '/pugv/player/web/playurl';

  /// 电视播放 URL
  static const String tvPlayUrl = '/x/tv/playurl';

  /// 字幕
  static const String playInfo = '/x/player/wbi/v2';

  /// PGC 三连
  static const String pgcTriple = '/pgc/season/episode/like/triple';

  /// 收藏夹详情
  static const String favResourceList = '/x/v3/fav/resource/list';

  /// 用户信息
  static const String userInfo = '/x/web-interface/nav';

  /// 用户统计信息
  static const String userStatOwner = '/x/web-interface/nav/stat';

  /// 用户收藏夹列表
  static const String userFavFolder = '/x/v3/fav/folder/created/list';

  /// 收藏夹信息
  static const String favFolderInfo = '/x/v3/fav/folder/info';

  /// 关系查询
  static const String relation = '/x/relation';

  /// 用户关系
  static const String relations = '/x/relation/relations';

  /// 操作用户关系
  static const String relationMod = '/x/relation/modify';

  /// 评论列表
  static const String replyList = '/x/v2/reply';

  /// 楼中楼
  static const String replyReplyList = '/x/v2/reply/reply';

  /// 评论点赞
  static const String likeReply = '/x/v2/reply/action';

  /// 评论踩
  static const String hateReply = '/x/v2/reply/hate';

  /// 发表评论
  static const String replyAdd = '/x/v2/reply/add';

  /// 删除评论
  static const String replyDel = '/x/v2/reply/del';

  /// 用户统计
  static const String userStat = '/x/relation/stat';

  /// 我的表情
  static const String myEmote = '/x/emote/user/panel/web';

  /// PGC点赞投币收藏
  static const String pgcLikeCoinFav = '/pgc/season/episode/community';

  /// 视频详情页 相关视频
  /// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/videostream_url.md
  static const String ugcUrl = '/x/player/wbi/playurl';

  /// 番剧视频流
  static const String pgcUrl = '/pgc/player/web/v2/playurl';

  /// PUGV 视频流
  static const String pugvUrl = '/pugv/player/web/playurl';

  /// 电视播放 URL
  static const String tvPlayUrl = '/x/tv/playurl';

  /// 播放信息（字幕等）
  static const String playInfo = '/x/player/wbi/v2';

  /// 视频详情页 相关视频
  static const String relatedList = '/x/web-interface/archive/related';

  /// 热门合集列表
  static const String popularSeriesList = '/x/web-interface/wbi/series/general';

  /// 热门合集详情
  static const String popularSeriesOne = '/x/web-interface/wbi/series/seriesOne';

  /// 热门视频
  static const String popularPrecious = '/x/web-interface/popular/precious';

  /// PGC 排行
  static const String pgcRank = '/x/web-interface/ranking/v2';

  /// PGC Season 排行
  static const String pgcSeasonRank = '/x/web-interface/ranking/pgc/season';

  /// 视频笔记列表
  static const String archiveNoteList = '/x/web-interface/archive/notes/list';

  /// 视频排行
  static const String getRankApi = '/x/web-interface/ranking/v2';

  // ==================== 收藏相关 ====================
  /// 点赞视频（APP端）
  static const String likeVideo = 'https://app.bilibili.com/x/v2/view/like';

  /// 点踩视频（APP端）
  static const String dislikeVideo = 'https://app.bilibili.com/x/v2/view/dislike';

  /// 投币视频（APP端）
  static const String coinVideo = 'https://app.bilibili.com/x/v2/view/coin/add';

  /// 一键三连
  static const String ugcTriple = '/x/web-interface/archive/like/triple';

  /// PGC 三连
  static const String pgcTriple = '/pgc/season/episode/like/triple';

  /// PGC 点赞投币收藏
  static const String pgcLikeCoinFav = '/pgc/season/episode/community';

  // ==================== 收藏相关 ====================
  /// 收藏夹资源列表
  static const String favResourceList = '/x/v3/fav/resource/list';

  /// 收藏视频
  static const String favVideo = '/x/v3/fav/resource/batch-deal';

  /// 取消所有收藏
  static const String unfavAll = '/x/v3/fav/resource/unfav-all';

  /// 复制收藏
  static const String copyFav = '/x/v3/fav/resource/copy';

  /// 移动收藏
  static const String moveFav = '/x/v3/fav/resource/move';

  /// 清理收藏
  static const String cleanFav = '/x/v3/fav/resource/clean';

  /// 排序收藏
  static const String sortFav = '/x/v3/fav/resource/sort';

  /// 排序收藏夹
  static const String sortFavFolder = '/x/v3/fav/folder/sort';

  /// 收藏夹列表
  static const String favFolder = '/x/v3/fav/folder/created/list-all';

  /// 用户收藏夹列表
  static const String userFavFolder = '/x/v3/fav/folder/created/list';

  /// 收藏夹信息
  static const String favFolderInfo = '/x/v3/fav/folder/info';

  /// 添加收藏夹
  static const String addFolder = '/x/v3/fav/folder/add';

  /// 编辑收藏夹
  static const String editFolder = '/x/v3/fav/folder/edit';

  /// 删除收藏夹
  static const String deleteFolder = '/x/v3/fav/folder/del';

  /// 复制到稍后再看
  static const String copyToview = '/x/v2/history/toview/copy';

  /// 移动到稍后再看
  static const String moveToview = '/x/v2/history/toview/move';

  // ==================== 弹幕相关 ====================
  /// 发送弹幕
  static const String shootDanmaku = '/x/v2/dm/post';

  /// 弹幕过滤器
  static const String danmakuFilter = '/x/dm/filter/user';

  // ==================== 评论相关 ====================
  /// 评论列表
  static const String replyList = '/x/v2/reply';

  /// 楼中楼评论
  static const String replyReplyList = '/x/v2/reply/reply';

  /// 评论点赞
  static const String likeReply = '/x/v2/reply/action';

  /// 评论踩
  static const String hateReply = '/x/v2/reply/hate';

  /// 发表评论
  static const String replyAdd = '/x/v2/reply/add';

  /// 删除评论
  static const String replyDel = '/x/v2/reply/del';

  // ==================== AI 总结 ====================
  /// AI 视频总结
  static const String aiConclusion = '/x/web-interface/view/conclusion/get';

  /// AI 视频章节
  static const String aiChapter = '/x/web-interface/view/conclusion/chapter';

  // ==================== 视频 Tag ====================
  /// 视频 Tag
  static const String videoTags = '/x/web-interface/view/detail/tag';
}
