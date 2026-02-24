import 'package:PiliPlus/features/pgc_index/data/datasources/pgc_index_remote_datasource.dart';
import 'package:PiliPlus/features/pgc_index/data/repositories/pgc_index_repository_impl.dart';
import 'package:PiliPlus/features/pgc_index/domain/repositories/pgc_index_repository.dart';
import 'package:PiliPlus/features/pgc_index/domain/usecases/get_pgc_index.dart';
import 'package:PiliPlus/features/pgc_index/presentation/providers/pgc_index_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PGC索引远程数据源Provider
final pgcIndexRemoteDataSourceProvider =
    Provider<PgcIndexRemoteDataSource>((ref) {
  return PgcIndexRemoteDataSource();
});

/// PGC索引仓库Provider
final pgcIndexRepositoryProvider = Provider<PgcIndexRepository>((ref) {
  final remoteDataSource = ref.watch(pgcIndexRemoteDataSourceProvider);
  return PgcIndexRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取PGC索引条件用例Provider
final getPgcIndexConditionUseCaseProvider =
    Provider<GetPgcIndexConditionUseCase>((ref) {
  final repository = ref.watch(pgcIndexRepositoryProvider);
  return GetPgcIndexConditionUseCase(repository);
});

/// 获取PGC索引结果用例Provider
final getPgcIndexResultUseCaseProvider =
    Provider<GetPgcIndexResultUseCase>((ref) {
  final repository = ref.watch(pgcIndexRepositoryProvider);
  return GetPgcIndexResultUseCase(repository);
});

/// PGC索引Controller Provider
final pgcIndexControllerProvider =
    Provider.family<PgcIndexController, int?>((ref, indexType) {
  return PgcIndexController(indexType: indexType);
});

/// PGC索引状态Provider
final pgcIndexStateProvider =
    Provider.family<PgcIndexState, int?>((ref, indexType) {
  final controller = ref.watch(pgcIndexControllerProvider(indexType));
  return controller.state;
});
