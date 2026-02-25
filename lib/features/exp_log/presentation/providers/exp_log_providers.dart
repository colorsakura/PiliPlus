import 'package:PiliPlus/features/exp_log/data/datasources/exp_log_remote_datasource.dart';
import 'package:PiliPlus/features/exp_log/data/repositories/exp_log_repository_impl.dart';
import 'package:PiliPlus/features/exp_log/domain/repositories/exp_log_repository.dart';
import 'package:PiliPlus/features/exp_log/domain/usecases/get_exp_log.dart';
import 'package:PiliPlus/features/exp_log/presentation/providers/exp_log_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 经验日志远程数据源Provider
final expLogRemoteDataSourceProvider = Provider<ExpLogRemoteDataSource>((ref) {
  return ExpLogRemoteDataSource();
});

/// 经验日志仓库Provider
final expLogRepositoryProvider = Provider<ExpLogRepository>((ref) {
  final remoteDataSource = ref.watch(expLogRemoteDataSourceProvider);
  return ExpLogRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取经验日志用例Provider
final getExpLogUseCaseProvider = Provider<GetExpLogUseCase>((ref) {
  final repository = ref.watch(expLogRepositoryProvider);
  return GetExpLogUseCase(repository);
});

/// 经验日志Controller Provider
final expLogControllerProvider =
    NotifierProvider<ExpLogController, ExpLogState>(
      ExpLogController.new,
    );
