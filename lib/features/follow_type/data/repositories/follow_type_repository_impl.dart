import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/follow_type/domain/repositories/follow_type_repository.dart';
import 'package:PiliPlus/features/follow_type/data/datasources/follow_type_remote_datasource.dart';
import 'package:PiliPlus/features/follow_type/domain/entities/follow_type_params.dart';

/// Implementation of follow type repository
class FollowTypeRepositoryImpl implements FollowTypeRepository {
  final FollowTypeRemoteDataSource remoteDataSource;

  const FollowTypeRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<FollowData>> fetchFollowed(FollowedParams params) {
    return remoteDataSource.fetchFollowed(params);
  }

  @override
  Future<LoadingState<FollowData>> fetchFollowSame(FollowSameParams params) {
    return remoteDataSource.fetchFollowSame(params);
  }
}
