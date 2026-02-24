import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/search/search_trending/list.dart';
import 'package:PiliPlus/features/search_trending/domain/entities/search_trending_item.dart';

/// Search trending remote data source
class SearchTrendingRemoteDatasource {
  /// Fetch search trending from API
  Future<LoadingState<List<SearchTrendingItemEntity>>> fetchSearchTrending() async {
    final result = await SearchHttp.searchTrending();

    return switch (result) {
      Loading() => LoadingState<List<SearchTrendingItemEntity>>.loading(),
      Success(:final response) => () {
          // Combine topList and list
          final topList = response.topList ?? <SearchTrendingItemModel>[];
          final mainList = response.list ?? <SearchTrendingItemModel>[];
          final combinedList = [...topList, ...mainList];

          final entities = combinedList.map(
            (model) => SearchTrendingItemEntity.fromModel(model),
          ).toList();

          return Success(entities);
        }(),
      Error() => result as LoadingState<List<SearchTrendingItemEntity>>,
    };
  }
}
