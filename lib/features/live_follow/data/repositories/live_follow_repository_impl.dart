import 'package:PiliPlus/features/live_follow/domain/entities/live_follow_item_entity.dart';
import 'package:PiliPlus/features/live_follow/domain/repositories/live_follow_repository.dart';
import 'package:PiliPlus/features/live/data/datasources/live_remote_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of live follow repository
class LiveFollowRepositoryImpl implements LiveFollowRepository {
  final LiveRemoteDataSource _remoteDataSource;

  LiveFollowRepositoryImpl({
    required LiveRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<LiveFollowItemEntity>>> fetchLiveFollow({
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.liveFollow(page);
      final items = data['list'] as List? ?? [];
      // Convert List<dynamic> to List<LiveFollowItemEntity>
      final entityList = items
          .map((item) => item as LiveFollowItemEntity)
          .toList();
      return Success(entityList);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
