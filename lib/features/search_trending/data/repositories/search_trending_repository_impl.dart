import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/search_trending/domain/entities/search_trending_item.dart';
import 'package:PiliPlus/features/search_trending/domain/repositories/search_trending_repository.dart';
import 'package:PiliPlus/features/search_trending/data/datasources/search_trending_remote_datasource.dart';

/// Search trending repository implementation
class SearchTrendingRepositoryImpl implements SearchTrendingRepository {
  final SearchTrendingRemoteDatasource _remoteDatasource;

  SearchTrendingRepositoryImpl(this._remoteDatasource);

  @override
  Future<LoadingState<List<SearchTrendingItemEntity>>> getSearchTrending() {
    return _remoteDatasource.fetchSearchTrending();
  }
}
