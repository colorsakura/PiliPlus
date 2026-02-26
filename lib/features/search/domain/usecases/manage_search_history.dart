import 'package:PiliPlus/features/search/domain/entities/search_history_entity.dart';
import 'package:PiliPlus/features/search/domain/repositories/search_repository.dart';

/// 管理搜索历史用例
class ManageSearchHistoryUseCase {
  final SearchRepository _repository;

  const ManageSearchHistoryUseCase(this._repository);

  /// 获取搜索历史
  SearchHistoryEntity getHistory() {
    return _repository.getSearchHistory();
  }

  /// 添加搜索历史
  ///
  /// [keyword] 搜索关键词
  SearchHistoryEntity addHistory(String keyword) {
    _repository.addSearchHistory(keyword);
    return _repository.getSearchHistory();
  }

  /// 删除搜索历史
  ///
  /// [keyword] 搜索关键词
  SearchHistoryEntity removeHistory(String keyword) {
    _repository.removeSearchHistory(keyword);
    return _repository.getSearchHistory();
  }

  /// 清空搜索历史
  SearchHistoryEntity clearHistory() {
    _repository.clearSearchHistory();
    return _repository.getSearchHistory();
  }
}
