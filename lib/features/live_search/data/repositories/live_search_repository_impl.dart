import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_search/data.dart';
import 'package:PiliPlus/features/live_search/domain/repositories/live_search_repository.dart';
import 'package:PiliPlus/features/live_search/domain/entities/live_search_params.dart';
import 'package:PiliPlus/features/live_search/data/datasources/live_search_remote_datasource.dart';

/// Implementation of live search repository
class LiveSearchRepositoryImpl implements LiveSearchRepository {
  final LiveSearchRemoteDataSource remoteDataSource;

  const LiveSearchRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<LiveSearchData>> search(LiveSearchParams params) {
    return remoteDataSource.search(params);
  }
}
