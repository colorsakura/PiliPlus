import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/login/domain/entities/login_result_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';

/// 密码登录用例
class LoginByPasswordUseCase {
  final LoginRepository _repository;

  LoginByPasswordUseCase(this._repository);

  /// 执行用例
  ///
  /// [username] 用户名
  /// [password] 密码
  ///
  /// 抛出 [Failure] 当登录失败时
  Future<LoginResultEntity> call({
    required String username,
    required String password,
  }) async {
    try {
      if (username.isEmpty) {
        throw const ValidationFailure('用户名不能为空');
      }
      if (password.isEmpty) {
        throw const ValidationFailure('密码不能为空');
      }

      // 获取公钥和盐值
      final webKey = await _repository.getWebKey();
      final key = webKey['key']!;
      final salt = webKey['hash']!;

      // 执行登录
      return await _repository.loginByPassword(
        username: username,
        password: password,
        key: key,
        salt: salt,
      );
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
