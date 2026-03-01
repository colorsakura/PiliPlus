import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';

/// 执行登录用例
///
/// 封装登录的业务逻辑，包括参数验证和错误处理
class PerformLoginUseCase {
  final LoginRepository _repository;

  const PerformLoginUseCase(this._repository);

  /// 执行登录
  ///
  /// [username] 用户名或邮箱，不能为空
  /// [password] 密码，不能为空
  ///
  /// 返回 [LoginEntity] 登录成功后的实体
  ///
  /// 抛出 [ValidationFailure] 当参数验证失败时
  /// 抛出 [UnauthorizedFailure] 当凭证无效时
  /// 抛出 [ServerFailure] 当服务器错误时
  /// 抛出 [NetworkFailure] 当网络错误时
  Future<LoginEntity> call({
    required String username,
    required String password,
  }) async {
    // 参数验证
    if (username.trim().isEmpty) {
      throw const ValidationFailure('用户名不能为空');
    }

    if (password.trim().isEmpty) {
      throw const ValidationFailure('密码不能为空');
    }

    if (password.length < 6) {
      throw const ValidationFailure('密码长度不能少于6位');
    }

    try {
      return await _repository.performLogin(
        username: username,
        password: password,
      );
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }
}
