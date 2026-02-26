import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/login/domain/entities/qr_code_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';

/// 获取二维码登录用例
class GetQRCodeUseCase {
  final LoginRepository _repository;

  GetQRCodeUseCase(this._repository);

  /// 执行用例
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<QrCodeEntity> call() async {
    try {
      return await _repository.getQRCode();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
