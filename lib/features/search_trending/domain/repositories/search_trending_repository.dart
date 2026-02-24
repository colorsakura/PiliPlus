import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/search_trending/domain/entities/search_trending_item.dart';

/// Search trending repository interface
abstract interface class SearchTrendingRepository {
  /// Get search trending items
  Future<LoadingState<List<SearchTrendingItemEntity>>> getSearchTrending();
}
