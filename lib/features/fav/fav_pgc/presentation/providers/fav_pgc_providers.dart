import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/fav/fav_pgc/data/datasources/fav_pgc_remote_datasource.dart';
import 'package:PiliPlus/features/fav/fav_pgc/data/repositories/fav_pgc_repository_impl.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/repositories/fav_pgc_repository.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/usecases/get_fav_pgc_usecase.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/usecases/remove_pgc_usecase.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/usecases/update_pgc_follow_status_usecase.dart';
import 'package:PiliPlus/features/fav/fav_pgc/presentation/providers/fav_pgc_list_controller.dart';

/// Provider for FavPgcRemoteDatasource
final favPgcRemoteDatasourceProvider = Provider<FavPgcRemoteDatasource>((ref) {
  return FavPgcRemoteDatasource();
});

/// Provider for FavPgcRepository
final favPgcRepositoryProvider = Provider<FavPgcRepository>((ref) {
  final datasource = ref.watch(favPgcRemoteDatasourceProvider);
  return FavPgcRepositoryImpl(datasource);
});

/// Provider for GetFavPgcUseCase
final getFavPgcUseCaseProvider = Provider<GetFavPgcUseCase>((ref) {
  final repository = ref.watch(favPgcRepositoryProvider);
  return GetFavPgcUseCase(repository);
});

/// Provider for RemovePgcUseCase
final removePgcUseCaseProvider = Provider<RemovePgcUseCase>((ref) {
  final repository = ref.watch(favPgcRepositoryProvider);
  return RemovePgcUseCase(repository);
});

/// Provider for UpdatePgcFollowStatusUseCase
final updatePgcFollowStatusUseCaseProvider =
    Provider<UpdatePgcFollowStatusUseCase>((ref) {
      final repository = ref.watch(favPgcRepositoryProvider);
      return UpdatePgcFollowStatusUseCase(repository);
    });

/// Provider family for FavPgcController (parametrized by type and followStatus)
final favPgcControllerProvider =
    Provider.family<FavPgcController, ({int type, int followStatus})>((
      ref,
      params,
    ) {
      return FavPgcController(
        type: params.type,
        followStatus: params.followStatus,
        getFavPgcUseCase: ref.watch(getFavPgcUseCaseProvider),
        removePgcUseCase: ref.watch(removePgcUseCaseProvider),
        updatePgcFollowStatusUseCase: ref.watch(
          updatePgcFollowStatusUseCaseProvider,
        ),
      );
    });
