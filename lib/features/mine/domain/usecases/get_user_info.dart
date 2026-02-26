import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/mine/domain/entities/user_info_entity.dart';
import 'package:PiliPlus/features/mine/domain/repositories/mine_repository.dart';

/// 获取用户信息用例
class GetUserInfoUseCase {
  final MineRepository _repository;

  GetUserInfoUseCase(this._repository);

  /// 执行用例
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<UserInfoEntity> call() async {
    try {
      return await _repository.getUserInfo();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException {
      throw UnauthorizedFailure();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
