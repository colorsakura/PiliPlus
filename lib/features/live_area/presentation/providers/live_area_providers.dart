import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/features/live_area/data/datasources/live_area_remote_datasource.dart';
import 'package:PiliPlus/features/live_area/data/repositories/live_area_repository_impl.dart';
import 'package:PiliPlus/features/live_area/domain/repositories/live_area_repository.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/get_live_area_list_usecase.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/get_live_fav_tag_usecase.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/set_live_fav_tag_usecase.dart';
import 'package:PiliPlus/features/live_area/presentation/providers/live_area_controller.dart';

// Remote Datasource Provider
final liveAreaRemoteDatasourceProvider = Provider<LiveAreaRemoteDatasource>((
  ref,
) {
  return const LiveAreaRemoteDatasource();
});

// Repository Provider
final liveAreaRepositoryProvider = Provider<LiveAreaRepository>((ref) {
  final datasource = ref.watch(liveAreaRemoteDatasourceProvider);
  return LiveAreaRepositoryImpl(datasource);
});

// Use Case Providers
final getLiveAreaListUseCaseProvider = Provider<GetLiveAreaListUseCase>((ref) {
  final repository = ref.watch(liveAreaRepositoryProvider);
  return GetLiveAreaListUseCase(repository);
});

final getLiveFavTagUseCaseProvider = Provider<GetLiveFavTagUseCase>((ref) {
  final repository = ref.watch(liveAreaRepositoryProvider);
  return GetLiveFavTagUseCase(repository);
});

final setLiveFavTagUseCaseProvider = Provider<SetLiveFavTagUseCase>((ref) {
  final repository = ref.watch(liveAreaRepositoryProvider);
  return SetLiveFavTagUseCase(repository);
});

// Login status provider
final isLoginProvider = Provider<bool>((ref) {
  return Accounts.main.isLogin;
});

// Controller Provider
final liveAreaControllerProvider = Provider<LiveAreaController>((ref) {
  return LiveAreaController(
    isLogin: ref.watch(isLoginProvider),
    getLiveAreaListUseCase: ref.watch(getLiveAreaListUseCaseProvider),
    getLiveFavTagUseCase: ref.watch(getLiveFavTagUseCaseProvider),
    setLiveFavTagUseCase: ref.watch(setLiveFavTagUseCaseProvider),
  );
});
