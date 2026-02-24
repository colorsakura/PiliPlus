import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:PiliPlus/features/dynamics/data/datasources/dynamics_local_datasource.dart';
import 'package:PiliPlus/features/dynamics/data/datasources/dynamics_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics/data/repositories/dynamics_repository_impl.dart';
import 'package:PiliPlus/features/dynamics/data/repositories/dynamics_tab_repository_impl.dart';
import 'package:PiliPlus/features/dynamics/domain/usecases/fetch_dynamics.dart';
import 'package:PiliPlus/features/dynamics/domain/usecases/fetch_follow_up.dart';
import 'package:PiliPlus/features/dynamics/domain/usecases/get_dynamics_tab_config.dart';

/// Local data source provider.
final dynamicsLocalDataSourceProvider = Provider<DynamicsLocalDataSource>((ref) {
  return const DynamicsLocalDataSource();
});

/// Remote data source provider.
final dynamicsRemoteDataSourceProvider = Provider<DynamicsRemoteDataSource>((ref) {
  return const DynamicsRemoteDataSource();
});

/// Dynamics repository provider.
final dynamicsRepositoryProvider = Provider<DynamicsRepositoryImpl>((ref) {
  return DynamicsRepositoryImpl(
    remoteDataSource: ref.watch(dynamicsRemoteDataSourceProvider),
  );
});

/// Dynamics tab repository provider.
final dynamicsTabRepositoryProvider = Provider<DynamicsTabRepositoryImpl>((ref) {
  return DynamicsTabRepositoryImpl(
    localDataSource: ref.watch(dynamicsLocalDataSourceProvider),
  );
});

/// Fetch dynamics use case provider.
final fetchDynamicsUseCaseProvider = Provider<FetchDynamicsUseCase>((ref) {
  return FetchDynamicsUseCase(ref.watch(dynamicsRepositoryProvider));
});

/// Fetch follow-up use case provider.
final fetchFollowUpUseCaseProvider = Provider<FetchFollowUpUseCase>((ref) {
  return FetchFollowUpUseCase(ref.watch(dynamicsRepositoryProvider));
});

/// Fetch all followings use case provider.
final fetchAllFollowingsUseCaseProvider = Provider<FetchAllFollowingsUseCase>((ref) {
  return FetchAllFollowingsUseCase(ref.watch(dynamicsRepositoryProvider));
});

/// Fetch dynamics UP list use case provider.
final fetchDynamicsUpListUseCaseProvider = Provider<FetchDynamicsUpListUseCase>((ref) {
  return FetchDynamicsUpListUseCase(ref.watch(dynamicsRepositoryProvider));
});

/// Get dynamics tab config use case provider.
final getDynamicsTabConfigUseCaseProvider = Provider<GetDynamicsTabConfigUseCase>((ref) {
  return GetDynamicsTabConfigUseCase(ref.watch(dynamicsTabRepositoryProvider));
});

