import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/data/datasources/dyn_reserve_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/data/repositories/dyn_reserve_repository_impl.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/domain/repositories/dyn_reserve_repository.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/domain/usecases/get_dyn_reserve_data.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/presentation/providers/dyn_create_reserve_controller.dart';

/// Dynamics reserve remote data source provider
final dynReserveRemoteDataSourceProvider =
    Provider<DynReserveRemoteDataSource>((ref) {
  return DynReserveRemoteDataSource();
});

/// Dynamics reserve repository provider
final dynReserveRepositoryProvider = Provider<DynReserveRepository>((ref) {
  final remoteDataSource = ref.watch(dynReserveRemoteDataSourceProvider);
  return DynReserveRepositoryImpl(remoteDataSource);
});

/// Get reserve info use case provider
final getReserveInfoUseCaseProvider = Provider<GetReserveInfoUseCase>((ref) {
  final repository = ref.watch(dynReserveRepositoryProvider);
  return GetReserveInfoUseCase(repository);
});

/// Create reserve use case provider
final createReserveUseCaseProvider = Provider<CreateReserveUseCase>((ref) {
  final repository = ref.watch(dynReserveRepositoryProvider);
  return CreateReserveUseCase(repository);
});

/// Update reserve use case provider
final updateReserveUseCaseProvider = Provider<UpdateReserveUseCase>((ref) {
  final repository = ref.watch(dynReserveRepositoryProvider);
  return UpdateReserveUseCase(repository);
});

/// Dynamics create reserve controller provider family
final dynCreateReserveControllerProvider =
    Provider.family<DynCreateReserveController, int?>((
  ref,
  sid,
) {
  return DynCreateReserveController(
    getReserveInfoUseCase: ref.read(getReserveInfoUseCaseProvider),
    createReserveUseCase: ref.read(createReserveUseCaseProvider),
    updateReserveUseCase: ref.read(updateReserveUseCaseProvider),
    sid: sid,
  );
});
