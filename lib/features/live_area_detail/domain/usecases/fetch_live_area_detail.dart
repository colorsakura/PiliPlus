import 'package:PiliPlus/features/live_area_detail/domain/entities/live_area_item_entity.dart';
import 'package:PiliPlus/features/live_area_detail/domain/repositories/live_area_detail_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching live area detail
class FetchLiveAreaDetailUseCase {
  const FetchLiveAreaDetailUseCase(this._repository);

  final LiveAreaDetailRepository _repository;

  Future<LoadingState<List<LiveAreaItemEntity>>> call({
    required dynamic parentAreaId,
  }) {
    return _repository.fetchLiveAreaDetail(parentAreaId: parentAreaId);
  }
}
