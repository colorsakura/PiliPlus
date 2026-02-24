import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_cheese/item.dart';
import 'package:PiliPlus/features/fav/fav_cheese/domain/repositories/fav_cheese_repository.dart';

/// Use case for getting favorite cheese
class GetFavCheeseUseCase {
  const GetFavCheeseUseCase(this._repository);

  final FavCheeseRepository _repository;

  Future<LoadingState<List<SpaceCheeseItem>>> call(int page) {
    return _repository.getFavCheese(page);
  }
}
