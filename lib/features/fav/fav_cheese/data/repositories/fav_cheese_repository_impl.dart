import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_cheese/item.dart';
import 'package:PiliPlus/features/fav/fav_cheese/domain/repositories/fav_cheese_repository.dart';
import 'package:PiliPlus/features/fav/fav_cheese/data/datasources/fav_cheese_remote_datasource.dart';

/// Repository implementation for favorite cheese
class FavCheeseRepositoryImpl implements FavCheeseRepository {
  const FavCheeseRepositoryImpl(this._remoteDatasource);

  final FavCheeseRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<SpaceCheeseItem>>> getFavCheese(int page) async {
    final result = await _remoteDatasource.getFavCheese(page: page);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response.toItemList()),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  @override
  Future<LoadingState<void>> removeCheese(int sid) {
    return _remoteDatasource.removeCheese(sid);
  }
}
