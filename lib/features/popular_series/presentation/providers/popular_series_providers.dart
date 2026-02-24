import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/popular_series/data/datasources/popular_series_remote_datasource.dart';
import 'package:PiliPlus/features/popular_series/data/repositories/popular_series_repository_impl.dart';
import 'package:PiliPlus/features/popular_series/domain/repositories/popular_series_repository.dart';
import 'package:PiliPlus/features/popular_series/domain/usecases/get_popular_series_data.dart';
import 'package:PiliPlus/features/popular_series/presentation/providers/popular_series_controller.dart';

/// Popular series remote data source provider
final popularSeriesRemoteDataSourceProvider =
    Provider<PopularSeriesRemoteDataSource>((ref) {
  return PopularSeriesRemoteDataSource();
});

/// Popular series repository provider
final popularSeriesRepositoryProvider =
    Provider<PopularSeriesRepository>((ref) {
  final remoteDataSource = ref.watch(popularSeriesRemoteDataSourceProvider);
  return PopularSeriesRepositoryImpl(remoteDataSource);
});

/// Get popular series list use case provider
final getPopularSeriesListUseCaseProvider =
    Provider<GetPopularSeriesListUseCase>((ref) {
  final repository = ref.watch(popularSeriesRepositoryProvider);
  return GetPopularSeriesListUseCase(repository);
});

/// Get popular series one use case provider
final getPopularSeriesOneUseCaseProvider =
    Provider<GetPopularSeriesOneUseCase>((ref) {
  final repository = ref.watch(popularSeriesRepositoryProvider);
  return GetPopularSeriesOneUseCase(repository);
});

/// Popular series controller provider
final popularSeriesControllerProvider =
    Provider<PopularSeriesController>((ref) {
  return PopularSeriesController(
    getPopularSeriesListUseCase: ref.read(getPopularSeriesListUseCaseProvider),
    getPopularSeriesOneUseCase: ref.read(getPopularSeriesOneUseCaseProvider),
  );
});
