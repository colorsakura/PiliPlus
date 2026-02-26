/// 核心失败类型定义
///
/// 定义应用中所有失败类型的基类和具体实现
library;

/// 失败基类
///
/// 所有失败类型都应该继承此基类
abstract class Failure {
  /// 失败消息
  final String message;

  const Failure(this.message);

  @override
  String toString() => 'Failure: $message';
}

/// 服务器失败
///
/// 当服务器请求返回错误时使用
class ServerFailure extends Failure {
  /// 错误代码
  final int? code;

  const ServerFailure(super.message, {this.code});

  @override
  String toString() =>
      'ServerFailure: $message${code != null ? ' (code: $code)' : ''}';
}

/// 网络失败
///
/// 当网络连接失败或超时时使用
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);

  @override
  String toString() => 'NetworkFailure: $message';
}

/// 未授权失败
///
/// 当用户未登录或登录已过期时使用
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('未授权或登录已过期');

  @override
  String toString() => 'UnauthorizedFailure: $message';
}

/// 缓存失败
///
/// 当本地缓存操作失败时使用
class CacheFailure extends Failure {
  const CacheFailure(super.message);

  @override
  String toString() => 'CacheFailure: $message';
}

/// 解析失败
///
/// 当数据解析失败时使用
class ParseFailure extends Failure {
  const ParseFailure(super.message);

  @override
  String toString() => 'ParseFailure: $message';
}

/// 业务逻辑失败
///
/// 当业务逻辑验证失败时使用
class BusinessLogicFailure extends Failure {
  final int? code;

  const BusinessLogicFailure(super.message, {this.code});

  @override
  String toString() =>
      'BusinessLogicFailure: $message${code != null ? ' (code: $code)' : ''}';
}

/// 未知失败
///
/// 当无法确定具体失败类型时使用
class UnknownFailure extends Failure {
  final dynamic originalError;

  const UnknownFailure(super.message, {this.originalError});

  @override
  String toString() =>
      'UnknownFailure: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// 验证失败
///
/// 当输入验证失败时使用
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);

  @override
  String toString() => 'ValidationFailure: $message';
}
