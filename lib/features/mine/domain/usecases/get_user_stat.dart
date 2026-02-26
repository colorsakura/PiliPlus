import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/mine/domain/entities/user_stat_entity.dart';
import 'package:PiliPlus/features/mine/domain/repositories/mine_repository.dart';

/// 获取用户统计信息用例
class GetUserStatUseCase {
  final MineRepository _repository;

  GetUserStatUseCase(this._repository);

  /// 执行用例
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<UserStatEntity> call() async {
    try {
      return await _repository.getUserStat();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
