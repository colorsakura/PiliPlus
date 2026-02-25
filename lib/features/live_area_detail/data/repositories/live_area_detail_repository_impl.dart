import 'package:PiliPlus/features/live_area_detail/domain/entities/live_area_item_entity.dart';
import 'package:PiliPlus/features/live_area_detail/domain/repositories/live_area_detail_repository.dart';
import 'package:PiliPlus/features/live/data/datasources/live_remote_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of live area detail repository
class LiveAreaDetailRepositoryImpl implements LiveAreaDetailRepository {
  final LiveRemoteDataSource _remoteDataSource;

  LiveAreaDetailRepositoryImpl({
    required LiveRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<LiveAreaItemEntity>>> fetchLiveAreaDetail({
    required dynamic parentAreaId,
  }) async {
    try {
      final items = await _remoteDataSource.liveRoomAreaList(
        parentid: parentAreaId,
      );
      // Convert List<dynamic> to List<LiveAreaItemEntity>
      final entityList = items
          .map((item) => item as LiveAreaItemEntity)
          .toList();
      return Success(entityList);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
