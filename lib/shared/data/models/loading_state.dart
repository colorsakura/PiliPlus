/// 统一响应状态
///
/// 用于封装网络请求和异步操作的结果
library;

import 'package:flutter/foundation.dart' show immutable;
import 'package:PiliPlus/utils/toast_utils.dart';

/// 统一响应状态
///
/// 使用 sealed class 确保所有状态类型都被覆盖
sealed class LoadingState<T> {
  const LoadingState();

  /// 加载状态
  factory LoadingState.loading() => const Loading._internal();

  /// 是否成功
  bool get isSuccess => this is Success<T>;

  /// 获取数据（成功时返回数据，失败时抛出异常）
  T get data => switch (this) {
    Success(:final response) => response,
    _ => throw this,
  };

  /// 获取数据（安全，失败时返回 null）
  T? get dataOrNull => switch (this) {
    Success(:final response) => response,
    _ => null,
  };

  /// 显示 Toast 提示
  Future<void> toast() => ToastUtils.showToast(toString());

  /// 映射数据类型
  LoadingState<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Loading() => LoadingState<R>.loading(),
      Success(:final response) => Success(mapper(response)),
      Error(:final code, :final errMsg) => Error(errMsg, code: code),
    };
  }
}

/// 加载中状态
class Loading extends LoadingState<Never> {
  const Loading._internal();

  @override
  String toString() => 'ApiException: loading';
}

/// 成功状态
@immutable
class Success<T> extends LoadingState<T> {
  final T response;
  const Success(this.response);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Success<T>) {
      return response == other.response;
    }
    return false;
  }

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'Success: $response';
}

/// 错误状态
@immutable
class Error extends LoadingState<Never> {
  final int? code;
  final String? errMsg;
  const Error(this.errMsg, {this.code});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Error) {
      return errMsg == other.errMsg && code == other.code;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(errMsg, code);

  @override
  String toString() => errMsg ?? code?.toString() ?? '';
}
