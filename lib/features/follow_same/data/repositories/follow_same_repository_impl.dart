import 'package:PiliPlus/features/follow_same/data/datasources/follow_same_remote_datasource.dart';
import 'package:PiliPlus/features/follow_same/domain/repositories/follow_same_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Repository implementation for "same followed" users
class FollowSameRepositoryImpl implements FollowSameRepository {
  const FollowSameRepositoryImpl(this._datasource);

  final FollowSameRemoteDatasource _datasource;

  @override
  Future<LoadingState<FollowData>> getSameFollowList({
    required int mid,
    required int pn,
  }) =>
      _datasource.getSameFollowList(
        mid: mid,
        pn: pn,
      );

  @override
  Future<String?> getUserName(int mid) => _datasource.getUserName(mid);
}
