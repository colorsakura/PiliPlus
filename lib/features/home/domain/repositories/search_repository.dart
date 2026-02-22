import 'package:PiliPlus/features/home/domain/entities/search_suggestion.dart';

/// 搜索建议仓库接口
abstract interface class SearchRepository {
  /// 获取默认搜索建议
  Future<SearchSuggestion?> getDefaultSearchSuggestion();
}
