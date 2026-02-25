import 'package:PiliPlus/features/followed/data/datasources/followed_remote_datasource.dart';
import 'package:PiliPlus/features/followed/domain/repositories/followed_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Repository implementation for "also followed" users
class FollowedRepositoryImpl implements FollowedRepository {
  const FollowedRepositoryImpl(this._datasource);

  final FollowedRemoteDatasource _datasource;

  @override
  Future<LoadingState<FollowData>> getFollowedList({
    required int mid,
    required int pn,
  }) => _datasource.getFollowedList(
    mid: mid,
    pn: pn,
  );

  @override
  Future<String?> getUserName(int mid) => _datasource.getUserName(mid);
}
