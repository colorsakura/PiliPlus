/// 核心异常定义
///
/// 定义应用中所有异常类型的基类和具体实现
library;

/// 应用异常基类
///
/// 所有自定义异常都应该继承此基类
abstract class AppException implements Exception {
  /// 异常消息
  String get message;

  /// 异常代码（可选）
  int? get code => null;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// 服务器异常
///
/// 当服务器返回错误响应时抛出
class ServerException extends AppException {
  @override
  final String message;

  @override
  final int? code;

  ServerException(this.message, {this.code});

  @override
  String toString() =>
      'ServerException: $message${code != null ? ' (code: $code)' : ''}';
}

/// 网络异常
///
/// 当网络连接失败或超时时抛出
class NetworkException extends AppException {
  @override
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// 未授权异常
///
/// 当用户未登录或登录已过期时抛出
class UnauthorizedException extends AppException {
  @override
  String get message => '未授权或登录已过期';

  @override
  int? get code => 401;

  UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// 缓存异常
///
/// 当本地缓存读写失败时抛出
class CacheException extends AppException {
  @override
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// 解析异常
///
/// 当数据解析失败时抛出
class ParseException extends AppException {
  @override
  final String message;

  ParseException(this.message);

  @override
  String toString() => 'ParseException: $message';
}

/// 业务逻辑异常
///
/// 当业务逻辑验证失败时抛出
class BusinessLogicException extends AppException {
  @override
  final String message;

  @override
  final int? code;

  BusinessLogicException(this.message, {this.code});

  @override
  String toString() =>
      'BusinessLogicException: $message${code != null ? ' (code: $code)' : ''}';
}

/// 验证异常
///
/// 当输入验证失败时抛出
class ValidationException extends AppException {
  @override
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
