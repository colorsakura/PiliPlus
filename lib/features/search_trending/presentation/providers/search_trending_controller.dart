import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/search_trending/domain/entities/search_trending_state.dart';
import 'package:PiliPlus/features/search_trending/domain/usecases/get_search_trending.dart';
import 'package:PiliPlus/features/search_trending/data/datasources/search_trending_remote_datasource.dart';
import 'package:PiliPlus/features/search_trending/data/repositories/search_trending_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search trending controller
class SearchTrendingController extends Notifier<SearchTrendingState> {
  late final GetSearchTrendingUseCase _getSearchTrendingUseCase;

  @override
  SearchTrendingState build() {
    _getSearchTrendingUseCase = GetSearchTrendingUseCase(
      SearchTrendingRepositoryImpl(
        SearchTrendingRemoteDatasource(),
      ),
    );
    // Auto-load on first access
    fetchSearchTrending();
    return SearchTrendingState(
      items: LoadingState.loading(),
      topCount: 0,
    );
  }

  /// Fetch search trending items
  Future<void> fetchSearchTrending() async {
    state = SearchTrendingState(
      items: LoadingState.loading(),
      topCount: 0,
    );

    final result = await _getSearchTrendingUseCase();

    state = switch (result) {
      Loading() => SearchTrendingState(
        items: LoadingState.loading(),
        topCount: 0,
      ),
      Success(:final data) => () {
        if (data != null) {
          // Calculate top count (items with icons are top items)
          final topCount = data
              .where((item) => item.icon?.isNotEmpty == true)
              .length;

          return SearchTrendingState(
            items: Success(data),
            topCount: topCount,
          );
        }
        return SearchTrendingState(
          items: Success([]),
          topCount: 0,
        );
      }(),
      Error() => SearchTrendingState(
        items: result,
        topCount: 0,
      ),
    };
  }

  /// Reload search trending
  Future<void> reload() => fetchSearchTrending();
}

/// Search trending controller provider
final searchTrendingControllerProvider =
    NotifierProvider<SearchTrendingController, SearchTrendingState>(
      SearchTrendingController.new,
    );
