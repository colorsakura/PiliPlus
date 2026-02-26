import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_create/data/datasources/dynamic_publish_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_create/domain/entities/dynamic_publish_params.dart';
import 'package:PiliPlus/features/dynamics_create/domain/repositories/dynamic_publish_repository.dart';

/// Implementation of dynamic publish repository
class DynamicPublishRepositoryImpl implements DynamicPublishRepository {
  final DynamicPublishRemoteDataSource remoteDataSource;

  const DynamicPublishRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<Map<String, dynamic>?>> createDynamic(CreateDynamicParams params) {
    return remoteDataSource.createDynamic(params);
  }

  @override
  Future<LoadingState<Null>> editDynamic(EditDynamicParams params) {
    return remoteDataSource.editDynamic(params);
  }
}
