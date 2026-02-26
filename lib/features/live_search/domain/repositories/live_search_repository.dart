import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_search/data.dart';
import 'package:PiliPlus/features/live_search/domain/entities/live_search_params.dart';

/// Repository interface for live search operations
abstract class LiveSearchRepository {
  /// Search live rooms or users
  ///
  /// [params] contains keyword, type, and page
  ///
  /// Returns [Success] with search results, or [Error] if failed
  Future<LoadingState<LiveSearchData>> search(LiveSearchParams params);
}
