/// 响应解码器
///
/// 负责解码 HTTP 响应中的 gzip 和 brotli 压缩数据
library;

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:brotli/brotli.dart';
import 'package:dio/dio.dart';

/// 响应解码器
///
/// 提供静态方法来解码各种压缩格式的响应数据
class ResponseDecoder {
  ResponseDecoder._();

  static const GZipDecoder _gzipDecoder = GZipDecoder();
  static const BrotliDecoder _brotliDecoder = BrotliDecoder();

  /// 解码字节数据
  ///
  /// 根据 [headers] 中的 content-encoding 自动选择解码器
  /// 支持 gzip 和 br (brotli) 两种压缩格式
  static List<int> decodeBytes(
    List<int> responseBytes,
    Map<String, List<String>> headers,
  ) {
    final encoding = headers['content-encoding']?.firstOrNull;

    return switch (encoding) {
      'gzip' => _gzipDecoder.decodeBytes(responseBytes),
      'br' => _brotliDecoder.convert(responseBytes),
      _ => responseBytes,
    };
  }

  /// 解码为字符串
  ///
  /// 先解压缩，然后转换为 UTF-8 字符串
  /// 用于 Dio 的 [ResponseType.plain] 或 JSON 响应
  static String decoder(
    List<int> responseBytes,
    RequestOptions options,
    ResponseBody responseBody,
  ) {
    return utf8.decode(
      decodeBytes(responseBytes, responseBody.headers),
      allowMalformed: true,
    );
  }
}
