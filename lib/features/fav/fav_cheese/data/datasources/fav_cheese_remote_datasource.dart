import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_cheese/data.dart';
import 'package:PiliPlus/models/space/space_cheese/item.dart';
import 'package:PiliPlus/utils/accounts.dart';

/// Remote data source for favorite cheese
class FavCheeseRemoteDatasource {
  final int mid = Accounts.main.mid;

  /// Get favorite cheese from API
  Future<LoadingState<SpaceCheeseData>> getFavCheese({required int page}) {
    return FavHttp.favPugv(mid: mid, page: page);
  }

  /// Remove cheese from favorites via API
  Future<LoadingState<void>> removeCheese(int sid) {
    return FavHttp.delFavPugv(sid);
  }
}

/// Extension to convert SpaceCheeseData to List<SpaceCheeseItem>
extension SpaceCheeseDataExtension on SpaceCheeseData {
  List<SpaceCheeseItem> toItemList() {
    return items ?? [];
  }

  bool get hasNextPage => page?.next == true;
}
