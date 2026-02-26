/// WebSocket数据源实现
library;

import 'dart:async';
import 'dart:typed_data';
import 'package:PiliPlus/core/websocket/exceptions.dart';
import 'package:PiliPlus/features/live_room/domain/datasources/live_websocket_datasource.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket数据源实现
class LiveWebSocketDatasourceImpl implements LiveWebSocketDatasource {
  final _dataController = StreamController<Uint8List>.broadcast();
  StreamSubscription? _streamSubscription;

  WebSocketChannel? _channel;

  @override
  bool get isConnected => _channel != null;

  @override
  Future<void> connect({
    required String url,
    required List<int> authData,
  }) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;

      // 发送认证数据
      _channel!.sink.add(authData);

      // 监听数据流
      _streamSubscription = _channel!.stream.listen(
        (data) {
          if (data is Uint8List) {
            _dataController.add(data);
          } else if (data is List<int>) {
            _dataController.add(Uint8List.fromList(data));
          }
        },
        onDone: () {
          _dataController.close();
        },
        onError: (error) {
          _dataController.addError(error);
        },
      );
    } catch (e) {
      throw WebSocketException('WebSocket连接失败: $e');
    }
  }

  @override
  Stream<Uint8List> get dataStream => _dataController.stream;

  @override
  Future<void> sendHeartbeat(List<int> data) async {
    if (_channel == null) {
      throw WebSocketException('WebSocket未连接');
    }
    try {
      _channel!.sink.add(data);
    } catch (e) {
      throw WebSocketException('发送心跳失败: $e');
    }
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await _channel?.sink.close();
    _channel = null;
    await _dataController.close();
  }
}
