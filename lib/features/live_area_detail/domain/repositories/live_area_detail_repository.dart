import 'package:PiliPlus/features/live_area_detail/domain/entities/live_area_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for live area detail data
abstract class LiveAreaDetailRepository {
  Future<LoadingState<List<LiveAreaItemEntity>>> fetchLiveAreaDetail({
    required dynamic parentAreaId,
  });
}
