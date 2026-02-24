import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/fav/fav_topic/data/datasources/fav_topic_remote_datasource.dart';
import 'package:PiliPlus/features/fav/fav_topic/data/repositories/fav_topic_repository_impl.dart';
import 'package:PiliPlus/features/fav/fav_topic/domain/repositories/fav_topic_repository.dart';
import 'package:PiliPlus/features/fav/fav_topic/domain/usecases/get_fav_topics_usecase.dart';
import 'package:PiliPlus/features/fav/fav_topic/domain/usecases/remove_topic_usecase.dart';
import 'package:PiliPlus/features/fav/fav_topic/presentation/providers/fav_topic_list_controller.dart';

/// Provider for FavTopicRemoteDatasource
final favTopicRemoteDatasourceProvider =
    Provider<FavTopicRemoteDatasource>((ref) {
  return FavTopicRemoteDatasource();
});

/// Provider for FavTopicRepository
final favTopicRepositoryProvider = Provider<FavTopicRepository>((ref) {
  final datasource = ref.watch(favTopicRemoteDatasourceProvider);
  return FavTopicRepositoryImpl(datasource);
});

/// Provider for GetFavTopicsUseCase
final getFavTopicsUseCaseProvider = Provider<GetFavTopicsUseCase>((ref) {
  final repository = ref.watch(favTopicRepositoryProvider);
  return GetFavTopicsUseCase(repository);
});

/// Provider for RemoveTopicUseCase
final removeTopicUseCaseProvider = Provider<RemoveTopicUseCase>((ref) {
  final repository = ref.watch(favTopicRepositoryProvider);
  return RemoveTopicUseCase(repository);
});

/// Provider for FavTopicController
final favTopicControllerProvider =
    Provider<FavTopicController>((ref) {
  return FavTopicController(
    getFavTopicsUseCase: ref.watch(getFavTopicsUseCaseProvider),
    removeTopicUseCase: ref.watch(removeTopicUseCaseProvider),
  );
});
