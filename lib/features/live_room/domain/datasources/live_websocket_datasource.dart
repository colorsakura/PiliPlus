/// WebSocket数据源接口
library;

import 'dart:typed_data';

/// WebSocket数据源接口
///
/// 定义WebSocket连接的基本操作
abstract class LiveWebSocketDatasource {
  /// 连接WebSocket服务器
  Future<void> connect({
    required String url,
    required List<int> authData,
  });

  /// 监听数据流
  Stream<Uint8List> get dataStream;

  /// 发送心跳数据
  Future<void> sendHeartbeat(List<int> data);

  /// 关闭连接
  Future<void> close();

  /// 当前连接状态
  bool get isConnected;
}
