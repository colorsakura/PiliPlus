import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/popular_precious/data/repositories/popular_precious_repository_impl.dart';
import 'package:PiliPlus/features/popular_precious/domain/usecases/fetch_popular_precious.dart';
import 'package:PiliPlus/features/popular_precious/presentation/providers/popular_precious_list_controller.dart';
import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';

final videoRemoteDataSourceProvider = Provider<VideoRemoteDataSource>((ref) {
  return VideoRemoteDataSource();
});

final popularPreciousRepositoryProvider =
    Provider<PopularPreciousRepositoryImpl>((ref) {
  return PopularPreciousRepositoryImpl(
    remoteDataSource: ref.watch(videoRemoteDataSourceProvider),
  );
});

final fetchPopularPreciousUseCaseProvider =
    Provider<FetchPopularPreciousUseCase>((ref) {
  return FetchPopularPreciousUseCase(
    ref.watch(popularPreciousRepositoryProvider),
  );
});

final popularPreciousListControllerProvider =
    Provider<PopularPreciousListController>((ref) {
  return PopularPreciousListController(
    fetchPopularPrecious: ref.watch(fetchPopularPreciousUseCaseProvider),
  );
});
