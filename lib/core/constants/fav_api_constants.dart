/// 收藏相关 API 常量
///
/// 定义所有收藏相关的 API 端点
library;

/// 收藏相关 API 常量
abstract class FavApiConstants {
  /// 收藏资源列表
  static const String favResourceList = '/x/v3/fav/resource/list';

  /// 收藏视频
  static const String favVideo = '/x/v3/fav/resource/batch-deal';

  /// 取消收藏所有
  static const String unfavAll = '/x/v3/fav/resource/unfav-all';

  /// 复制收藏
  static const String copyFav = '/x/v3/fav/resource/copy';

  /// 移动收藏
  static const String moveFav = '/x/v3/fav/resource/move';

  /// 清理失效收藏
  static const String cleanFav = '/x/v3/fav/resource/clean';

  /// 排序收藏
  static const String sortFav = '/x/v3/fav/resource/sort';

  /// 排序收藏夹
  static const String sortFavFolder = '/x/v3/fav/folder/sort';

  /// 复制到稍后再看
  static const String copyToview = '/x/v2/history/toview/copy';

  /// 移动到稍后再看
  static const String moveToview = '/x/v2/history/toview/move';

  /// 用户创建的收藏夹列表
  static const String userFavFolder = '/x/v3/fav/folder/created/list';

  /// 所有收藏夹列表
  static const String favFolder = '/x/v3/fav/folder/created/list-all';

  /// 收藏夹信息
  static const String favFolderInfo = '/x/v3/fav/folder/info';

  /// 添加收藏夹
  static const String addFolder = '/x/v3/fav/folder/add';

  /// 编辑收藏夹
  static const String editFolder = '/x/v3/fav/folder/edit';

  /// 删除收藏夹
  static const String deleteFolder = '/x/v3/fav/folder/del';

  /// 用户空间收藏夹
  static const String spaceFav = '/x/v3/fav/folder/space';

  /// 收藏PGC（番剧/影视）
  static const String favPgc = '/x/space/bangumi/follow/list';

  /// 收藏番剧列表
  static const String favSeasonList = '/x/space/fav/season/list';

  /// 取消收藏收藏夹
  static const String unfavFolder = '/x/v3/fav/folder/unfav';

  /// 收藏番剧
  static const String favSeason = '/x/v3/fav/season/fav';

  /// 取消收藏番剧
  static const String unfavSeason = '/x/v3/fav/season/unfav';

  /// 笔记列表
  static const String noteList = '/x/note/list';

  /// 用户发布的笔记列表
  static const String userNoteList = '/x/note/publish/list/user';

  /// 删除笔记
  static const String delNote = '/x/note/del';

  /// 删除已发布的笔记
  static const String delPublishNote = '/x/note/publish/del';

  /// 收藏的文章
  static const String favArticle = '/x/polymer/web-dynamic/v1/opus/feed/fav';

  /// 社区互动
  static const String communityAction = '/x/community/cosmo/interface/simple_action';

  /// 删除收藏的文章
  static const String delFavArticle = '/x/article/favorites/del';

  /// 添加收藏的文章
  static const String addFavArticle = '/x/article/favorites/add';

  /// 收藏课程
  static const String favPugv = '/pugv/app/web/favorite/page';

  /// 添加收藏课程
  static const String addFavPugv = '/pugv/app/web/favorite/add';

  /// 删除收藏课程
  static const String delFavPugv = '/pugv/app/web/favorite/del';

  /// 收藏话题列表
  static const String favTopicList = '/x/topic/web/fav/list';

  /// 添加收藏话题
  static const String addFavTopic = '/x/topic/fav/sub/add';

  /// 删除收藏话题
  static const String delFavTopic = '/x/topic/fav/sub/cancel';

  /// 点赞话题
  static const String likeTopic = '/x/topic/like';

  /// 收藏收藏夹
  static const String favFavFolder = '/x/v3/fav/folder/fav';

  /// 取消收藏收藏夹
  static const String unfavFavFolder = '/x/v3/fav/folder/unfav';
}
