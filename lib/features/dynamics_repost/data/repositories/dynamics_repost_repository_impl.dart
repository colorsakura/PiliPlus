import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_repost/domain/entities/dynamics_repost_params.dart';
import 'package:PiliPlus/features/dynamics_repost/domain/repositories/dynamics_repost_repository.dart';
import 'package:PiliPlus/features/dynamics_repost/data/datasources/dynamics_repost_remote_datasource.dart';

/// Implementation of dynamic repost repository
class DynamicsRepostRepositoryImpl implements DynamicsRepostRepository {
  final DynamicsRepostRemoteDataSource remoteDataSource;

  const DynamicsRepostRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<Map?>> repostDynamic(DynamicsRepostParams params) {
    return remoteDataSource.repostDynamic(params);
  }
}
