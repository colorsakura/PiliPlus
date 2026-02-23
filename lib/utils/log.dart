import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 统一日志工具
///
/// 使用 dart:developer.log 输出日志，支持日志级别和命名空间
/// 日志格式: [Name] Level Message
enum LogLevel {
  fine(500), // 详细信息
  info(800), // 一般信息
  warning(900), // 警告
  severe(1000)
  ; // 严重错误

  final int value;
  const LogLevel(this.value);
}

class AppLog {
  /// 输出日志
  static void log(
    String message, {
    required String name,
    LogLevel level = LogLevel.info,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name,
        level: level.value,
        time: DateTime.now(),
      );
    }
  }

  /// 详细信息
  static void fine(String message, {required String name}) {
    log(message, name: name, level: LogLevel.fine);
  }

  /// 一般信息
  static void info(String message, {required String name}) {
    log(message, name: name, level: LogLevel.info);
  }

  /// 警告
  static void warning(String message, {required String name}) {
    log(message, name: name, level: LogLevel.warning);
  }

  /// 错误
  static void severe(
    String message, {
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name,
        level: LogLevel.severe.value,
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }
}
