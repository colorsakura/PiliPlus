import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/pgc/data/datasources/pgc_remote_datasource.dart';
import 'package:PiliPlus/features/pgc/data/repositories/pgc_repository_impl.dart';
import 'package:PiliPlus/features/pgc/domain/repositories/pgc_repository.dart';
import 'package:PiliPlus/features/pgc/domain/usecases/get_pgc_data.dart';
import 'package:PiliPlus/features/pgc/presentation/providers/pgc_controller.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';

/// PGC remote data source provider
final pgcRemoteDataSourceProvider = Provider<PgcApiDataSource>((ref) {
  return PgcApiDataSource();
});

/// PGC repository provider
final pgcRepositoryProvider = Provider<PgcRepository>((ref) {
  final remoteDataSource = ref.watch(pgcRemoteDataSourceProvider);
  return PgcRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Get PGC index use case provider
final getPgcIndexUseCaseProvider = Provider<GetPgcIndexUseCase>((ref) {
  final repository = ref.watch(pgcRepositoryProvider);
  return GetPgcIndexUseCase(repository);
});

/// Get PGC follow use case provider
final getPgcFollowUseCaseProvider = Provider<GetPgcFollowUseCase>((ref) {
  final repository = ref.watch(pgcRepositoryProvider);
  return GetPgcFollowUseCase(repository);
});

/// Get PGC timeline use case provider
final getPgcTimelineUseCaseProvider = Provider<GetPgcTimelineUseCase>((ref) {
  final repository = ref.watch(pgcRepositoryProvider);
  return GetPgcTimelineUseCase(repository);
});

/// PGC controller provider family (keyed by tab type)
///
/// Uses Provider.family to create a unique controller for each tab type
/// Note: Not using autoDispose because the page uses AutomaticKeepAliveClientMixin
final pgcControllerProvider =
    Provider.family<PgcController, HomeTabType>((ref, tabType) {
  final controller = PgcController(
    tabType: tabType,
    getPgcIndexUseCase: ref.read(getPgcIndexUseCaseProvider),
    getPgcFollowUseCase: ref.read(getPgcFollowUseCaseProvider),
    getPgcTimelineUseCase: ref.read(getPgcTimelineUseCaseProvider),
  );

  // Don't dispose here - let it be managed by the framework
  // The controller will be disposed when the app shuts down

  return controller;
});
