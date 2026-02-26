import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_search/data.dart';
import 'package:PiliPlus/features/live_search/data/datasources/live_search_remote_datasource.dart';
import 'package:PiliPlus/features/live_search/domain/entities/live_search_params.dart';
import 'package:PiliPlus/http/live.dart' as http;

/// Implementation of live search remote data source using LiveHttp
class LiveSearchRemoteDataSourceImpl implements LiveSearchRemoteDataSource {
  const LiveSearchRemoteDataSourceImpl();

  @override
  Future<LoadingState<LiveSearchData>> search(LiveSearchParams params) {
    return http.LiveHttp.liveSearch(
      keyword: params.keyword,
      type: params.type,
      page: params.page,
    );
  }
}
