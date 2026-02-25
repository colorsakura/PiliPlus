/// 直播消息实体
library;

/// 直播消息实体
class LiveMessage {
  /// 操作码
  final int operationCode;

  /// 消息命令类型
  final String? cmd;

  /// 消息数据
  final Map<String, dynamic>? data;

  const LiveMessage({
    required this.operationCode,
    this.cmd,
    this.data,
  });

  /// 从JSON创建消息
  factory LiveMessage.fromJson(Map<String, dynamic> json) {
    return LiveMessage(
      operationCode: 0, // 操作码由协议层处理
      cmd: json['cmd'] as String?,
      data: json,
    );
  }

  /// 是否为弹幕消息
  bool get isDanmaku => cmd == 'DANMU_MSG';

  /// 是否为超级聊天消息
  bool get isSuperChat => cmd == 'SUPER_CHAT_MESSAGE';

  /// 是否为超级聊天删除消息
  bool get isSuperChatDelete => cmd == 'SUPER_CHAT_MESSAGE_DELETE';

  /// 是否为观看人数变化
  bool get isWatchedChange => cmd == 'WATCHED_CHANGE';

  /// 是否为在线排名变化
  bool get isOnlineRankChange => cmd == 'ONLINE_RANK_COUNT';

  /// 是否为房间信息变化
  bool get isRoomChange => cmd == 'ROOM_CHANGE';

  @override
  String toString() {
    return 'LiveMessage{operationCode: $operationCode, cmd: $cmd}';
  }
}
