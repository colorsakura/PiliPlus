import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/features/live_area/domain/repositories/live_area_repository.dart';

/// Use case for getting live favorite tags
class GetLiveFavTagUseCase {
  const GetLiveFavTagUseCase(this._repository);

  final LiveAreaRepository _repository;

  Future<LoadingState<List<AreaItem>>> call() => _repository.getLiveFavTag();
}
