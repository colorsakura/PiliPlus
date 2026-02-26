import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/mine/domain/entities/fav_folder_entity.dart';
import 'package:PiliPlus/features/mine/domain/repositories/mine_repository.dart';

/// 获取收藏夹列表用例
class GetFavFoldersUseCase {
  final MineRepository _repository;

  GetFavFoldersUseCase(this._repository);

  /// 执行用例
  ///
  /// [mid] 用户ID
  /// [pn] 页码
  /// [ps] 每页数量
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<FavFolderListEntity> call({
    required String mid,
    int pn = 1,
    int ps = 20,
  }) async {
    try {
      if (mid.isEmpty) {
        throw const ValidationFailure('用户ID不能为空');
      }

      return await _repository.getFavFolders(
        mid: mid,
        pn: pn,
        ps: ps,
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
