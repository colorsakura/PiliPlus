import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_search/data.dart';
import 'package:PiliPlus/features/live_search/domain/entities/live_search_params.dart';

/// Data source interface for live search operations
abstract class LiveSearchRemoteDataSource {
  /// Search live rooms or users via API
  Future<LoadingState<LiveSearchData>> search(LiveSearchParams params);
}
