import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/search/domain/entities/search_suggest_entity.dart';
import 'package:PiliPlus/features/search/domain/repositories/search_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 获取搜索建议用例
class GetSearchSuggestUseCase {
  final SearchRepository _repository;

  const GetSearchSuggestUseCase(this._repository);

  /// 执行获取搜索建议
  ///
  /// [term] 搜索关键词
  /// 返回搜索建议列表状态
  Future<LoadingState<List<SearchSuggestEntity>>> call({
    required String term,
  }) async {
    try {
      final result = await _repository.getSearchSuggest(term: term);
      return Success(result);
    } on ServerFailure catch (e) {
      return Error(e.message);
    } on NetworkFailure catch (e) {
      return Error(e.message);
    }
  }
}
