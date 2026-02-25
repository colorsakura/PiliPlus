/// 重试拦截器
///
/// 当网络请求失败时自动重试
library;

import 'package:dio/dio.dart';
import 'package:http2/http2.dart';

import 'package:PiliPlus/core/network/http_client.dart' as http;

/// 重试拦截器
///
/// 当请求遇到可重试的错误（如连接超时）时，
/// 会自动重试最多 [_count] 次，每次重试间隔递增
class RetryInterceptor extends Interceptor {
  final int _count;
  final int _delay;

  RetryInterceptor(this._count, this._delay);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 流式响应不重试
    if (err.requestOptions.responseType == ResponseType.stream) {
      return handler.next(err);
    }

    // 处理重定向
    if (err.response != null) {
      final options = err.requestOptions;
      if (options.followRedirects && options.maxRedirects > 0) {
        final status = err.response!.statusCode;
        if (status != null && 300 <= status && status < 400) {
          _handleRedirect(err, handler);
          return;
        }
      }
      return handler.next(err);
    }

    // 处理可重试的错误
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.unknown:
        _retryIfNeeded(err, handler);
        return;
      default:
        return handler.next(err);
    }
  }

  /// 处理重定向
  void _handleRedirect(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response!.statusCode!;
    var redirectUrl = err.response!.headers.value('location');

    if (redirectUrl == null) {
      return handler.next(err);
    }

    var uri = Uri.parse(redirectUrl);
    if (!uri.hasScheme) {
      uri = options.uri.resolveUri(uri);
      redirectUrl = uri.toString();
    }

    (options..path = redirectUrl).maxRedirects--;

    if (status == 303) {
      options
        ..data = null
        ..method = 'GET';
    }

    http.HttpClientManager.instance
        .fetch(options)
        .then(
          (response) => handler.resolve(
            response
              ..redirects.add(
                RedirectRecord(status, options.method, uri),
              )
              ..isRedirect = true,
          ),
        )
        .onError<DioException>((error, _) => handler.next(error));
  }

  /// 如果需要则重试
  void _retryIfNeeded(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final retryCount = err.requestOptions.extra['_rt'] ?? 0;

    // 网络中断时不重试，因为请求可能已经被服务器接收
    if (err.error is TransportConnectionException) {
      return handler.next(err);
    }

    if (retryCount < _count) {
      final delay = Duration(
        milliseconds: ++err.requestOptions.extra['_rt'] * _delay,
      );

      Future.delayed(
        delay,
        () => http.HttpClientManager.instance
            .fetch(err.requestOptions)
            .then(handler.resolve)
            .onError<DioException>((error, _) => handler.next(error)),
      );
    } else {
      handler.next(err);
    }
  }
}
