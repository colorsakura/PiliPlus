/// 错误处理器
///
/// 负责将异常转换为失败类型
library;

import 'package:dio/dio.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/core/errors/failures.dart';

/// 错误处理器
///
/// 提供 [AppException] 到 [Failure] 的转换
/// 以及 [DioException] 到 [AppException] 的转换
class ErrorHandler {
  ErrorHandler._();

  /// 将 [AppException] 转换为 [Failure]
  static Failure handleException(AppException exception) {
    return switch (exception) {
      ServerException(:final message, :final code) => ServerFailure(
        message,
        code: code,
      ),
      NetworkException(:final message) => NetworkFailure(message),
      UnauthorizedException() => const UnauthorizedFailure(),
      CacheException(:final message) => CacheFailure(message),
      ParseException(:final message) => ParseFailure(message),
      BusinessLogicException(:final message, :final code) =>
        BusinessLogicFailure(
          message,
          code: code,
        ),
      _ => UnknownFailure(
        exception.message,
        originalError: exception,
      ),
    };
  }

  /// 将 [DioException] 转换为 [AppException]
  static AppException handleDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => NetworkException('网络连接超时'),
      DioExceptionType.connectionError => NetworkException('网络连接失败'),
      DioExceptionType.badResponse => _handleBadResponse(error),
      DioExceptionType.cancel => NetworkException('请求已取消'),
      DioExceptionType.badCertificate => NetworkException('证书验证失败'),
      DioExceptionType.unknown => NetworkException(
        '网络请求失败: ${error.message ?? "未知错误"}',
      ),
    };
  }

  /// 处理错误响应
  static AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // 提取错误消息
    String? errorMessage;
    if (data is Map<String, dynamic>) {
      errorMessage ??= data['message'] as String?;
      errorMessage ??= data['msg'] as String?;
    }

    // 根据状态码返回不同的异常
    return switch (statusCode) {
      401 || 403 => UnauthorizedException(),
      404 => ServerException(
        errorMessage ?? '请求的资源不存在',
        code: statusCode,
      ),
      400 => ServerException(
        errorMessage ?? '请求参数错误',
        code: statusCode,
      ),
      500 || 502 || 503 || 504 => ServerException(
        errorMessage ?? '服务器错误，请稍后重试',
        code: statusCode,
      ),
      _ => ServerException(
        errorMessage ?? '请求失败',
        code: statusCode,
      ),
    };
  }

  /// 处理通用异常
  static Failure handleError(dynamic error) {
    if (error is AppException) {
      return handleException(error);
    } else if (error is DioException) {
      final exception = handleDioError(error);
      return handleException(exception);
    } else if (error is Failure) {
      return error;
    } else {
      return UnknownFailure(
        '发生未知错误',
        originalError: error,
      );
    }
  }
}
