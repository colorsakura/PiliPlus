import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_setting/data.dart';

/// Space setting repository interface
abstract interface class SpaceSettingRepository {
  /// Get space setting data
  Future<LoadingState<SpaceSettingData>> getSpaceSetting();

  /// Update space setting mods
  Future<LoadingState<void>> updateSpaceSettingMods(Map<String, dynamic> data);
}
