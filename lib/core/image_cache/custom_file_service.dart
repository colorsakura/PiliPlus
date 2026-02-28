/// 自定义文件服务
///
/// 使用独立的 Dio 实例下载图片，支持重试和超时配置
library;

import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:PiliPlus/utils/log.dart';

/// 自定义文件服务响应
class DioFileServiceResponse implements FileServiceResponse {
  const DioFileServiceResponse(this._response, this._receivedTime);

  final Response<dynamic> _response;
  final DateTime _receivedTime;

  @override
  Stream<List<int>> get content async* {
    final data = _response.data;
    if (data is List<int>) {
      yield data;
    } else if (data is Stream<List<int>>) {
      yield* data;
    }
  }

  @override
  int? get contentLength {
    final length = _response.headers.value(HttpHeaders.contentLengthHeader);
    return length != null ? int.tryParse(length) : null;
  }

  @override
  int get statusCode => _response.statusCode ?? 0;

  @override
  DateTime get validTill {
    // Without a cache-control header we keep the file for a week
    var ageDuration = const Duration(days: 7);
    final controlHeader =
        _response.headers.value(HttpHeaders.cacheControlHeader);
    if (controlHeader != null) {
      final controlSettings = controlHeader.split(',');
      for (final setting in controlSettings) {
        final sanitizedSetting = setting.trim().toLowerCase();
        if (sanitizedSetting == 'no-cache') {
          ageDuration = Duration.zero;
        }
        if (sanitizedSetting.startsWith('max-age=')) {
          final validSeconds =
              int.tryParse(sanitizedSetting.split('=')[1]) ?? 0;
          if (validSeconds > 0) {
            ageDuration = Duration(seconds: validSeconds);
          }
        }
      }
    }

    return _receivedTime.add(ageDuration);
  }

  @override
  String? get eTag => _response.headers.value(HttpHeaders.etagHeader);

  @override
  String get fileExtension {
    var fileExtension = '';
    final contentTypeHeader =
        _response.headers.value(HttpHeaders.contentTypeHeader);
    if (contentTypeHeader != null) {
      final contentType = ContentType.parse(contentTypeHeader);
      fileExtension = contentType.mimeType.split('/').last;
      if (!fileExtension.startsWith('.')) {
        fileExtension = '.$fileExtension';
      }
    }
    return fileExtension;
  }
}

/// 自定义文件服务
///
/// 使用独立的 Dio 客户端下载文件，避免 baseUrl 干扰
class CustomFileService extends FileService {
  final Duration timeout;
  late final Dio _dio;

  CustomFileService({this.timeout = const Duration(seconds: 15)}) {
    _dio = Dio(
      BaseOptions(
        // 不设置 baseUrl，避免干扰完整 URL
        connectTimeout: const Duration(milliseconds: 10000),
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: {
          'accept-encoding': 'br,gzip',
        },
        persistentConnection: true,
      ),
    );
  }

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
      );

      return DioFileServiceResponse(response, clock.now());
    } catch (e) {
      AppLog.warning('Failed to download file: $e', name: 'CustomFileService');
      rethrow;
    }
  }
}
