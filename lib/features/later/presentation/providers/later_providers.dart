import 'package:PiliPlus/features/later/data/datasources/later_remote_datasource.dart';
import 'package:PiliPlus/features/later/data/repositories/later_repository_impl.dart';
import 'package:PiliPlus/features/later/domain/repositories/later_repository.dart';
import 'package:PiliPlus/features/later/domain/usecases/clear_later.dart';
import 'package:PiliPlus/features/later/domain/usecases/fetch_later.dart';
import 'package:PiliPlus/features/later/domain/usecases/remove_later_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 远程数据源Provider
final laterRemoteDataSourceProvider = Provider<LaterRemoteDataSource>((ref) {
  return LaterRemoteDataSource();
});

/// 仓库Provider
final laterRepositoryProvider = Provider<LaterRepository>((ref) {
  final remoteDataSource = ref.watch(laterRemoteDataSourceProvider);
  return LaterRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取稍后再看列表用例Provider
final fetchLaterUseCaseProvider = Provider<FetchLaterUseCase>((ref) {
  final repository = ref.watch(laterRepositoryProvider);
  return FetchLaterUseCase(repository);
});

/// 移除稍后再看项用例Provider
final removeLaterItemUseCaseProvider = Provider<RemoveLaterItemUseCase>((ref) {
  final repository = ref.watch(laterRepositoryProvider);
  return RemoveLaterItemUseCase(repository);
});

/// 清空稍后再看用例Provider
final clearLaterUseCaseProvider = Provider<ClearLaterUseCase>((ref) {
  final repository = ref.watch(laterRepositoryProvider);
  return ClearLaterUseCase(repository);
});
