import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/fav/fav_article/data/datasources/fav_article_remote_datasource.dart';
import 'package:PiliPlus/features/fav/fav_article/data/repositories/fav_article_repository_impl.dart';
import 'package:PiliPlus/features/fav/fav_article/domain/repositories/fav_article_repository.dart';
import 'package:PiliPlus/features/fav/fav_article/domain/usecases/get_fav_articles_usecase.dart';
import 'package:PiliPlus/features/fav/fav_article/domain/usecases/remove_article_usecase.dart';
import 'package:PiliPlus/features/fav/fav_article/presentation/providers/fav_article_list_controller.dart';

/// Provider for FavArticleRemoteDatasource
final favArticleRemoteDatasourceProvider =
    Provider<FavArticleRemoteDatasource>((ref) {
  return FavArticleRemoteDatasource();
});

/// Provider for FavArticleRepository
final favArticleRepositoryProvider = Provider<FavArticleRepository>((ref) {
  final datasource = ref.watch(favArticleRemoteDatasourceProvider);
  return FavArticleRepositoryImpl(datasource);
});

/// Provider for GetFavArticlesUseCase
final getFavArticlesUseCaseProvider = Provider<GetFavArticlesUseCase>((ref) {
  final repository = ref.watch(favArticleRepositoryProvider);
  return GetFavArticlesUseCase(repository);
});

/// Provider for RemoveArticleUseCase
final removeArticleUseCaseProvider = Provider<RemoveArticleUseCase>((ref) {
  final repository = ref.watch(favArticleRepositoryProvider);
  return RemoveArticleUseCase(repository);
});

/// Provider for FavArticleController
final favArticleControllerProvider =
    Provider<FavArticleController>((ref) {
  return FavArticleController(
    getFavArticlesUseCase: ref.watch(getFavArticlesUseCaseProvider),
    removeArticleUseCase: ref.watch(removeArticleUseCaseProvider),
  );
});
