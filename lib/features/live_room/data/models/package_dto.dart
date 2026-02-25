/// 协议包DTO
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:PiliPlus/core/websocket/models/package_protocol.dart';
import 'package:PiliPlus/features/live_room/data/models/auth_message_dto.dart';

/// 抽象包接口
abstract class Package {
  PackageHeader get header;
  Uint8List marshal();
}

/// 认证包
class AuthPackage implements Package {
  @override
  final PackageHeader header;
  final AuthMessage body;

  const AuthPackage({
    required this.header,
    required this.body,
  });

  @override
  Uint8List marshal() {
    final json = utf8.encode(body.toJsonStr());
    final buffer = BytesBuilder()
      ..add(header.toBytes(json.length))
      ..add(json);
    return buffer.toBytes();
  }
}

/// 心跳包
class HeartbeatPackage implements Package {
  @override
  final PackageHeader header;

  const HeartbeatPackage({required this.header});

  @override
  Uint8List marshal() {
    return header.toBytes(0);
  }
}
