import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/models/live/live_area_list/area_list.dart';

/// Remote data source for live area
class LiveAreaRemoteDatasource {
  const LiveAreaRemoteDatasource();

  /// Fetch live area list
  Future<LoadingState<List<AreaList>?>> getLiveAreaList() =>
      LiveHttp.liveAreaList();

  /// Fetch favorite tags
  Future<LoadingState<List<AreaItem>>> getLiveFavTag() =>
      LiveHttp.getLiveFavTag();

  /// Set favorite tags
  Future<LoadingState<void>> setLiveFavTag(String ids) =>
      LiveHttp.setLiveFavTag(ids: ids);
}
