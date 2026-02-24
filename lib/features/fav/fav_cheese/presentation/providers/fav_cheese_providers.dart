import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/fav/fav_cheese/data/datasources/fav_cheese_remote_datasource.dart';
import 'package:PiliPlus/features/fav/fav_cheese/data/repositories/fav_cheese_repository_impl.dart';
import 'package:PiliPlus/features/fav/fav_cheese/domain/repositories/fav_cheese_repository.dart';
import 'package:PiliPlus/features/fav/fav_cheese/domain/usecases/get_fav_cheese_usecase.dart';
import 'package:PiliPlus/features/fav/fav_cheese/domain/usecases/remove_cheese_usecase.dart';
import 'package:PiliPlus/features/fav/fav_cheese/presentation/providers/fav_cheese_list_controller.dart';

/// Provider for FavCheeseRemoteDatasource
final favCheeseRemoteDatasourceProvider =
    Provider<FavCheeseRemoteDatasource>((ref) {
  return FavCheeseRemoteDatasource();
});

/// Provider for FavCheeseRepository
final favCheeseRepositoryProvider = Provider<FavCheeseRepository>((ref) {
  final datasource = ref.watch(favCheeseRemoteDatasourceProvider);
  return FavCheeseRepositoryImpl(datasource);
});

/// Provider for GetFavCheeseUseCase
final getFavCheeseUseCaseProvider = Provider<GetFavCheeseUseCase>((ref) {
  final repository = ref.watch(favCheeseRepositoryProvider);
  return GetFavCheeseUseCase(repository);
});

/// Provider for RemoveCheeseUseCase
final removeCheeseUseCaseProvider = Provider<RemoveCheeseUseCase>((ref) {
  final repository = ref.watch(favCheeseRepositoryProvider);
  return RemoveCheeseUseCase(repository);
});

/// Provider for FavCheeseController
final favCheeseControllerProvider =
    Provider<FavCheeseController>((ref) {
  return FavCheeseController(
    getFavCheeseUseCase: ref.watch(getFavCheeseUseCaseProvider),
    removeCheeseUseCase: ref.watch(removeCheeseUseCaseProvider),
  );
});
