/// 直播流连接配置实体
library;

/// 直播流连接配置
class LiveStreamConnectionConfig {
  /// 房间ID
  final int roomId;

  /// 用户ID
  final int uid;

  /// 流令牌
  final String streamToken;

  /// WebSocket服务器列表
  final List<String> servers;

  const LiveStreamConnectionConfig({
    required this.roomId,
    required this.uid,
    required this.streamToken,
    required this.servers,
  });

  @override
  String toString() {
    return 'LiveStreamConnectionConfig{roomId: $roomId, uid: $uid, servers: ${servers.length}}';
  }
}
