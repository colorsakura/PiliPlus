/// HTTP 客户端
///
/// 提供全局的 Dio 实例配置，包括拦截器、超时、HTTP/2 支持等
library;

import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:PiliPlus/core/network/http_interceptors/retry_interceptor.dart';
import 'package:PiliPlus/core/network/http_interceptors/logging_interceptor.dart';
import 'package:PiliPlus/core/network/response_decoder.dart' as decoder;
import 'package:PiliPlus/core/constants/api_constants.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';

/// HTTP 客户端管理器
///
/// 单例模式，提供全局共享的 Dio 实例
///
/// 使用示例：
/// ```dart
/// final response = await HttpClientManager.instance.get('/some/endpoint');
/// ```
class HttpClientManager {
  HttpClientManager._();

  /// Dio 实例（懒加载初始化）
  static Dio? _instance;

  /// 获取 Dio 实例
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  /// 初始化 HTTP 客户端
  ///
  /// 应在应用启动时调用一次（可选，会自动懒加载）
  static void initialize() {
    _instance ??= _createDio();
  }

  /// 创建 Dio 实例
  static Dio _createDio() {
    final enableHttp2 = Pref.enableHttp2;

    // 基础配置
    final options = BaseOptions(
      baseUrl: ApiConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 10000),
      headers: {
        'user-agent': 'Dart/3.6 (dart:io)',
        if (!enableHttp2) 'connection': 'keep-alive',
        'accept-encoding': 'br,gzip',
      },
      responseDecoder: decoder.ResponseDecoder.decoder,
      persistentConnection: true,
    );

    // 配置代理
    final proxyConfig = _getProxyConfig();

    // HTTP/1.1 适配器
    final http11Adapter = IOHttpClientAdapter(
      createHttpClient: proxyConfig != null
          ? () => _createProxiedHttpClient(proxyConfig)
          : () => _createDefaultHttpClient(),
    );

    // 创建 Dio 实例
    final dio = Dio(options);

    // 配置 HTTP 客户端适配器
    dio.httpClientAdapter = enableHttp2
        ? Http2Adapter(
            ConnectionManager(
              idleTimeout: const Duration(seconds: 15),
              onClientCreate: proxyConfig != null
                  ? (_, config) => _configureHttp2Proxy(config, proxyConfig)
                  : Pref.badCertificateCallback
                  ? (_, config) {
                      config.onBadCertificate = (_) => true;
                    }
                  : null,
            ),
            fallbackAdapter: http11Adapter,
          )
        : http11Adapter;

    // 添加拦截器
    dio.interceptors.addAll([
      RetryInterceptor(Pref.retryCount, Pref.retryDelay),
      if (kDebugMode) HttpLoggingInterceptor(),
    ]);

    // 配置转换器和状态验证
    dio
      ..transformer = BackgroundTransformer()
      ..options.validateStatus = (int? status) {
        return status != null && status >= 200 && status < 300;
      };

    return dio;
  }

  /// 创建默认的 HTTP 客户端
  static io.HttpClient _createDefaultHttpClient() {
    return io.HttpClient()
      ..idleTimeout = const Duration(seconds: 15)
      ..autoUncompress = false;
  }

  /// 创建带代理的 HTTP 客户端
  static io.HttpClient _createProxiedHttpClient(ProxyConfig config) {
    final client = io.HttpClient()
      ..idleTimeout = const Duration(seconds: 15)
      ..autoUncompress = false
      ..findProxy = (_) => 'PROXY ${config.host}:${config.port}';
    client.badCertificateCallback =
        (
          io.X509Certificate cert,
          String host,
          int port,
        ) => true;
    return client;
  }

  /// 获取代理配置
  static ProxyConfig? _getProxyConfig() {
    if (!Pref.enableSystemProxy) return null;

    final host = Pref.systemProxyHost;
    final port = int.tryParse(Pref.systemProxyPort);

    if (port == null || host.isEmpty) return null;

    return ProxyConfig(host: host, port: port);
  }

  /// 配置 HTTP/2 代理
  static void _configureHttp2Proxy(
    dynamic config,
    ProxyConfig proxyConfig,
  ) {
    config
      ..proxy = Uri(
        scheme: 'http',
        host: proxyConfig.host,
        port: proxyConfig.port,
      )
      ..onBadCertificate = (_) => true;
  }
}

/// 代理配置
class ProxyConfig {
  final String host;
  final int port;

  const ProxyConfig({
    required this.host,
    required this.port,
  });
}
