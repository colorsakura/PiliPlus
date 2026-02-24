import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav/fav_cheese/domain/repositories/fav_cheese_repository.dart';

/// Use case for removing cheese from favorites
class RemoveCheeseUseCase {
  const RemoveCheeseUseCase(this._repository);

  final FavCheeseRepository _repository;

  Future<LoadingState<void>> call(int sid) {
    return _repository.removeCheese(sid);
  }
}
