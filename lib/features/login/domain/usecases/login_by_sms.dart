import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/login/domain/entities/login_result_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';

/// 短信验证码登录用例
class LoginBySmsUseCase {
  final LoginRepository _repository;

  LoginBySmsUseCase(this._repository);

  /// 执行用例
  ///
  /// [tel] 手机号
  /// [code] 验证码
  /// [captchaKey] 验证码密钥
  /// [cid] 国家代码
  ///
  /// 抛出 [Failure] 当登录失败时
  Future<LoginResultEntity> call({
    required String tel,
    required String code,
    required String captchaKey,
    required Object cid,
  }) async {
    try {
      if (tel.isEmpty) {
        throw const ValidationFailure('手机号不能为空');
      }
      if (code.isEmpty) {
        throw const ValidationFailure('验证码不能为空');
      }
      if (captchaKey.isEmpty) {
        throw const ValidationFailure('验证码密钥不能为空');
      }

      // 获取公钥
      final webKey = await _repository.getWebKey();
      final key = webKey['key']!;

      // 执行登录
      return await _repository.loginBySms(
        tel: tel,
        code: code,
        captchaKey: captchaKey,
        cid: cid,
        key: key,
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
