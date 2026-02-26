import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/login/domain/entities/sms_code_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';

/// 发送短信验证码用例
class SendSmsCodeUseCase {
  final LoginRepository _repository;

  SendSmsCodeUseCase(this._repository);

  /// 执行用例
  ///
  /// [tel] 手机号
  /// [cid] 国家代码
  ///
  /// 抛出 [Failure] 当发送失败时
  Future<SmsCodeEntity> call({
    required String tel,
    required Object cid,
  }) async {
    try {
      if (tel.isEmpty) {
        throw const ValidationFailure('手机号不能为空');
      }

      return await _repository.sendSmsCode(
        cid: cid,
        tel: tel,
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
