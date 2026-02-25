/// 消息相关 API 常量
///
/// 定义所有消息相关的 API 端点
library;

/// 消息相关 API 常量
abstract class MsgApiConstants {
  /// 消息未读数
  static const String msgUnread = '/session_svr/v1/session_svr/single_unread';

  /// 消息中心未读信息
  static const String msgFeedUnread = '/x/msgfeed/unread';

  /// 回复我的
  static const String msgFeedReply = '/x/msgfeed/reply';

  /// @我的
  static const String msgFeedAt = '/x/msgfeed/at';

  /// 收到的赞
  static const String msgFeedLike = '/x/msgfeed/like';

  /// 赞详情
  static const String msgLikeDetail = '/x/msgfeed/like_detail';

  /// 系统通知
  static const String msgSysNotify = '/x/sys-msg/query_notify_list';

  /// 系统消息光标更新（已读标记）
  static const String msgSysUpdateCursor = '/x/sys-msg/update_cursor';

  /// 上传图片
  static const String uploadImage = '/x/upload/web/image';

  /// 上传BFS
  static const String uploadBfs = '/x/dynamic/feed/draw/upload_bfs';

  /// 创建动态
  static const String createDynamic = '/x/dynamic/feed/create/dyn';

  /// 删除动态
  static const String removeDynamic = '/x/dynamic/feed/operate/remove';

  /// 移除会话
  static const String removeMsg = '/session_svr/v1/session_svr/remove_session';

  /// 删除消息
  static const String delMsgfeed = '/x/msgfeed/del';

  /// 删除系统消息
  static const String delSysMsg = '/x/sys-msg/del_notify_list';

  /// 设置置顶
  static const String setTop = '/session_svr/v1/session_svr/set_top';

  /// 确认会话消息已读
  static const String ackSessionMsg = '/chat_svr/v1/chat_svr/ack_session_msg';

  /// 发送消息
  static const String sendMsg = '/web_im/v1/web_im/send_msg';

  /// 消息通知设置
  static const String msgSetNotice = '/x/msgfeed/notice';

  /// 设置消息勿扰
  static const String setMsgDnd = '/link_setting/v1/link_setting/set_msg_dnd';

  /// 用户信息
  static const String imUserInfos = '/x/im/user_infos';

  /// 获取会话设置
  static const String getSessionSs =
      '/link_setting/v1/link_setting/get_session_ss';

  /// 获取消息勿扰设置
  static const String getMsgDnd = '/link_setting/v1/link_setting/get_msg_dnd';

  /// 设置推送设置
  static const String setPushSs = '/link_setting/v1/link_setting/set_push_ss';

  /// IM消息举报
  static const String imMsgReport = '/x/bplus/im/report/add';
}
