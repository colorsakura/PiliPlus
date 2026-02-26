import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_search/data.dart';
import 'package:PiliPlus/features/live_search/domain/repositories/live_search_repository.dart';
import 'package:PiliPlus/features/live_search/domain/entities/live_search_params.dart';

/// Use case for live search
class SearchLive {
  final LiveSearchRepository repository;

  const SearchLive(this.repository);

  /// Execute the search operation
  ///
  /// [params] contains keyword, type, and page
  ///
  /// Returns [Success] with search results, or [Error] if failed
  Future<LoadingState<LiveSearchData>> call(LiveSearchParams params) {
    return repository.search(params);
  }
}
