import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_setting/privacy.dart';
import 'package:PiliPlus/features/space_setting/domain/entities/space_setting_state.dart';
import 'package:PiliPlus/features/space_setting/domain/usecases/get_space_setting.dart';
import 'package:PiliPlus/features/space_setting/data/datasources/space_setting_remote_datasource.dart';
import 'package:PiliPlus/features/space_setting/data/repositories/space_setting_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Space setting controller
class SpaceSettingController extends Notifier<SpaceSettingState> {
  late final GetSpaceSettingUseCase _getSpaceSettingUseCase;
  late final UpdateSpaceSettingModsUseCase _updateSpaceSettingModsUseCase;

  bool _hasMod = false;

  bool get hasMod => _hasMod;
  Privacy? get currentPrivacy {
    return switch (state.privacy) {
      Success(:final response) => response,
      _ => null,
    };
  }

  @override
  SpaceSettingState build() {
    final datasource = SpaceSettingRemoteDatasource();
    final repository = SpaceSettingRepositoryImpl(datasource);
    _getSpaceSettingUseCase = GetSpaceSettingUseCase(repository);
    _updateSpaceSettingModsUseCase = UpdateSpaceSettingModsUseCase(repository);

    // Auto-load on first access
    fetchSpaceSetting();

    return SpaceSettingState(
      privacy: LoadingState.loading(),
    );
  }

  /// Fetch space setting data
  Future<void> fetchSpaceSetting() async {
    state = SpaceSettingState(
      privacy: LoadingState.loading(),
    );

    final result = await _getSpaceSettingUseCase();

    state = switch (result) {
      Loading() => SpaceSettingState(
        privacy: LoadingState.loading(),
      ),
      Success(:final response) => SpaceSettingState(
        privacy: Success(response.privacy),
      ),
      Error() => SpaceSettingState(
        privacy: result,
      ),
    };
  }

  /// Update setting item value
  void updateSettingValue(SpaceSettingModel item, bool? value) {
    _hasMod = true;
    value ??= !item.boolVal;

    item.value = item.isReverse
        ? value
              ? 0
              : 1
        : value
        ? 1
        : 0;

    // Trigger rebuild
    ref.invalidateSelf();
  }

  /// Save mods on dispose
  Future<void> saveMods() async {
    if (!_hasMod) return;

    final privacy = currentPrivacy;
    if (privacy == null) return;

    final data = {
      for (final e in privacy.list1) e.key: e.value,
      for (final e in privacy.list2) e.key: e.value,
      for (final e in privacy.list3) e.key: e.value,
    };

    final result = await _updateSpaceSettingModsUseCase(data);
    // Ignore result, toast is handled by the HTTP layer
  }

  /// Reload data
  Future<void> onReload() => fetchSpaceSetting();
}

/// Space setting controller provider
final spaceSettingControllerProvider =
    NotifierProvider<SpaceSettingController, SpaceSettingState>(
      SpaceSettingController.new,
    );
