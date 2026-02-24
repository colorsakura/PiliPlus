import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub_detail/data.dart';

/// Remote datasource for subscription detail data
class SubscriptionDetailRemoteDatasource {
  const SubscriptionDetailRemoteDatasource();

  /// Fetch subscription folder detail from API
  Future<LoadingState<SubDetailData>> getFavSeasonList({
    required int id,
    required int ps,
    required int pn,
  }) =>
      FavHttp.favSeasonList(
        id: id,
        ps: ps,
        pn: pn,
      );
}
