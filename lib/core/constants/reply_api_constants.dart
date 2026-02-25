/// 评论相关 API 常量
///
/// 定义所有评论相关的 API 端点
library;

/// 评论相关 API 常量
abstract class ReplyApiConstants {
  // ==================== 评论列表 ====================
  /// 评论列表
  static const String replyList = '/x/v2/reply';

  /// 楼中楼评论列表
  static const String replyReplyList = '/x/v2/reply/reply';

  // ==================== 评论互动 ====================
  /// 评论点赞
  static const String likeReply = '/x/v2/reply/action';

  /// 评论踩/取消踩
  static const String hateReply = '/x/v2/reply/hate';

  /// 评论区互动信息
  static const String replyInteraction = '/x/v2/reply/main/reply/interaction';

  // ==================== 评论操作 ====================
  /// 设置评论置顶
  static const String replyTop = '/x/v2/reply/top';

  /// 修改评论主体信息
  static const String replySubjectModify = '/x/v2/reply/subject/modify';

  // ==================== 表情相关 ====================
  /// 用户表情面板
  static const String myEmote = '/x/emote/user/panel/web';
}
