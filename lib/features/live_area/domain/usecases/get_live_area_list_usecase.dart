import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_area_list/area_list.dart';
import 'package:PiliPlus/features/live_area/domain/repositories/live_area_repository.dart';

/// Use case for getting live area list
class GetLiveAreaListUseCase {
  const GetLiveAreaListUseCase(this._repository);

  final LiveAreaRepository _repository;

  Future<LoadingState<List<AreaList>?>> call() => _repository.getLiveAreaList();
}
