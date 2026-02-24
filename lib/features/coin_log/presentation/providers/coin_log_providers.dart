import 'package:PiliPlus/features/coin_log/data/datasources/coin_log_remote_datasource.dart';
import 'package:PiliPlus/features/coin_log/data/repositories/coin_log_repository_impl.dart';
import 'package:PiliPlus/features/coin_log/domain/repositories/coin_log_repository.dart';
import 'package:PiliPlus/features/coin_log/domain/usecases/get_coin_log.dart';
import 'package:PiliPlus/features/coin_log/presentation/providers/coin_log_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 硬币日志远程数据源Provider
final coinLogRemoteDataSourceProvider = Provider<CoinLogRemoteDataSource>((ref) {
  return CoinLogRemoteDataSource();
});

/// 硬币日志仓库Provider
final coinLogRepositoryProvider = Provider<CoinLogRepository>((ref) {
  final remoteDataSource = ref.watch(coinLogRemoteDataSourceProvider);
  return CoinLogRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取硬币日志用例Provider
final getCoinLogUseCaseProvider = Provider<GetCoinLogUseCase>((ref) {
  final repository = ref.watch(coinLogRepositoryProvider);
  return GetCoinLogUseCase(repository);
});

/// 硬币日志Controller Provider
final coinLogControllerProvider =
    NotifierProvider<CoinLogController, CoinLogState>(
  CoinLogController.new,
);
