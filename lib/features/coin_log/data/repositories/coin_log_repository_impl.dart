import 'package:PiliPlus/features/coin_log/data/datasources/coin_log_remote_datasource.dart';
import 'package:PiliPlus/features/coin_log/domain/entities/coin_log_item.dart';
import 'package:PiliPlus/features/coin_log/domain/repositories/coin_log_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 硬币日志仓库实现
///
/// 实现硬币日志仓库接口,使用远程数据源获取数据
class CoinLogRepositoryImpl implements CoinLogRepository {
  final CoinLogRemoteDataSource _remoteDataSource;

  CoinLogRepositoryImpl({
    required CoinLogRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<CoinLogResultEntity>> getCoinLog() async {
    final result = await _remoteDataSource.getCoinLog();
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(
        CoinLogResultEntity.fromModel(response.list),
      ),
      Error() => result as LoadingState<CoinLogResultEntity>,
    };
  }
}
