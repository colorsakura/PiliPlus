import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/follow_search/domain/repositories/follow_search_repository.dart';
import 'package:PiliPlus/features/follow_search/data/datasources/follow_search_remote_datasource.dart';

/// Repository implementation for follow search
class FollowSearchRepositoryImpl implements FollowSearchRepository {
  const FollowSearchRepositoryImpl(this._remoteDatasource);

  final FollowSearchRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<FollowData>> searchFollows({
    required int mid,
    required String name,
    required int page,
    required int pageSize,
  }) {
    return _remoteDatasource.searchFollows(
      mid: mid,
      name: name,
      page: page,
      pageSize: pageSize,
    );
  }
}
