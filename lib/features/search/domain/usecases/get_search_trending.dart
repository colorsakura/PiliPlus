import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/search/domain/entities/search_trending_entity.dart';
import 'package:PiliPlus/features/search/domain/repositories/search_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 获取热搜榜用例
class GetSearchTrendingUseCase {
  final SearchRepository _repository;

  const GetSearchTrendingUseCase(this._repository);

  /// 执行获取热搜榜
  ///
  /// [limit] 返回数量
  /// 返回热搜数据状态
  Future<LoadingState<SearchTrendingDataEntity>> call({
    int limit = 30,
  }) async {
    try {
      final result = await _repository.getSearchTrending(limit: limit);
      return Success(result);
    } on ServerFailure catch (e) {
      return Error(e.message);
    } on NetworkFailure catch (e) {
      return Error(e.message);
    }
  }
}
