/// WebSocket异常定义
library;

import 'package:PiliPlus/core/errors/exceptions.dart';

/// WebSocket连接异常
class WebSocketException extends AppException {
  @override
  final String message;

  WebSocketException(this.message);

  @override
  String toString() => 'WebSocketException: $message';
}

/// 协议解析异常
class ProtocolParseException extends AppException {
  @override
  final String message;

  ProtocolParseException(this.message);

  @override
  String toString() => 'ProtocolParseException: $message';
}
