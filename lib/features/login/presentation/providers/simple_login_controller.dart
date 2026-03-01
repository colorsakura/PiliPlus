import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/presentation/providers/login_providers.dart';

part 'simple_login_controller.g.dart';

/// 登录状态
enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

/// 简化的登录状态类
class SimpleLoginState {
  final LoginStatus status;
  final LoginEntity? loginEntity;
  final String? errorMessage;

  const SimpleLoginState({
    required this.status,
    this.loginEntity,
    this.errorMessage,
  });

  factory SimpleLoginState.initial() {
    return const SimpleLoginState(status: LoginStatus.initial);
  }

  factory SimpleLoginState.loading() {
    return SimpleLoginState(status: LoginStatus.loading);
  }

  factory SimpleLoginState.success(LoginEntity entity) {
    return SimpleLoginState(
      status: LoginStatus.success,
      loginEntity: entity,
    );
  }

  factory SimpleLoginState.error(String message) {
    return SimpleLoginState(
      status: LoginStatus.error,
      errorMessage: message,
    );
  }

  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get hasError => status == LoginStatus.error;
}

/// 简化的登录控制器（用于演示干净架构）
@riverpod
class SimpleLoginController extends _$SimpleLoginController {
  @override
  SimpleLoginState build() {
    return SimpleLoginState.initial();
  }

  /// 执行登录
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = SimpleLoginState.loading();

    try {
      final useCase = ref.read(performLoginUseCaseProvider);
      final loginEntity = await useCase(
        username: username,
        password: password,
      );

      state = SimpleLoginState.success(loginEntity);
    } on ValidationFailure catch (e) {
      state = SimpleLoginState.error(e.message);
    } on UnauthorizedFailure {
      state = SimpleLoginState.error('用户名或密码错误');
    } on NetworkFailure catch (e) {
      state = SimpleLoginState.error('网络错误: ${e.message}');
    } on ServerFailure catch (e) {
      state = SimpleLoginState.error('服务器错误: ${e.message}');
    } catch (e) {
      state = SimpleLoginState.error('未知错误: $e');
    }
  }

  /// 重置状态
  void reset() {
    state = SimpleLoginState.initial();
  }
}
