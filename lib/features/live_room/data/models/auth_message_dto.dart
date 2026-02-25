/// 认证消息DTO
library;

import 'dart:convert';

/// 抽象消息接口
abstract class Message {
  String toJsonStr();
}

/// 认证消息DTO
class AuthMessage implements Message {
  final int roomid;
  final int uid;
  final int protover;
  final String platform;
  final int type;
  final String key;

  const AuthMessage({
    required this.roomid,
    required this.uid,
    required this.protover,
    required this.platform,
    required this.type,
    required this.key,
  });

  @override
  String toJsonStr() {
    final message = {
      'roomid': roomid,
      'uid': uid,
      'protover': protover,
      'platform': platform,
      'type': type,
      'key': key,
    };
    return jsonEncode(message);
  }
}
