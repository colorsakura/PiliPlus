/// 直播流仓库实现
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:brotli/brotli.dart';
import 'package:PiliPlus/core/websocket/exceptions.dart';
import 'package:PiliPlus/core/websocket/models/package_protocol.dart';
import 'package:PiliPlus/features/live_room/data/datasources/live_websocket_datasource_impl.dart';
import 'package:PiliPlus/features/live_room/data/models/auth_message_dto.dart';
import 'package:PiliPlus/features/live_room/data/models/package_dto.dart';
import 'package:PiliPlus/features/live_room/domain/entities/connection_config.dart';
import 'package:PiliPlus/features/live_room/domain/entities/live_message.dart';
import 'package:PiliPlus/features/live_room/domain/repositories/live_stream_repository.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// 直播流仓库实现
class LiveStreamRepositoryImpl implements LiveStreamRepository {
  final LiveWebSocketDatasourceImpl datasource;
  final _messageController = StreamController<LiveMessage>.broadcast();
  Timer? _heartbeatTimer;
  int _heartbeatCount = 1;
  bool _isActive = true;
  final String _logTag = 'LiveStreamRepository';

  LiveStreamRepositoryImpl(this.datasource);

  @override
  bool get isConnected => datasource.isConnected;

  @override
  Future<String?> connect(
    LiveStreamConnectionConfig config,
  ) async {
    try {
      _isActive = true;

      // 创建认证包
      final authPackage = AuthPackage(
        header: const PackageHeader(
          protocolVer: 1,
          operationCode: OperationCode.auth,
          seq: 1,
        ),
        body: AuthMessage(
          roomid: config.roomId,
          uid: config.uid,
          protover: 3,
          platform: 'web',
          type: 2,
          key: config.streamToken,
        ),
      );

      // 尝试连接服务器
      bool connected = false;
      WebSocketException? lastError;

      for (final server in config.servers) {
        try {
          await datasource.connect(
            url: server,
            authData: authPackage.marshal(),
          );
          connected = true;
          break;
        } on WebSocketException catch (e) {
          lastError = e;
          continue;
        }
      }

      if (!connected) {
        return lastError?.message ?? '所有服务器连接失败';
      }

      // 检查是否在连接过程中被取消
      if (!_isActive) {
        await disconnect();
        return '连接已取消';
      }

      // 开始监听消息
      _startListening();

      return null; // 成功返回null
    } on WebSocketException catch (e) {
      return e.message;
    } catch (e) {
      return '连接失败: $e';
    }
  }

  /// 开始监听消息
  void _startListening() {
    datasource.dataStream.listen(
      _onData,
      onDone: () {
        if (kDebugMode) logger.i('$_logTag WebSocket连接已关闭');
      },
      onError: (error) {
        if (kDebugMode) logger.e('$_logTag WebSocket错误: $error');
      },
    );
  }

  /// 处理接收到的数据
  @pragma('vm:notify-debugger-on-exception')
  void _onData(Uint8List data) {
    try {
      final header = PackageHeaderRes.fromBytesData(data);
      if (header == null) {
        return;
      }

      // 处理心跳响应
      if (header.operationCode == OperationCode.heartbeatReply) {
        return;
      }

      // 处理认证响应
      if (header.operationCode == OperationCode.authReply) {
        _startHeartbeat();
        if (kDebugMode) logger.i('$_logTag 直播间认证成功');
        return;
      }

      // 处理消息数据
      List<int> decompressedData = [];

      switch (header.protocolVer) {
        case ProtocolVersion.json:
        case ProtocolVersion.jsonV1:
          _processingData(data);
          return;
        case ProtocolVersion.gzip:
          decompressedData = ZLibDecoder().convert(
            Uint8List.sublistView(data, 0x10),
          );
          break;
        case ProtocolVersion.brotli:
          decompressedData = const BrotliDecoder().convert(
            Uint8List.sublistView(data, 0x10),
          );
          break;
      }

      _processingData(
        decompressedData is Uint8List
            ? decompressedData
            : Uint8List.fromList(decompressedData),
      );
    } catch (e) {
      if (kDebugMode) logger.e('$_logTag 处理数据失败: $e');
    }
  }

  /// 处理消息数据
  @pragma('vm:notify-debugger-on-exception')
  void _processingData(Uint8List data) {
    try {
      final subHeader = PackageHeaderRes.fromBytesData(data);
      if (subHeader == null) {
        return;
      }

      final msgBody = utf8.decode(
        data.sublist(subHeader.headerSize, subHeader.totalSize),
      );

      final json = jsonDecode(msgBody);
      final message = LiveMessage.fromJson(json);
      _messageController.add(message);

      // 处理剩余数据
      if (subHeader.totalSize < data.length) {
        _processingData(data.sublist(subHeader.totalSize));
      }
    } catch (e) {
      if (kDebugMode) logger.e('$_logTag 解析消息失败: $e');
    }
  }

  /// 开始心跳
  void _startHeartbeat() {
    if (!_isActive) {
      return;
    }

    _heartbeatTimer ??= Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!_isActive) {
          timer.cancel();
          return;
        }

        try {
          final package = HeartbeatPackage(
            header: PackageHeader(
              protocolVer: 1,
              operationCode: OperationCode.heartbeat,
              seq: _heartbeatCount,
            ),
          );
          datasource.sendHeartbeat(package.marshal());
          _heartbeatCount++;
          if (kDebugMode) logger.i('$_logTag 发送心跳 $_heartbeatCount');
        } catch (e) {
          timer.cancel();
          if (kDebugMode) logger.e('$_logTag 发送心跳失败: $e');
        }
      },
    );
  }

  @override
  Stream<LiveMessage> get messageStream => _messageController.stream;

  @override
  Future<void> sendHeartbeat() async {
    final package = HeartbeatPackage(
      header: PackageHeader(
        protocolVer: 1,
        operationCode: OperationCode.heartbeat,
        seq: _heartbeatCount++,
      ),
    );
    await datasource.sendHeartbeat(package.marshal());
  }

  @override
  Future<void> disconnect() async {
    _isActive = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatCount = 1;
    await _messageController.close();
    await datasource.close();
    if (kDebugMode) logger.i('$_logTag 已断开连接');
  }
}
