import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/space_setting/data.dart';

/// Space setting remote data source
class SpaceSettingRemoteDatasource {
  /// Fetch space setting from API
  Future<LoadingState<SpaceSettingData>> fetchSpaceSetting() async {
    final result = await UserHttp.spaceSetting();

    return switch (result) {
      Loading() => LoadingState<SpaceSettingData>.loading(),
      Success(:final response) => Success(response),
      Error() => result as LoadingState<SpaceSettingData>,
    };
  }

  /// Update space setting mods
  Future<LoadingState<void>> updateMods(Map<String, dynamic> data) async {
    final result = await UserHttp.spaceSettingMod(data);

    return switch (result) {
      Loading() => LoadingState<void>.loading(),
      Success() => const Success(null),
      Error() => result as LoadingState<void>,
    };
  }
}
