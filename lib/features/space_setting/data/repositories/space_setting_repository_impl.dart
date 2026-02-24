import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_setting/data.dart';
import 'package:PiliPlus/features/space_setting/domain/repositories/space_setting_repository.dart';
import 'package:PiliPlus/features/space_setting/data/datasources/space_setting_remote_datasource.dart';

/// Space setting repository implementation
class SpaceSettingRepositoryImpl implements SpaceSettingRepository {
  final SpaceSettingRemoteDatasource _remoteDatasource;

  SpaceSettingRepositoryImpl(this._remoteDatasource);

  @override
  Future<LoadingState<SpaceSettingData>> getSpaceSetting() {
    return _remoteDatasource.fetchSpaceSetting();
  }

  @override
  Future<LoadingState<void>> updateSpaceSettingMods(Map<String, dynamic> data) {
    return _remoteDatasource.updateMods(data);
  }
}
