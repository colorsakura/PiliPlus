import 'package:PiliPlus/features/home/domain/entities/search_suggestion.dart';
import 'package:PiliPlus/features/home/domain/repositories/search_repository.dart';

/// 获取搜索建议用例
class FetchSearchSuggestionUseCase {
  final SearchRepository _repository;

  const FetchSearchSuggestionUseCase(this._repository);

  /// 执行用例：获取默认搜索建议
  Future<SearchSuggestion?> call() => _repository.getDefaultSearchSuggestion();
}
