/// 日志拦截器
///
/// 在调试模式下打印所有 HTTP 请求和响应的详细信息
library;

import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// HTTP 日志拦截器
///
/// 仅在调试模式下启用，用于记录所有网络请求的详细信息
/// 包括请求 URL、方法、响应状态码、耗时等
class HttpLoggingInterceptor extends Interceptor {
  final _requestStartTimes = <String, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestStartTimes[options.uri.toString()] = DateTime.now();

    final uri = options.uri;
    final displayUrl = '${uri.scheme}://${uri.host}${uri.path}';

    _log(
      'HTTP Request → ${options.method} $displayUrl',
      level: 500,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = _requestStartTimes[response.requestOptions.uri.toString()];
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : null;

    final uri = response.requestOptions.uri;
    final displayUrl = '${uri.scheme}://${uri.host}${uri.path}';

    final buffer = StringBuffer(
      'HTTP Response ← ${response.statusCode} '
      '${_getStatusEmoji(response.statusCode)} '
      '${response.requestOptions.method} $displayUrl',
    );

    if (duration != null) {
      buffer.write(' (${duration.inMilliseconds}ms)');
    }

    _log(buffer.toString(), level: 800);
    _requestStartTimes.remove(response.requestOptions.uri.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = _requestStartTimes[err.requestOptions.uri.toString()];
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : null;

    final uri = err.requestOptions.uri;
    final displayUrl = '${uri.scheme}://${uri.host}${uri.path}';

    final statusCode = err.response?.statusCode;
    final buffer = StringBuffer(
      'HTTP Error ✗ ${err.type.name} '
      '${err.requestOptions.method} $displayUrl',
    );

    if (statusCode != null) {
      buffer.write(' [$statusCode]');
    }
    if (duration != null) {
      buffer.write(' (${duration.inMilliseconds}ms)');
    }

    _log(buffer.toString(), level: 1000);
    _requestStartTimes.remove(err.requestOptions.uri.toString());
    handler.next(err);
  }

  /// 获取状态码对应的表情符号
  String _getStatusEmoji(int? statusCode) {
    if (statusCode == null) return '';
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    if (statusCode >= 500) return '💥';
    return '';
  }

  /// 打印日志
  void _log(String message, {required int level}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'HTTP',
        level: level,
        time: DateTime.now(),
      );
    }
  }
}
