import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/models/live/live_area_list/area_list.dart';
import 'package:PiliPlus/features/live_area/domain/repositories/live_area_repository.dart';
import 'package:PiliPlus/features/live_area/data/datasources/live_area_remote_datasource.dart';

/// Repository implementation for live area
class LiveAreaRepositoryImpl implements LiveAreaRepository {
  const LiveAreaRepositoryImpl(this._remoteDatasource);

  final LiveAreaRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<AreaList>?>> getLiveAreaList() =>
      _remoteDatasource.getLiveAreaList();

  @override
  Future<LoadingState<List<AreaItem>>> getLiveFavTag() =>
      _remoteDatasource.getLiveFavTag();

  @override
  Future<LoadingState<void>> setLiveFavTag(String ids) =>
      _remoteDatasource.setLiveFavTag(ids);
}
