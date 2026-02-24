import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/data/datasources/dyn_topic_rcmd_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/data/repositories/dyn_topic_rcmd_repository_impl.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/domain/repositories/dyn_topic_rcmd_repository.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/domain/usecases/get_dyn_topic_rcmd.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/presentation/providers/dyn_topic_rcmd_controller.dart';

/// Dynamics topic recommendation remote data source provider
final dynTopicRcmdRemoteDataSourceProvider =
    Provider<DynTopicRcmdRemoteDataSource>((ref) {
  return DynTopicRcmdRemoteDataSource();
});

/// Dynamics topic recommendation repository provider
final dynTopicRcmdRepositoryProvider =
    Provider<DynTopicRcmdRepository>((ref) {
  final remoteDataSource = ref.watch(dynTopicRcmdRemoteDataSourceProvider);
  return DynTopicRcmdRepositoryImpl(remoteDataSource);
});

/// Get dynamics topic recommendation use case provider
final getDynTopicRcmdUseCaseProvider = Provider<GetDynTopicRcmdUseCase>((ref) {
  final repository = ref.watch(dynTopicRcmdRepositoryProvider);
  return GetDynTopicRcmdUseCase(repository);
});

/// Dynamics topic recommendation controller provider
final dynTopicRcmdControllerProvider =
    Provider<DynTopicRcmdController>((ref) {
  return DynTopicRcmdController(
    getDynTopicRcmdUseCase: ref.read(getDynTopicRcmdUseCaseProvider),
  );
});
