import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/live_area/domain/repositories/live_area_repository.dart';

/// Use case for setting live favorite tags
class SetLiveFavTagUseCase {
  const SetLiveFavTagUseCase(this._repository);

  final LiveAreaRepository _repository;

  Future<LoadingState<void>> call(String ids) => _repository.setLiveFavTag(ids);
}
