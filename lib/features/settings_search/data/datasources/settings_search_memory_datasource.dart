import 'package:PiliPlus/features/settings_search/domain/entities/settings_search_state_entity.dart';

/// Settings search memory data source
abstract class SettingsSearchMemoryDataSource {
  /// Get current state
  SettingsSearchStateEntity getState();

  /// Update state
  void updateState(SettingsSearchStateEntity state);
}

/// Settings search memory data source implementation
class SettingsSearchMemoryDataSourceImpl implements SettingsSearchMemoryDataSource {
  SettingsSearchStateEntity _state = const SettingsSearchStateEntity();

  @override
  SettingsSearchStateEntity getState() => _state;

  @override
  void updateState(SettingsSearchStateEntity state) {
    _state = state;
  }
}
