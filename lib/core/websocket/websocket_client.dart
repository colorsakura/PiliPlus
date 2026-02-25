/// 通用WebSocket客户端
library;

import 'dart:async';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket连接状态
enum WebSocketState {
  /// 连接中
  connecting,
  /// 已连接
  connected,
  /// 已断开
  disconnected,
  /// 错误
  error,
}

/// WebSocket连接配置
class WebSocketConfig {
  final List<String> servers;
  final Duration connectionTimeout;
  final int maxRetries;

  const WebSocketConfig({
    required this.servers,
    this.connectionTimeout = const Duration(seconds: 10),
    this.maxRetries = 3,
  });
}

/// 通用WebSocket客户端
class WebSocketClient {
  WebSocketChannel? _channel;
  final _stateController = StreamController<WebSocketState>.broadcast();
  final _dataController = StreamController<Uint8List>.broadcast();

  /// 当前连接状态
  WebSocketState _state = WebSocketState.disconnected;

  /// 状态流
  Stream<WebSocketState> get stateStream => _stateController.stream;

  /// 数据流
  Stream<Uint8List> get dataStream => _dataController.stream;

  /// 当前状态
  WebSocketState get state => _state;

  /// 是否已连接
  bool get isConnected => _state == WebSocketState.connected;

  /// 连接到WebSocket服务器
  ///
  /// 尝试按顺序连接到配置的服务器列表，直到成功或全部失败
  Future<void> connect(WebSocketConfig config) async {
    if (_state == WebSocketState.connected) {
      await close();
    }

    for (final server in config.servers) {
      try {
        _setState(WebSocketState.connecting);
        _channel = WebSocketChannel.connect(Uri.parse(server));
        await _channel!.ready.timeout(config.connectionTimeout);

        _setState(WebSocketState.connected);
        _channel!.stream.listen(
          _onData,
          onDone: _onDone,
          onError: _onError,
        );
        return;
      } catch (_) {
        await close();
        continue;
      }
    }
    _setState(WebSocketState.error);
    throw Exception('所有WebSocket服务器连接失败');
  }

  /// 发送数据
  void send(List<int> data) {
    if (!isConnected || _channel == null) {
      throw StateError('WebSocket未连接');
    }
    _channel!.sink.add(data);
  }

  /// 处理接收到的数据
  void _onData(dynamic data) {
    if (data is Uint8List) {
      _dataController.add(data);
    } else if (data is List<int>) {
      _dataController.add(Uint8List.fromList(data));
    }
  }

  /// 连接完成处理
  void _onDone() {
    _setState(WebSocketState.disconnected);
  }

  /// 错误处理
  void _onError(dynamic error) {
    _setState(WebSocketState.error);
  }

  /// 设置状态
  void _setState(WebSocketState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  /// 关闭连接
  Future<void> close() async {
    _setState(WebSocketState.disconnected);
    await _channel?.sink.close();
    _channel = null;
  }

  /// 释放资源
  void dispose() {
    close();
    _stateController.close();
    _dataController.close();
  }
}
