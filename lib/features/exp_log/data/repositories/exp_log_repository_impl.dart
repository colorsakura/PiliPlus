import 'package:PiliPlus/features/exp_log/data/datasources/exp_log_remote_datasource.dart';
import 'package:PiliPlus/features/exp_log/domain/entities/exp_log_item.dart';
import 'package:PiliPlus/features/exp_log/domain/repositories/exp_log_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 经验日志仓库实现
///
/// 实现经验日志仓库接口,使用远程数据源获取数据
class ExpLogRepositoryImpl implements ExpLogRepository {
  final ExpLogRemoteDataSource _remoteDataSource;

  ExpLogRepositoryImpl({
    required ExpLogRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<ExpLogResultEntity>> getExpLog() async {
    final result = await _remoteDataSource.getExpLog();
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(
          ExpLogResultEntity.fromModel(response.list),
        ),
      Error() => result as LoadingState<ExpLogResultEntity>,
    };
  }
}
