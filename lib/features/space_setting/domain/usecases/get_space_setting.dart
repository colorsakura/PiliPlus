import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_setting/data.dart';
import 'package:PiliPlus/features/space_setting/domain/repositories/space_setting_repository.dart';

/// Get space setting use case
class GetSpaceSettingUseCase {
  final SpaceSettingRepository _repository;

  const GetSpaceSettingUseCase(this._repository);

  Future<LoadingState<SpaceSettingData>> call() {
    return _repository.getSpaceSetting();
  }
}

/// Update space setting mods use case
class UpdateSpaceSettingModsUseCase {
  final SpaceSettingRepository _repository;

  const UpdateSpaceSettingModsUseCase(this._repository);

  Future<LoadingState<void>> call(Map<String, dynamic> data) {
    return _repository.updateSpaceSettingMods(data);
  }
}
