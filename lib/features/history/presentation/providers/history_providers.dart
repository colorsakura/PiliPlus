import 'package:PiliPlus/features/history/data/datasources/history_remote_datasource.dart';
import 'package:PiliPlus/features/history/data/repositories/history_repository_impl.dart';
import 'package:PiliPlus/features/history/domain/repositories/history_repository.dart';
import 'package:PiliPlus/features/history/domain/usecases/delete_history.dart';
import 'package:PiliPlus/features/history/domain/usecases/fetch_history.dart';
import 'package:PiliPlus/features/history/domain/usecases/get_history_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 历史记录远程数据源Provider
final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((
  ref,
) {
  return HistoryRemoteDataSource();
});

/// 历史记录仓库Provider
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final remoteDataSource = ref.watch(historyRemoteDataSourceProvider);
  return HistoryRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取历史记录用例Provider
final fetchHistoryUseCaseProvider = Provider<FetchHistoryUseCase>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return FetchHistoryUseCase(repository);
});

/// 删除历史记录用例Provider
final deleteHistoryUseCaseProvider = Provider<DeleteHistoryUseCase>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return DeleteHistoryUseCase(repository);
});

/// 获取历史记录状态用例Provider
final getHistoryStatusUseCaseProvider = Provider<GetHistoryStatusUseCase>((
  ref,
) {
  final repository = ref.watch(historyRepositoryProvider);
  return GetHistoryStatusUseCase(repository);
});
