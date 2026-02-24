import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_cheese/item.dart';

/// Repository interface for favorite cheese (courses)
abstract class FavCheeseRepository {
  /// Get favorite cheese list
  Future<LoadingState<List<SpaceCheeseItem>>> getFavCheese(int page);

  /// Remove cheese from favorites
  Future<LoadingState<void>> removeCheese(int sid);
}
