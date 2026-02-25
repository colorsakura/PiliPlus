import 'package:PiliPlus/features/popular_precious/domain/entities/popular_precious_item_entity.dart';
import 'package:PiliPlus/features/popular_precious/domain/repositories/popular_precious_repository.dart';
import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of popular precious repository
class PopularPreciousRepositoryImpl implements PopularPreciousRepository {
  final VideoRemoteDataSource _remoteDataSource;

  PopularPreciousRepositoryImpl({
    required VideoRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<PopularPreciousItemEntity>>> fetchPopularPrecious({
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.popularPrecious(page: page);
      final items = data['list'] as List? ?? [];
      // Convert List<dynamic> to List<PopularPreciousItemEntity>
      final entityList = items
          .map((item) => item as PopularPreciousItemEntity)
          .toList();
      return Success(entityList);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
