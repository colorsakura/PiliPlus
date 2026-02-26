import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/search/domain/entities/search_trending_entity.dart';
import 'package:PiliPlus/features/search/domain/repositories/search_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 获取搜索推荐用例
class GetSearchRecommendUseCase {
  final SearchRepository _repository;

  const GetSearchRecommendUseCase(this._repository);

  /// 执行获取搜索推荐
  ///
  /// 返回搜索推荐列表状态
  Future<LoadingState<List<SearchTrendingEntity>>> call() async {
    try {
      final result = await _repository.getSearchRecommend();
      return Success(result);
    } on ServerFailure catch (e) {
      return Error(e.message);
    } on NetworkFailure catch (e) {
      return Error(e.message);
    }
  }
}
