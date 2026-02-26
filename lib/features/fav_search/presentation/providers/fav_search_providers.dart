import 'package:PiliPlus/features/fav_search/data/datasources/fav_search_remote_datasource.dart';
import 'package:PiliPlus/features/fav_search/data/repositories/fav_search_repository_impl.dart';
import 'package:PiliPlus/features/fav_search/domain/repositories/fav_search_repository.dart';
import 'package:PiliPlus/features/fav_search/domain/usecases/search_favorites.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite search remote data source provider
final favSearchRemoteDataSourceProvider = Provider<FavSearchRemoteDataSource>((ref) {
  return const FavSearchRemoteDataSourceImpl();
});

/// Favorite search repository provider
final favSearchRepositoryProvider = Provider<FavSearchRepository>((ref) {
  final remoteDataSource = ref.watch(favSearchRemoteDataSourceProvider);
  return FavSearchRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Search favorites use case provider
final searchFavoritesUseCaseProvider = Provider<SearchFavorites>((ref) {
  final repository = ref.watch(favSearchRepositoryProvider);
  return SearchFavorites(repository);
});
