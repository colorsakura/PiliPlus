import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/models/live/live_area_list/area_list.dart';

/// Repository interface for live area
abstract class LiveAreaRepository {
  /// Fetch live area list
  Future<LoadingState<List<AreaList>?>> getLiveAreaList();

  /// Fetch favorite tags
  Future<LoadingState<List<AreaItem>>> getLiveFavTag();

  /// Set favorite tags
  Future<LoadingState<void>> setLiveFavTag(String ids);
}
