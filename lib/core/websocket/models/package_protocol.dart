/// 协议包模型
library;

import 'dart:typed_data';

/// 协议包头
class PackageHeader {
  final int protocolVer;
  final int operationCode;
  final int seq;

  const PackageHeader({
    required this.protocolVer,
    required this.operationCode,
    required this.seq,
  });

  @override
  String toString() {
    return 'PackageHeader{protocolVer: $protocolVer, operationCode: $operationCode, seq: $seq}';
  }

  /// 将包头转换为字节数组
  Uint8List toBytes(int contentSize) {
    final bytes = ByteData(0x10)
      ..setInt32(0, 0x10 + contentSize, Endian.big)
      ..setInt16(4, 0x10, Endian.big)
      ..setInt16(6, protocolVer, Endian.big)
      ..setInt32(8, operationCode, Endian.big)
      ..setInt32(12, seq, Endian.big);
    return bytes.buffer.asUint8List();
  }
}

/// 响应协议包头
class PackageHeaderRes extends PackageHeader {
  final int totalSize;
  final int headerSize;

  const PackageHeaderRes({
    required this.totalSize,
    required this.headerSize,
    required super.protocolVer,
    required super.operationCode,
    required super.seq,
  });

  /// 从字节数据解析包头
  static PackageHeaderRes? fromBytesData(Uint8List data) {
    if (data.length < 16) {
      return null;
    }
    final byteData = ByteData.sublistView(data);

    final totalSize = byteData.getUint32(0, Endian.big);
    final headerSize = byteData.getUint16(4, Endian.big);
    final protocolVer = byteData.getUint16(6, Endian.big);
    final operationCode = byteData.getUint32(8, Endian.big);
    final seq = byteData.getUint32(12, Endian.big);

    return PackageHeaderRes(
      totalSize: totalSize,
      headerSize: headerSize,
      protocolVer: protocolVer,
      operationCode: operationCode,
      seq: seq,
    );
  }

  @override
  String toString() {
    return 'PackageHeaderRes{totalSize: $totalSize, headerSize: $headerSize, protocolVer: $protocolVer, operationCode: $operationCode, seq: $seq}';
  }
}

/// 操作码常量
class OperationCode {
  /// 心跳请求
  static const int heartbeat = 2;

  /// 心跳响应
  static const int heartbeatReply = 3;

  /// 认证请求
  static const int auth = 7;

  /// 认证响应
  static const int authReply = 8;

  /// 消息请求
  static const int message = 9;

  /// 消息响应
  static const int messageReply = 10;
}

/// 协议版本常量
class ProtocolVersion {
  /// JSON格式
  static const int json = 0;

  /// 也是JSON
  static const int jsonV1 = 1;

  /// GZIP压缩
  static const int gzip = 2;

  /// Brotli压缩
  static const int brotli = 3;
}
