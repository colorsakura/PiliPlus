/// 直播流仓库接口
library;

import 'package:PiliPlus/features/live_room/domain/entities/connection_config.dart';
import 'package:PiliPlus/features/live_room/domain/entities/live_message.dart';

/// 直播流仓库接口
abstract class LiveStreamRepository {
  /// 连接直播间
  ///
  /// 连接成功返回空字符串，失败返回错误消息
  Future<String?> connect(
    LiveStreamConnectionConfig config,
  );

  /// 监听消息流
  ///
  /// 返回直播消息流，需要在连接成功后调用
  Stream<LiveMessage> get messageStream;

  /// 发送心跳
  Future<void> sendHeartbeat();

  /// 断开连接
  Future<void> disconnect();

  /// 当前连接状态
  bool get isConnected;
}
